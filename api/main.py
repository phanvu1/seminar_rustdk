from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel
from database import get_db

app = FastAPI(title="Remote Desktop API", version="1.0")

# ==========================================
# 1. SCHEMAS (Định dạng dữ liệu JSON nhận từ Client)
# ==========================================
class LoginRequest(BaseModel):
    username: str
    password: str

class UserCreate(BaseModel):
    username: str
    password_hash: str
    full_name: str
    role_id: int

class DeviceCreate(BaseModel):
    user_id: int
    device_name: str
    rustdesk_id: str
    ip_address: str

class SessionCreate(BaseModel):
    request_id: int
    it_user_id: int
    target_user_id: int
    source_device_id: int
    target_device_id: int

# ==========================================
# 2. ROUTES (Các đường dẫn API theo thiết kế)
# ==========================================

@app.get("/")
def root(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT @@VERSION")).fetchone()
    return {"message": "FastAPI Server Đang Hoạt Động", "sql_version": result[0]}

# --- NHÓM AUTH ---
@app.post("/api/auth/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    query = text("SELECT user_id, username, role_id FROM dbo.Users WHERE username = :u AND password_hash = :p AND deleted_at IS NULL")
    user = db.execute(query, {"u": req.username, "p": req.password}).fetchone()
    if not user:
        raise HTTPException(status_code=401, detail="Sai tài khoản hoặc mật khẩu")
    return {"message": "Đăng nhập thành công", "user_id": user[0], "role_id": user[2], "token": "jwt-token-demo"}

@app.post("/api/auth/logout")
def logout():
    return {"message": "Đăng xuất thành công"}

@app.get("/api/auth/me")
def get_me():
    return {"message": "Đang phát triển: Yêu cầu giải mã JWT Token"}

# --- NHÓM USERS ---
@app.get("/api/users")
def get_users(db: Session = Depends(get_db)):
    query = text("SELECT user_id, username, full_name, role_id, status FROM dbo.Users WHERE deleted_at IS NULL")
    users = db.execute(query).fetchall()
    return {"data": [{"user_id": u[0], "username": u[1], "full_name": u[2], "role_id": u[3], "status": u[4]} for u in users]}

@app.post("/api/users")
def create_user(req: UserCreate, db: Session = Depends(get_db)):
    try:
        query = text("""
            INSERT INTO dbo.Users (username, password_hash, full_name, role_id)
            VALUES (:u, :p, :f, :r)
        """)
        db.execute(query, {"u": req.username, "p": req.password_hash, "f": req.full_name, "r": req.role_id})
        db.commit()
        return {"message": "Tạo user mới thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/users/{id}")
def update_user(id: int, full_name: str, db: Session = Depends(get_db)):
    try:
        query = text("UPDATE dbo.Users SET full_name = :f WHERE user_id = :id AND deleted_at IS NULL")
        db.execute(query, {"f": full_name, "id": id})
        db.commit()
        return {"message": f"Đã sửa user {id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.delete("/api/users/{id}")
def delete_user(id: int, db: Session = Depends(get_db)):
    try:
        query = text("UPDATE dbo.Users SET deleted_at = SYSDATETIME(), status = 'inactive' WHERE user_id = :id")
        db.execute(query, {"id": id})
        db.commit()
        return {"message": f"Đã xóa (soft-delete) user {id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# --- NHÓM DEVICES ---
@app.get("/api/devices")
def get_devices(db: Session = Depends(get_db)):
    query = text("SELECT device_id, device_name, rustdesk_id, ip_address, status FROM dbo.Devices WHERE deleted_at IS NULL")
    devices = db.execute(query).fetchall()
    return {"data": [{"device_id": d[0], "device_name": d[1], "rustdesk_id": d[2], "status": d[4]} for d in devices]}

@app.post("/api/devices")
def create_device(req: DeviceCreate, db: Session = Depends(get_db)):
    try:
        query = text("""
            INSERT INTO dbo.Devices (user_id, device_name, rustdesk_id, ip_address, status, last_online)
            VALUES (:uid, :dname, :rid, :ip, 'online', SYSDATETIME())
        """)
        db.execute(query, {"uid": req.user_id, "dname": req.device_name, "rid": req.rustdesk_id, "ip": req.ip_address})
        db.commit()
        return {"message": "Thêm thiết bị thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/devices/{id}")
def update_device(id: int, device_name: str, db: Session = Depends(get_db)):
    try:
        query = text("UPDATE dbo.Devices SET device_name = :n WHERE device_id = :id AND deleted_at IS NULL")
        db.execute(query, {"n": device_name, "id": id})
        db.commit()
        return {"message": f"Đã cập nhật thiết bị {id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.delete("/api/devices/{id}")
def delete_device(id: int, db: Session = Depends(get_db)):
    try:
        query = text("UPDATE dbo.Devices SET deleted_at = SYSDATETIME(), status = 'disabled' WHERE device_id = :id")
        db.execute(query, {"id": id})
        db.commit()
        return {"message": f"Đã xóa thiết bị {id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/devices/{id}/status")
def get_device_status(id: int, db: Session = Depends(get_db)):
    query = text("SELECT status, last_online FROM dbo.Devices WHERE device_id = :id AND deleted_at IS NULL")
    status = db.execute(query, {"id": id}).fetchone()
    if not status:
        raise HTTPException(status_code=404, detail="Không tìm thấy thiết bị")
    return {"status": status[0], "last_online": status[1]}

# --- NHÓM SESSIONS ---
@app.get("/api/sessions")
def get_sessions(db: Session = Depends(get_db)):
    query = text("SELECT session_id, it_user_id, target_user_id, status, start_time FROM dbo.RemoteSessions WHERE deleted_at IS NULL")
    sessions = db.execute(query).fetchall()
    return {"data": [{"session_id": s[0], "it_user_id": s[1], "target_user_id": s[2], "status": s[3]} for s in sessions]}

@app.post("/api/sessions")
def create_session(req: SessionCreate, db: Session = Depends(get_db)):
    try:
        query = text("""
            INSERT INTO dbo.RemoteSessions (request_id, it_user_id, target_user_id, source_device_id, target_device_id)
            VALUES (:rid, :it, :target, :sdev, :tdev)
        """)
        db.execute(query, {"rid": req.request_id, "it": req.it_user_id, "target": req.target_user_id, "sdev": req.source_device_id, "tdev": req.target_device_id})
        db.commit()
        return {"message": "Ghi log phiên thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))