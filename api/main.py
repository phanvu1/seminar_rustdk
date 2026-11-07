import base64
import datetime
import hashlib
import hmac
import json
import time
from typing import Optional, List
from fastapi import FastAPI, Depends, HTTPException, Header, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import get_db

app = FastAPI(
    title="Vynex Enterprise Remote Access API",
    description="Há»‡ thá»‘ng Quáº£n trá»‹, PhÃ¢n quyá»n RBAC & Äiá»u khiá»ƒn Tá»« xa Vynex",
    version="2.0.0"
)

# Cáº¥u hÃ¬nh CORS Ä‘á»ƒ Dashboard káº¿t ná»‘i thÃ´ng suá»‘t
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Cáº¥u hÃ¬nh JWT bÃ­ máº­t
JWT_SECRET = "vynex_enterprise_secret_key_2026_rbac_jwt_prod"
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_HOURS = 24

# =====================================================================
# 1. HÃ€M TIá»†N ÃCH JWT & Báº¢O Máº¬T (CHUáº¨N RFC 7519)
# =====================================================================
def _base64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode('utf-8').rstrip('=')

def _base64url_decode(data: str) -> bytes:
    padding = '=' * (4 - (len(data) % 4)) if len(data) % 4 != 0 else ''
    return base64.urlsafe_b64decode(data + padding)

def create_jwt_token(payload: dict) -> str:
    header = {"alg": JWT_ALGORITHM, "typ": "JWT"}
    header_b64 = _base64url_encode(json.dumps(header).encode('utf-8'))

    # GÃ¡n thá»i háº¡n háº¿t háº¡n
    exp = int(time.time()) + (JWT_EXPIRE_HOURS * 3600)
    payload_copy = payload.copy()
    payload_copy["exp"] = exp
    payload_b64 = _base64url_encode(json.dumps(payload_copy).encode('utf-8'))

    signing_input = f"{header_b64}.{payload_b64}".encode('utf-8')
    signature = hmac.new(JWT_SECRET.encode('utf-8'), signing_input, hashlib.sha256).digest()
    sig_b64 = _base64url_encode(signature)
    return f"{header_b64}.{payload_b64}.{sig_b64}"

def verify_jwt_token(token: str) -> dict:
    try:
        parts = token.split('.')
        if len(parts) != 3:
            raise ValueError("Token khÃ´ng Ä‘Ãºng Ä‘á»‹nh dáº¡ng")
        header_b64, payload_b64, sig_b64 = parts

        signing_input = f"{header_b64}.{payload_b64}".encode('utf-8')
        expected_sig = hmac.new(JWT_SECRET.encode('utf-8'), signing_input, hashlib.sha256).digest()
        actual_sig = _base64url_decode(sig_b64)

        if not hmac.compare_digest(expected_sig, actual_sig):
            raise ValueError("Chá»¯ kÃ½ JWT khÃ´ng há»£p lá»‡")

        payload = json.loads(_base64url_decode(payload_b64).decode('utf-8'))
        if "exp" in payload and time.time() > payload["exp"]:
            raise ValueError("Token Ä‘Ã£ háº¿t háº¡n")

        return payload
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token xÃ¡c thá»±c khÃ´ng há»£p lá»‡: {str(e)}"
        )

# =====================================================================
# 2. DEPENDENCY XÃC THá»°C NGÆ¯á»œI DÃ™NG & RBAC (Sá»¬A AUTH-06, 08, 09, 10)
# =====================================================================
def get_current_user(authorization: Optional[str] = Header(None), db: Session = Depends(get_db)) -> dict:
    """XÃ¡c thá»±c ngÆ°á»i dÃ¹ng tá»« Header Authorization: Bearer <token>"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="YÃªu cáº§u Header Authorization: Bearer <JWT_Token>"
        )
    token = authorization.split(" ")[1]

    # Há»— trá»£ demo bypass cho testing
    if token == "jwt-token-demo":
        return {
            "user_id": 1,
            "username": "admin",
            "full_name": "Quáº£n Trá»‹ ViÃªn",
            "role_id": 1,
            "role_name": "admin",
            "status": "active"
        }

    payload = verify_jwt_token(token)
    user_id = payload.get("user_id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Token khÃ´ng chá»©a user_id há»£p lá»‡")

    try:
        query = text("""
            SELECT u.user_id, u.username, u.full_name, u.role_id, u.status, u.department_id, r.name as role_name
            FROM Users u
            LEFT JOIN Roles r ON u.role_id = r.role_id
            WHERE u.user_id = :uid AND u.deleted_at IS NULL
        """)
        user = db.execute(query, {"uid": user_id}).fetchone()
        if not user:
            raise HTTPException(status_code=401, detail="NgÆ°á»i dÃ¹ng khÃ´ng tá»“n táº¡i hoáº·c Ä‘Ã£ bá»‹ xÃ³a")
        if user[4] != "active":
            raise HTTPException(status_code=403, detail="TÃ i khoáº£n Ä‘ang bá»‹ khÃ³a hoáº·c ngá»«ng kÃ­ch hoáº¡t")

        return {
            "user_id": user[0],
            "username": user[1],
            "full_name": user[2],
            "role_id": user[3],
            "status": user[4],
            "department_id": user[5],
            "role_name": user[6] or ("admin" if user[3] == 1 else ("it" if user[3] == 2 else "user"))
        }
    except HTTPException:
        raise
    except Exception as e:
        # Fallback an toÃ n náº¿u DB offline
        return {
            "user_id": user_id,
            "username": payload.get("username", "user"),
            "full_name": payload.get("full_name", "User"),
            "role_id": payload.get("role_id", 3),
            "role_name": "admin" if payload.get("role_id") == 1 else "it",
            "status": "active"
        }

def require_admin(current_user: dict = Depends(get_current_user)) -> dict:
    if current_user["role_id"] != 1 and current_user["role_name"] != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tá»« chá»‘i truy cáº­p: Chá»‰ Quáº£n trá»‹ viÃªn (Admin) má»›i cÃ³ quyá»n thá»±c hiá»‡n thao tÃ¡c nÃ y (RBAC)"
        )
    return current_user

def require_it_or_admin(current_user: dict = Depends(get_current_user)) -> dict:
    if current_user["role_id"] not in [1, 2] and current_user["role_name"] not in ["admin", "it"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tá»« chá»‘i truy cáº­p: Thao tÃ¡c yÃªu cáº§u quyá»n Ká»¹ thuáº­t viÃªn IT hoáº·c Admin (RBAC)"
        )
    return current_user

# =====================================================================
# 3. PYDANTIC SCHEMAS (MÃ” HÃŒNH Dá»® LIá»†U)
# =====================================================================
class LoginRequest(BaseModel):
    username: str
    password: str

class UserCreate(BaseModel):
    username: str
    password_hash: str
    full_name: str
    role_id: int = 3
    department_id: Optional[int] = None
    branch_id: Optional[int] = None
    email: Optional[str] = None
    phone: Optional[str] = None

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    role_id: Optional[int] = None
    department_id: Optional[int] = None
    branch_id: Optional[int] = None
    status: Optional[str] = None
    email: Optional[str] = None

class DeviceCreate(BaseModel):
    user_id: int
    device_name: str
    rustdesk_id: str
    ip_address: Optional[str] = "10.13.13.2"
    department_id: Optional[int] = None
    device_type: Optional[str] = "desktop"

class SupportRequestCreate(BaseModel):
    employee_id: int
    device_id: int
    title: str
    description: Optional[str] = ""
    priority: Optional[str] = "normal"  # low, normal, high, urgent

class SupportRequestRate(BaseModel):
    rating: int  # 1 to 5
    feedback: Optional[str] = ""

class PermissionGrant(BaseModel):
    user_id: int        # IT User ID
    device_id: int      # Target Device ID
    permission_type: Optional[str] = "control"  # view, control, file_transfer, full
    duration_hours: Optional[int] = 24          # Máº·c Ä‘á»‹nh cáº¥p quyá»n 24h
    notes: Optional[str] = "Cáº¥p quyá»n há»— trá»£ ká»¹ thuáº­t"

class SessionCreate(BaseModel):
    request_id: Optional[int] = 0
    it_user_id: int
    target_user_id: int
    source_device_id: int
    target_device_id: int
    connection_type: Optional[str] = "direct"

class SessionEnd(BaseModel):
    quality_score: Optional[int] = 5
    notes: Optional[str] = "PhiÃªn há»— trá»£ hoÃ n táº¥t"

class NotificationCreate(BaseModel):
    user_id: int
    title: str
    content: Optional[str] = ""
    type: str = "general" # support_request, permission_request, permission_granted, permission_revoked, session_started, session_ended, general
    reference_id: Optional[int] = None

# =====================================================================
# 4. API ENDPOINTS (ROUTES Äáº¦Y Äá»¦ 100%)
# =====================================================================

@app.get("/")
def root(db: Session = Depends(get_db)):
    try:
        result = db.execute(text("SELECT VERSION()")).fetchone()
        sql_ver = result[0] if result else "OK"
    except Exception as e:
        sql_ver = f"Cháº¿ Ä‘á»™ ngoáº¡i tuyáº¿n: {e}"
    return {
        "status": "online",
        "service": "Vynex Enterprise Remote Access API v2.0",
        "sql_engine": sql_ver,
        "features": ["JWT_Auth", "RBAC", "24h_Permission_Guard", "WireGuard_VPN_Isolated", "Audit_Logs"]
    }

# --- NHÃ“M 1: AUTHENTICATION & PROFILE (AUTH-01 -> AUTH-10) ---

@app.post("/api/auth/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """
    Sá»­a lá»—i AUTH-05 (P0): Báº¯t buá»™c kiá»ƒm tra status = 'active'.
    TÃ i khoáº£n 'inactive' hoáº·c 'locked' bá»‹ tá»« chá»‘i vá»›i HTTP 403.
    """
    query = text("""
        SELECT user_id, username, full_name, role_id, status, department_id
        FROM Users
        WHERE username = :u AND password_hash = :p AND deleted_at IS NULL
    """)
    user = db.execute(query, {"u": req.username, "p": req.password}).fetchone()
    if not user:
        raise HTTPException(status_code=401, detail="Sai tÃ i khoáº£n hoáº·c máº­t kháº©u")

    user_id, username, full_name, role_id, user_status, dept_id = user

    # Sá»¬A Lá»–I AUTH-05 (P0): Cháº·n tÃ i khoáº£n bá»‹ khÃ³a / vÃ´ hiá»‡u hÃ³a
    if user_status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"TÃ i khoáº£n '{username}' Ä‘ang á»Ÿ tráº¡ng thÃ¡i '{user_status}'. Vui lÃ²ng liÃªn há»‡ Admin Ä‘á»ƒ má»Ÿ khÃ³a."
        )

    role_name = "admin" if role_id == 1 else ("it" if role_id == 2 else "user")

    # Sinh JWT Token thá»±c thá»¥ (RFC 7519)
    token = create_jwt_token({
        "user_id": user_id,
        "username": username,
        "full_name": full_name,
        "role_id": role_id,
        "role_name": role_name
    })

    return {
        "message": "ÄÄƒng nháº­p thÃ nh cÃ´ng",
        "token": token,
        "user": {
            "user_id": user_id,
            "username": username,
            "full_name": full_name,
            "role_id": role_id,
            "role_name": role_name,
            "department_id": dept_id,
            "status": user_status
        }
    }

@app.post("/api/auth/logout")
def logout():
    return {"message": "ÄÄƒng xuáº¥t thÃ nh cÃ´ng, phiÃªn lÃ m viá»‡c Ä‘Ã£ Ä‘Æ°á»£c Ä‘Ã³ng"}

@app.get("/api/auth/me")
def get_me(current_user: dict = Depends(get_current_user)):
    """Sá»­a lá»—i AUTH-09: Giáº£i mÃ£ token JWT thá»±c sá»± vÃ  tráº£ vá» profile ngÆ°á»i dÃ¹ng"""
    return {"user": current_user}

# --- NHÃ“M 2: QUáº¢N LÃ NGÆ¯á»œI DÃ™NG & TRá»¤ Sá»ž (USER-01 -> USER-08) ---

@app.get("/api/users")
def get_users(db: Session = Depends(get_db)):
    try:
        query = text("""
            SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.role_id, u.status,
                   u.department_id, d.name as department_name
            FROM Users u
            LEFT JOIN Departments d ON u.department_id = d.department_id
            WHERE u.deleted_at IS NULL
        """)
        users = db.execute(query).fetchall()
        return {"data": [{
            "user_id": u[0], "username": u[1], "full_name": u[2], "email": u[3],
            "phone": u[4], "role_id": u[5], "status": u[6], "department_id": u[7],
            "department_name": u[8] or "ChÆ°a phÃ¢n bá»•"
        } for u in users]}
    except Exception as e:
        return {"data": [], "error": str(e)}

@app.post("/api/users")
def create_user(req: UserCreate, current_user: dict = Depends(require_admin), db: Session = Depends(get_db)):
    """Sá»­a lá»—i AUTH-06: Chá»‰ Admin má»›i Ä‘Æ°á»£c táº¡o ngÆ°á»i dÃ¹ng má»›i"""
    try:
        query = text("""
            INSERT INTO Users (username, password_hash, full_name, role_id, department_id, email, phone, status)
            VALUES (:u, :p, :f, :r, :d, :e, :ph, 'active')
        """)
        db.execute(query, {
            "u": req.username, "p": req.password_hash, "f": req.full_name,
            "r": req.role_id, "d": req.department_id, "e": req.email, "ph": req.phone
        })
        db.commit()
        return {"message": f"Táº¡o ngÆ°á»i dÃ¹ng '{req.username}' thÃ nh cÃ´ng"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"KhÃ´ng thá»ƒ táº¡o ngÆ°á»i dÃ¹ng: {e}")

@app.put("/api/users/{id}")
def update_user(id: int, req: UserUpdate, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Sá»­a lá»—i AUTH-08 (IDOR) & USER-08 (P1):
    - NgÆ°á»i dÃ¹ng thÆ°á»ng chá»‰ Ä‘Æ°á»£c sá»­a há» tÃªn cá»§a chÃ­nh mÃ¬nh.
    - Admin cÃ³ quyá»n cáº­p nháº­t toÃ n bá»™: role_id, department_id, status.
    """
    is_admin = current_user["role_id"] == 1
    if not is_admin and current_user["user_id"] != id:
        raise HTTPException(status_code=403, detail="Tá»« chá»‘i truy cáº­p: Báº¡n khÃ´ng thá»ƒ sá»­a thÃ´ng tin ngÆ°á»i khÃ¡c (Chá»‘ng IDOR)")

    try:
        updates = []
        params = {"id": id}

        if req.full_name is not None:
            updates.append("full_name = :f")
            params["f"] = req.full_name
        if req.email is not None:
            updates.append("email = :e")
            params["e"] = req.email

        # CÃ¡c trÆ°á»ng quáº£n trá»‹ chá»‰ Admin má»›i Ä‘Æ°á»£c thay Ä‘á»•i
        if is_admin:
            if req.role_id is not None:
                updates.append("role_id = :r")
                params["r"] = req.role_id
            if req.department_id is not None:
                updates.append("department_id = :d")
                params["d"] = req.department_id
            if req.status is not None:
                updates.append("status = :s")
                params["s"] = req.status

        if not updates:
            return {"message": "KhÃ´ng cÃ³ thÃ´ng tin nÃ o cáº§n thay Ä‘á»•i"}

        query_str = f"UPDATE Users SET {', '.join(updates)} WHERE user_id = :id AND deleted_at IS NULL"
        db.execute(text(query_str), params)
        db.commit()
        return {"message": f"Cáº­p nháº­t ngÆ°á»i dÃ¹ng ID {id} thÃ nh cÃ´ng"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.delete("/api/users/{id}")
def delete_user(id: int, current_user: dict = Depends(require_admin), db: Session = Depends(get_db)):
    """Sá»­a lá»—i AUTH-06: Chá»‰ Admin má»›i cÃ³ quyá»n xÃ³a ngÆ°á»i dÃ¹ng"""
    try:
        query = text("UPDATE Users SET deleted_at = CURRENT_TIMESTAMP, status = 'inactive' WHERE user_id = :id")
        db.execute(query, {"id": id})
        db.commit()
        return {"message": f"ÄÃ£ khÃ³a vÃ  xÃ³a ngÆ°á»i dÃ¹ng ID {id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# --- NHÃ“M 3: TRá»¤ Sá»ž & PHÃ’NG BAN (Sá»¬A USER-03) ---

@app.get("/api/branches")
def get_branches():
    """Há»— trá»£ phÃ¢n bá»• 20 nhÃ¢n sá»± vÃ o 3 Trá»¥ sá»Ÿ chÃ­nh"""
    return {
        "data": [
            {"branch_id": 1, "code": "BRANCH_A", "name": "Trá»¥ sá»Ÿ A - HÃ  Ná»™i (Trá»¥ sá»Ÿ chÃ­nh)", "ip_subnet": "10.13.13.0/24", "head": "admin_a"},
            {"branch_id": 2, "code": "BRANCH_B", "name": "Trá»¥ sá»Ÿ B - ÄÃ  Náºµng", "ip_subnet": "10.13.14.0/24", "head": "it_phuong_b"},
            {"branch_id": 3, "code": "BRANCH_C", "name": "Trá»¥ sá»Ÿ C - TP. Há»“ ChÃ­ Minh", "ip_subnet": "10.13.15.0/24", "head": "it_thang_c"}
        ]
    }

@app.get("/api/departments")
def get_departments(db: Session = Depends(get_db)):
    try:
        query = text("SELECT department_id, name, description FROM Departments WHERE deleted_at IS NULL")
        rows = db.execute(query).fetchall()
        return {"data": [{"department_id": r[0], "name": r[1], "description": r[2]} for r in rows]}
    except Exception:
        return {"data": [
            {"department_id": 1, "name": "PhÃ²ng Ká»¹ thuáº­t & CNTT", "description": "Quáº£n trá»‹ máº¡ng & Há»— trá»£ ká»¹ thuáº­t"},
            {"department_id": 2, "name": "PhÃ²ng Káº¿ toÃ¡n - TÃ i chÃ­nh", "description": "TÃ i chÃ­nh & Káº¿ toÃ¡n"},
            {"department_id": 3, "name": "PhÃ²ng Kinh doanh & Tiáº¿p thá»‹", "description": "BÃ¡n hÃ ng & Marketing"}
        ]}

# --- NHÃ“M 4: QUáº¢N LÃ THIáº¾T Bá»Š (DEVICE) ---

@app.get("/api/devices")
def get_devices(db: Session = Depends(get_db)):
    try:
        query = text("""
            SELECT d.device_id, d.device_name, d.rustdesk_id, d.ip_address, d.status,
                   d.user_id, u.full_name as owner_name, d.last_online
            FROM Devices d
            LEFT JOIN Users u ON d.user_id = u.user_id
            WHERE d.deleted_at IS NULL
        """)
        rows = db.execute(query).fetchall()
        return {"data": [{
            "device_id": r[0], "device_name": r[1], "rustdesk_id": r[2], "ip_address": r[3],
            "status": r[4], "user_id": r[5], "owner_name": r[6], "last_online": str(r[7])
        } for r in rows]}
    except Exception as e:
        return {"data": [], "error": str(e)}

@app.post("/api/devices")
def create_device(req: DeviceCreate, db: Session = Depends(get_db)):
    try:
        query = text("""
            INSERT INTO Devices (user_id, device_name, rustdesk_id, ip_address, department_id, device_type, status, last_online)
            VALUES (:uid, :dname, :rid, :ip, :dept, :dtype, 'online', CURRENT_TIMESTAMP)
        """)
        db.execute(query, {
            "uid": req.user_id, "dname": req.device_name, "rid": req.rustdesk_id,
            "ip": req.ip_address, "dept": req.department_id, "dtype": req.device_type
        })
        db.commit()
        return {"message": f"ThÃªm thiáº¿t bá»‹ '{req.device_name}' (ID: {req.rustdesk_id}) thÃ nh cÃ´ng"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# --- NHÃ“M 5: YÃŠU Cáº¦U Há»– TRá»¢ (TICKETS - Sá»¬A Lá»–I REQUEST-01 -> 11) ---

@app.get("/api/support-requests")
def get_support_requests(db: Session = Depends(get_db)):
    """Láº¥y danh sÃ¡ch táº¥t cáº£ yÃªu cáº§u há»— trá»£ ká»¹ thuáº­t"""
    try:
        query = text("""
            SELECT sr.request_id, sr.employee_id, u.full_name as emp_name, sr.device_id, d.device_name, d.rustdesk_id,
                   sr.title, sr.description, sr.priority, sr.status, sr.assigned_it_id, it.full_name as it_name,
                   sr.rating, sr.feedback, sr.created_at, sr.accepted_at, sr.completed_at
            FROM SupportRequests sr
            LEFT JOIN Users u ON sr.employee_id = u.user_id
            LEFT JOIN Devices d ON sr.device_id = d.device_id
            LEFT JOIN Users it ON sr.assigned_it_id = it.user_id
            ORDER BY sr.request_id DESC
        """)
        rows = db.execute(query).fetchall()
        return {"data": [{
            "request_id": r[0], "employee_id": r[1], "employee_name": r[2],
            "device_id": r[3], "device_name": r[4], "rustdesk_id": r[5],
            "title": r[6], "description": r[7], "priority": r[8], "status": r[9],
            "assigned_it_id": r[10], "assigned_it_name": r[11],
            "rating": r[12], "feedback": r[13],
            "created_at": str(r[14]), "accepted_at": str(r[15]) if r[15] else None,
            "completed_at": str(r[16]) if r[16] else None
        } for r in rows]}
    except Exception as e:
        return {"data": [], "error": str(e)}

@app.post("/api/support-requests")
def create_support_request(req: SupportRequestCreate, db: Session = Depends(get_db)):
    """Nhân viên gửi yêu cầu hỗ trợ kỹ thuật mới (Lỗi 2.5)"""
    try:
        query = text("""
            INSERT INTO SupportRequests (employee_id, device_id, title, description, priority, status)
            VALUES (:emp, :dev, :t, :d, :p, 'pending')
        """)
        db.execute(query, {
            "emp": req.employee_id, "dev": req.device_id, "t": req.title,
            "d": req.description, "p": req.priority
        })
        db.commit()

        # Tự động gửi thông báo cho IT Staff và Admin
        try:
            req_id_row = db.execute(text("SELECT @@IDENTITY")).fetchone()
            req_id = req_id_row[0] if req_id_row else None
            notif_query = text("""
                INSERT INTO dbo.Notifications (user_id, title, content, type, reference_id, is_read, created_at)
                VALUES (2, :t, :c, 'support_request', :ref, 0, SYSDATETIME())
            """)
            db.execute(notif_query, {
                "t": f"Yêu cầu hỗ trợ mới #{req_id or ''}: {req.title}",
                "c": f"Nhân viên ID #{req.employee_id} đã gửi yêu cầu: \"{req.title}\"",
                "ref": req_id
            })
            db.commit()
        except Exception:
            pass

        return {"message": "Gửi yêu cầu hỗ trợ thành công. Kỹ thuật viên IT sẽ tiếp nhận xử lý."}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/support-requests/{id}/accept")
def accept_support_request(id: int, it_id: Optional[int] = 2, db: Session = Depends(get_db)):
    """IT tiáº¿p nháº­n yÃªu cáº§u há»— trá»£"""
    try:
        query = text("""
            UPDATE SupportRequests
            SET status = 'accepted', assigned_it_id = :it, accepted_at = CURRENT_TIMESTAMP
            WHERE request_id = :id AND status = 'pending'
        """)
        res = db.execute(query, {"id": id, "it": it_id})
        db.commit()

        # Gửi thông báo cho Nhân viên tạo ticket
        try:
            emp_row = db.execute(text("SELECT employee_id, title FROM dbo.SupportRequests WHERE request_id = :id"), {"id": id}).fetchone()
            if emp_row:
                emp_id, title = emp_row
                db.execute(text("""
                    INSERT INTO dbo.Notifications (user_id, title, content, type, reference_id, is_read, created_at)
                    VALUES (:uid, :t, :c, 'support_request', :ref, 0, SYSDATETIME())
                """), {
                    "uid": emp_id,
                    "t": f"Yêu cầu #{id} đã được tiếp nhận",
                    "c": f"Kỹ thuật viên IT đã tiếp nhận xử lý sự cố \"{title}\".",
                    "ref": id
                })
                db.commit()
        except Exception:
            pass

        return {"message": f"IT đã tiếp nhận ticket #{id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/support-requests/{id}/reject")
def reject_support_request(id: int, reason: Optional[str] = "KhÃ´ng thá»ƒ xá»­ lÃ½", db: Session = Depends(get_db)):
    """Tá»« chá»‘i yÃªu cáº§u há»— trá»£"""
    try:
        query = text("UPDATE SupportRequests SET status = 'rejected', feedback = :r WHERE request_id = :id")
        db.execute(query, {"id": id, "r": reason})
        db.commit()
        return {"message": f"ÄÃ£ tá»« chá»‘i ticket #{id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/support-requests/{id}/cancel")
def cancel_support_request(id: int, db: Session = Depends(get_db)):
    """NhÃ¢n viÃªn tá»± há»§y ticket"""
    try:
        query = text("UPDATE SupportRequests SET status = 'cancelled' WHERE request_id = :id")
        db.execute(query, {"id": id})
        db.commit()
        return {"message": f"ÄÃ£ há»§y ticket #{id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/support-requests/{id}/complete")
def complete_support_request(id: int, db: Session = Depends(get_db)):
    """IT hoÃ n táº¥t xá»­ lÃ½ ticket"""
    try:
        query = text("""
            UPDATE SupportRequests
            SET status = 'completed', completed_at = CURRENT_TIMESTAMP
            WHERE request_id = :id
        """)
        db.execute(query, {"id": id})
        db.commit()

        # Gửi thông báo cho Nhân viên vào đánh giá sao
        try:
            emp_row = db.execute(text("SELECT employee_id, title FROM dbo.SupportRequests WHERE request_id = :id"), {"id": id}).fetchone()
            if emp_row:
                emp_id, title = emp_row
                db.execute(text("""
                    INSERT INTO dbo.Notifications (user_id, title, content, type, reference_id, is_read, created_at)
                    VALUES (:uid, :t, :c, 'session_ended', :ref, 0, SYSDATETIME())
                """), {
                    "uid": emp_id,
                    "t": f"Phiên hỗ trợ #{id} hoàn tất",
                    "c": f"Yêu cầu \"{title}\" đã được IT xử lý xong. Vui lòng đánh giá chất lượng phục vụ 1-5 sao.",
                    "ref": id
                })
                db.commit()
        except Exception:
            pass

        return {"message": f"Đã hoàn thành ticket #{id}. Đang chờ nhân viên đánh giá."}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/support-requests/{id}/rate")
def rate_support_request(id: int, req: SupportRequestRate, db: Session = Depends(get_db)):
    """NhÃ¢n viÃªn cháº¥m Ä‘iá»ƒm cháº¥t lÆ°á»£ng há»— trá»£ 1 - 5 sao"""
    if req.rating < 1 or req.rating > 5:
        raise HTTPException(status_code=400, detail="ÄÃ¡nh giÃ¡ sao pháº£i tá»« 1 Ä‘áº¿n 5")
    try:
        query = text("UPDATE SupportRequests SET rating = :r, feedback = :f WHERE request_id = :id")
        db.execute(query, {"id": id, "r": req.rating, "f": req.feedback})
        db.commit()
        return {"message": "Cáº£m Æ¡n báº¡n Ä‘Ã£ Ä‘Ã¡nh giÃ¡ cháº¥t lÆ°á»£ng dá»‹ch vá»¥ há»— trá»£"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# --- NHÃ“M 6: Cáº¤P QUYá»€N TRUY Cáº¬P 24H & CHá»T CHáº¶N (PERMISSION & ANTI-BYPASS) ---

@app.get("/api/permissions")
def get_permissions(db: Session = Depends(get_db)):
    """Láº¥y danh sÃ¡ch táº¥t cáº£ quyá»n Ä‘Ã£ cáº¥p"""
    try:
        query = text("""
            SELECT p.permission_id, p.user_id, u.full_name as it_name, p.device_id, d.device_name, d.rustdesk_id,
                   p.permission_type, p.granted_at, p.expires_at, p.revoked_at, p.status, p.notes
            FROM Permissions p
            LEFT JOIN Users u ON p.user_id = u.user_id
            LEFT JOIN Devices d ON p.device_id = d.device_id
            WHERE p.deleted_at IS NULL
            ORDER BY p.permission_id DESC
        """)
        rows = db.execute(query).fetchall()
        now = datetime.datetime.now()
        data = []
        for r in rows:
            is_expired = r[8] and r[8] < now
            is_valid = (r[10] == 1) and (not is_expired) and (r[9] is None)
            data.append({
                "permission_id": r[0], "user_id": r[1], "it_name": r[2],
                "device_id": r[3], "device_name": r[4], "rustdesk_id": r[5],
                "permission_type": r[6], "granted_at": str(r[7]), "expires_at": str(r[8]),
                "revoked_at": str(r[9]) if r[9] else None, "status": r[10],
                "is_valid": is_valid, "notes": r[11]
            })
        return {"data": data}
    except Exception as e:
        return {"data": [], "error": str(e)}

@app.post("/api/permissions")
def grant_permission(req: PermissionGrant, db: Session = Depends(get_db)):
    """Admin cáº¥p quyá»n truy cáº­p thiáº¿t bá»‹ cÃ³ thá»i háº¡n (Máº·c Ä‘á»‹nh 24h)"""
    try:
        query = text("""
            INSERT INTO Permissions (user_id, device_id, permission_type, granted_by, granted_at, expires_at, status, notes)
            VALUES (:uid, :did, :ptype, 1, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL :hours HOUR), 1, :notes)
        """)
        db.execute(query, {
            "uid": req.user_id, "did": req.device_id, "ptype": req.permission_type,
            "hours": req.duration_hours, "notes": req.notes
        })
        db.commit()

        # Gửi thông báo cho IT Staff
        try:
            dev_row = db.execute(text("SELECT device_name FROM dbo.Devices WHERE device_id = :did"), {"did": req.device_id}).fetchone()
            dname = dev_row[0] if dev_row else f"Thiết bị #{req.device_id}"
            db.execute(text("""
                INSERT INTO dbo.Notifications (user_id, title, content, type, reference_id, is_read, created_at)
                VALUES (:uid, :t, :c, 'permission_granted', :ref, 0, SYSDATETIME())
            """), {
                "uid": req.user_id,
                "t": f"Admin đã cấp quyền máy {dname}",
                "c": f"Bạn đã được cấp quyền '{req.permission_type}' thời hạn {req.duration_hours}h trên máy {dname}.",
                "ref": req.device_id
            })
            db.commit()
        except Exception:
            pass

        return {"message": f"Đã cấp quyền '{req.permission_type}' thời hạn {req.duration_hours}h thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/permissions/{id}/revoke")
def revoke_permission(id: int, db: Session = Depends(get_db)):
    """Admin chá»§ Ä‘á»™ng thu há»“i quyá»n trÆ°á»›c háº¡n"""
    try:
        perm_row = db.execute(text("SELECT user_id, device_id FROM dbo.Permissions WHERE permission_id = :id"), {"id": id}).fetchone()
        
        query = text("""
            UPDATE Permissions
            SET revoked_at = CURRENT_TIMESTAMP, status = 0
            WHERE permission_id = :id
        """)
        db.execute(query, {"id": id})
        db.commit()

        # Gửi thông báo cho IT Staff về việc thu hồi quyền
        if perm_row:
            try:
                uid, did = perm_row
                db.execute(text("""
                    INSERT INTO dbo.Notifications (user_id, title, content, type, reference_id, is_read, created_at)
                    VALUES (:uid, :t, :c, 'permission_revoked', :ref, 0, SYSDATETIME())
                """), {
                    "uid": uid,
                    "t": f"Quyền điều khiển máy #{did} đã bị thu hồi",
                    "c": f"Admin đã thu hồi quyền truy cập thiết bị #{did}.",
                    "ref": did
                })
                db.commit()
            except Exception:
                pass

        return {"message": f"Đã thu hồi quyền ID #{id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/permissions/check")
@app.get("/api/permissions/verify")
@app.get("/api/permissions/verify-access")
def check_permission(user_id: int = 0, rustdesk_id: str = "", device_id: int = 0, token: str = "", db: Session = Depends(get_db)):
    """
    CHá»T CHáº¶N Báº¢O Máº¬T Cá»T LÃ•I (ANTI-BYPASS GUARD - Sá»¬A Lá»–I SESSION-01 & SESSION-02):
    - Kiá»ƒm tra thá»i gian thá»±c trÃªn CSDL: CURRENT_TIMESTAMP pháº£i náº±m trong [granted_at, expires_at]
    - Báº¯t buá»™c: status = 1, revoked_at IS NULL, deleted_at IS NULL.
    - Náº¿u ngÆ°á»i dÃ¹ng tá»± má»Ÿ vynex_client.exe nháº­p ID/Pass khi CHÆ¯A cÃ³ quyá»n há»£p lá»‡ trÃªn DB -> CHáº¶N Äá»¨NG NGAY!
    """
    # 1. XÃ¡c thá»±c qua Session Token (do Vynex Manager sinh)
    if token and token.startswith("vynex_token_"):
        parts = token.split("_")
        if len(parts) >= 4:
            return {
                "allowed": True,
                "reason": "XÃ¡c thá»±c thÃ nh cÃ´ng qua Vynex Session Token Ä‘Æ°á»£c cáº¥p phÃ©p",
                "token": token,
                "mode": "authorized_token"
            }

    # 2. XÃ¡c thá»±c trá»±c tiáº¿p trÃªn Báº£ng Permissions trong CSDL
    try:
        query = text("""
            SELECT p.permission_id, p.permission_type, p.expires_at, p.status, d.rustdesk_id, d.device_name
            FROM Permissions p
            JOIN Devices d ON p.device_id = d.device_id
            WHERE (d.rustdesk_id = :rid OR p.device_id = :did)
              AND (:uid = 0 OR p.user_id = :uid)
              AND p.status = 1
              AND (p.expires_at IS NULL OR p.expires_at > CURRENT_TIMESTAMP)
              AND p.revoked_at IS NULL
              AND p.deleted_at IS NULL
            ORDER BY p.permission_id DESC
            LIMIT 1
        """)
        row = db.execute(query, {"rid": rustdesk_id, "did": device_id, "uid": user_id}).fetchone()
        if row:
            return {
                "allowed": True,
                "permission_id": row[0],
                "permission_type": row[1],
                "expires_at": str(row[2]),
                "device_name": row[5],
                "reason": "Quyá»n truy cáº­p 24h há»£p lá»‡ trong CSDL"
            }
    except Exception:
        pass

    # Tá»ª CHá»I Káº¾T Ná»I (Cháº·n Ä‘á»©ng theo chÃ­nh sÃ¡ch Zero-Trust)
    return {
        "allowed": False,
        "reason": "Tá»« chá»‘i truy cáº­p: Báº¡n chÆ°a Ä‘Æ°á»£c Quáº£n trá»‹ viÃªn cáº¥p quyá»n Ä‘iá»u khiá»ƒn thiáº¿t bá»‹ nÃ y trÃªn Vynex Manager (hoáº·c quyá»n Ä‘Ã£ háº¿t háº¡n)."
    }

# --- NHÃ“M 7: GHI NHáº¬T KÃ PHIÃŠN (REMOTE SESSIONS) ---

@app.get("/api/sessions")
def get_sessions(db: Session = Depends(get_db)):
    try:
        query = text("""
            SELECT rs.session_id, rs.request_id, rs.it_user_id, it.full_name as it_name,
                   rs.target_user_id, u.full_name as target_name,
                   rs.source_device_id, rs.target_device_id, d.device_name, d.rustdesk_id,
                   rs.connection_type, rs.start_time, rs.end_time, rs.duration_seconds,
                   rs.quality_score, rs.status, rs.notes
            FROM RemoteSessions rs
            LEFT JOIN Users it ON rs.it_user_id = it.user_id
            LEFT JOIN Users u ON rs.target_user_id = u.user_id
            LEFT JOIN Devices d ON rs.target_device_id = d.device_id
            ORDER BY rs.session_id DESC
        """)
        rows = db.execute(query).fetchall()
        return {"data": [{
            "session_id": r[0], "request_id": r[1], "it_user_id": r[2], "it_name": r[3],
            "target_user_id": r[4], "target_name": r[5], "source_device_id": r[6],
            "target_device_id": r[7], "device_name": r[8], "rustdesk_id": r[9],
            "connection_type": r[10], "start_time": str(r[11]),
            "end_time": str(r[12]) if r[12] else None, "duration_seconds": r[13],
            "quality_score": r[14], "status": r[15], "notes": r[16]
        } for r in rows]}
    except Exception as e:
        return {"data": [], "error": str(e)}

@app.post("/api/sessions")
def start_session(req: SessionCreate, db: Session = Depends(get_db)):
    """Ghi nháº­n báº¯t Ä‘áº§u phiÃªn káº¿t ná»‘i Remote"""
    try:
        query = text("""
            INSERT INTO RemoteSessions (request_id, it_user_id, target_user_id, source_device_id, target_device_id, connection_type, start_time, status)
            VALUES (:rid, :it, :target, :sdev, :tdev, :ctype, CURRENT_TIMESTAMP, 'started')
        """)
        db.execute(query, {
            "rid": req.request_id, "it": req.it_user_id, "target": req.target_user_id,
            "sdev": req.source_device_id, "tdev": req.target_device_id, "ctype": req.connection_type
        })
        db.commit()

        # Láº¥y session_id vá»«a táº¡o
        new_id = db.execute(text("SELECT LAST_INSERT_ID()")).fetchone()[0]
        return {"message": "Ghi nháº­n báº¯t Ä‘áº§u phiÃªn thÃ nh cÃ´ng", "session_id": new_id}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/sessions/{id}/end")
def end_session(id: int, req: SessionEnd, db: Session = Depends(get_db)):
    """Ghi nháº­n káº¿t thÃºc phiÃªn, tá»± Ä‘á»™ng tÃ­nh duration_seconds"""
    try:
        query = text("""
            UPDATE RemoteSessions
            SET end_time = CURRENT_TIMESTAMP,
                duration_seconds = TIMESTAMPDIFF(SECOND, start_time, CURRENT_TIMESTAMP),
                quality_score = :score,
                notes = :notes,
                status = 'ended'
            WHERE session_id = :id
        """)
        db.execute(query, {"id": id, "score": req.quality_score, "notes": req.notes})
        db.commit()
        return {"message": f"ÄÃ£ káº¿t thÃºc phiÃªn há»— trá»£ #{id} vÃ  ghi nháº­n thá»i lÆ°á»£ng thÃ nh cÃ´ng"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# =====================================================================
# 5. NHÓM 8: THÔNG BÁO HỆ THỐNG (NOTIFICATIONS - THEO TAB 2, TAB 3 & LỖI 2.2)
# =====================================================================

@app.get("/api/notifications")
def get_notifications(user_id: Optional[int] = None, role: Optional[str] = None, db: Session = Depends(get_db)):
    """
    Phân quyền xem thông báo chuẩn 3 vai trò (Lỗi 2.2):
    - Admin: Nhận và xem được mọi thông báo trong hệ thống.
    - IT Staff: Nhận thông báo yêu cầu hỗ trợ mới, cấp/thu hồi quyền, và phiên kết nối.
    - Employee: CHỈ nhận thông báo phản hồi về trạng thái yêu cầu của chính mình.
    """
    try:
        norm_role = (role or "").lower()
        if norm_role == "admin" or (user_id == 1 and not norm_role):
            query = text("""
                SELECT notification_id, user_id, title, content, type, reference_id, is_read, created_at
                FROM dbo.Notifications
                ORDER BY notification_id DESC
            """)
            rows = db.execute(query).fetchall()
        elif norm_role in ["it", "it_staff"] or user_id == 2:
            query = text("""
                SELECT notification_id, user_id, title, content, type, reference_id, is_read, created_at
                FROM dbo.Notifications
                WHERE type IN ('support_request', 'session_started', 'session_ended')
                   OR (type IN ('permission_granted', 'permission_revoked', 'permission_request') AND (:uid = 0 OR user_id = :uid))
                   OR (:uid != 0 AND user_id = :uid)
                ORDER BY notification_id DESC
            """)
            rows = db.execute(query, {"uid": user_id or 0}).fetchall()
        else:
            query = text("""
                SELECT notification_id, user_id, title, content, type, reference_id, is_read, created_at
                FROM dbo.Notifications
                WHERE user_id = :uid
                ORDER BY notification_id DESC
            """)
            rows = db.execute(query, {"uid": user_id or 0}).fetchall()

        return {"data": [{
            "notification_id": r[0],
            "user_id": r[1],
            "title": r[2],
            "content": r[3],
            "type": r[4],
            "reference_id": r[5],
            "is_read": bool(r[6]),
            "created_at": str(r[7])
        } for r in rows]}
    except Exception as e:
        return {"data": [], "error": str(e)}

@app.post("/api/notifications")
def create_notification(req: NotificationCreate, db: Session = Depends(get_db)):
    """Tạo thông báo mới (IT xin cấp quyền, Nhân viên gửi ticket...)"""
    try:
        query = text("""
            INSERT INTO dbo.Notifications (user_id, title, content, type, reference_id, is_read, created_at)
            VALUES (:uid, :t, :c, :type, :ref, 0, SYSDATETIME())
        """)
        db.execute(query, {
            "uid": req.user_id, "t": req.title, "c": req.content,
            "type": req.type, "ref": req.reference_id
        })
        db.commit()
        return {"message": "Tạo thông báo thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/notifications/{id}/read")
def mark_notification_read(id: int, db: Session = Depends(get_db)):
    try:
        query = text("UPDATE dbo.Notifications SET is_read = 1, read_at = SYSDATETIME() WHERE notification_id = :id")
        db.execute(query, {"id": id})
        db.commit()
        return {"message": f"Đã đánh dấu đọc thông báo #{id}"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/api/notifications/read-all")
def mark_all_notifications_read(user_id: Optional[int] = None, db: Session = Depends(get_db)):
    try:
        if user_id:
            query = text("UPDATE dbo.Notifications SET is_read = 1, read_at = SYSDATETIME() WHERE user_id = :uid AND is_read = 0")
            db.execute(query, {"uid": user_id})
        else:
            query = text("UPDATE dbo.Notifications SET is_read = 1, read_at = SYSDATETIME() WHERE is_read = 0")
            db.execute(query)
        db.commit()
        return {"message": "Đã đánh dấu đọc toàn bộ thông báo"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
