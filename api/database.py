import os
from urllib.parse import quote_plus

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# MySQL Server connection. Set DATABASE_URL when the server does not use
# the default local root account.
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    db_user = quote_plus(os.getenv("MYSQL_USER", "root"))
    db_password = quote_plus(os.getenv("MYSQL_PASSWORD", ""))
    db_host = os.getenv("MYSQL_HOST", "127.0.0.1")
    db_port = os.getenv("MYSQL_PORT", "3306")
    db_name = os.getenv("MYSQL_DATABASE", "RemoteDesktopDB_v3")
    DATABASE_URL = (
        f"mysql+pymysql://{db_user}:{db_password}"
        f"@{db_host}:{db_port}/{db_name}?charset=utf8mb4"
    )

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Hàm lấy Database Session cho mỗi API request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()