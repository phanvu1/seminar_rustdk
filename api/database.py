from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Chuỗi kết nối SQL Server (Thay đổi Server, Username, Password cho khớp với máy bạn)
# Sử dụng Windows Authentication: trusted_connection=yes
DATABASE_URL = "mssql+pyodbc://@LAPTOP-766DU13D/RemoteDesktopDB_v3?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Hàm lấy Database Session cho mỗi API request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()