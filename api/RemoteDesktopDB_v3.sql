/* RemoteDesktopDB_v3 v3 - MySQL 8.0+ / MySQL Workbench | Execute on a fresh database */
CREATE DATABASE IF NOT EXISTS `RemoteDesktopDB_v3`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE `RemoteDesktopDB_v3`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

/* Roles: configurable application roles */
CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    permissions JSON NOT NULL DEFAULT (JSON_ARRAY()),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT UQ_Roles_Name UNIQUE (name)
) ENGINE=InnoDB;

INSERT INTO Roles (name, description, permissions) VALUES
    ('admin', 'Quản trị', '["manage_users","manage_devices","manage_permissions"]'),
    ('it', 'Nhân viên IT', '["handle_support","remote_control"]'),
    ('user', 'Nhân viên', '["request_support"]'),
    ('manager', 'Quản lý', '["view_reports"]');

/* 00 Branches: Quản lý 3 Trụ sở A, B, C cho 20 nhân sự */
CREATE TABLE IF NOT EXISTS Branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL,
    address VARCHAR(255) NULL,
    ip_subnet VARCHAR(45) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT UQ_Branches_Code UNIQUE (code)
) ENGINE=InnoDB;

INSERT INTO Branches (name, code, address, ip_subnet) VALUES
    ('Trụ sở A - Hà Nội', 'BRANCH_A', 'Hà Nội', '10.13.13.0/24'),
    ('Trụ sở B - Đà Nẵng', 'BRANCH_B', 'Đà Nẵng', '10.13.14.0/24'),
    ('Trụ sở C - TP. Hồ Chí Minh', 'BRANCH_C', 'TP. Hồ Chí Minh', '10.13.15.0/24');

/* 01 Departments: manager FK is added after Users to resolve circular dependency */
CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    manager_id INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT UQ_Departments_Name UNIQUE (name)
) ENGINE=InnoDB;

/* 02 Users */
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NULL,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(254) NULL,
    phone VARCHAR(20) NULL,
    avatar_url VARCHAR(500) NULL,
    role_id INT NOT NULL DEFAULT 3,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    last_login DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT UQ_Users_Username UNIQUE (username),
    CONSTRAINT FK_Users_Departments FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (role_id) REFERENCES Roles(role_id),
    CONSTRAINT CK_Users_Status CHECK (status IN ('active','inactive','locked'))
) ENGINE=InnoDB;

ALTER TABLE Departments 
    ADD CONSTRAINT FK_Departments_Manager FOREIGN KEY (manager_id) REFERENCES Users(user_id);

CREATE UNIQUE INDEX UX_Users_Email ON Users(email);

/* 03 Devices */
CREATE TABLE Devices (
    device_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    department_id INT NULL,
    device_name VARCHAR(100) NOT NULL,
    rustdesk_id VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45) NULL,
    mac_address VARCHAR(17) NULL,
    device_type VARCHAR(20) NOT NULL DEFAULT 'desktop',
    os_name VARCHAR(80) NULL,
    os_version VARCHAR(80) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'offline',
    last_online DATETIME NULL,
    last_heartbeat DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT UQ_Devices_Rustdesk UNIQUE (rustdesk_id),
    CONSTRAINT FK_Devices_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Devices_Department FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    CONSTRAINT CK_Devices_Type CHECK (device_type IN ('desktop','laptop','server','other')),
    CONSTRAINT CK_Devices_Status CHECK (status IN ('online','offline','disabled'))
) ENGINE=InnoDB;

/* 04 Servers - metadata for managed HBBS/HBBR, not their internal data */
CREATE TABLE Servers (
    server_id INT AUTO_INCREMENT PRIMARY KEY,
    server_name VARCHAR(100) NOT NULL,
    server_type VARCHAR(10) NOT NULL,
    host VARCHAR(255) NOT NULL,
    port INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'unknown',
    last_heartbeat DATETIME NULL,
    cpu_usage DECIMAL(5,2) NULL,
    ram_usage DECIMAL(5,2) NULL,
    version VARCHAR(40) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT CK_Servers_Type CHECK (server_type IN ('HBBS','HBBR')),
    CONSTRAINT CK_Servers_Port CHECK (port BETWEEN 1 AND 65535),
    CONSTRAINT CK_Servers_Status CHECK (status IN ('online','offline','unknown')),
    CONSTRAINT CK_Servers_CPU CHECK (cpu_usage IS NULL OR cpu_usage BETWEEN 0 AND 100),
    CONSTRAINT CK_Servers_RAM CHECK (ram_usage IS NULL OR ram_usage BETWEEN 0 AND 100),
    CONSTRAINT UQ_Servers_Endpoint UNIQUE (server_type, host, port)
) ENGINE=InnoDB;

/* 05 SupportRequests: Employee -> IT helpdesk */
CREATE TABLE SupportRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    device_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    priority VARCHAR(10) NOT NULL DEFAULT 'normal',
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    assigned_it_id INT NULL,
    accepted_at DATETIME NULL,
    completed_at DATETIME NULL,
    rating TINYINT NULL,
    feedback TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT FK_Support_Employee FOREIGN KEY (employee_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Support_Device FOREIGN KEY (device_id) REFERENCES Devices(device_id),
    CONSTRAINT FK_Support_AssignedIT FOREIGN KEY (assigned_it_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Support_Priority CHECK (priority IN ('low','normal','high','urgent')),
    CONSTRAINT CK_Support_Status CHECK (status IN ('pending','accepted','in_progress','completed','rejected','cancelled')),
    CONSTRAINT CK_Support_Rating CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
    CONSTRAINT CK_Support_Times CHECK (completed_at IS NULL OR completed_at >= created_at)
) ENGINE=InnoDB;

/* 06 ConnectionRequests: IT device -> employee device */
CREATE TABLE ConnectionRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    support_request_id INT NULL,
    requester_id INT NOT NULL,
    source_device_id INT NOT NULL,
    target_device_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    message VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at DATETIME NULL,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT FK_Connection_Support FOREIGN KEY (support_request_id) REFERENCES SupportRequests(request_id),
    CONSTRAINT FK_Connection_Requester FOREIGN KEY (requester_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Connection_Source FOREIGN KEY (source_device_id) REFERENCES Devices(device_id),
    CONSTRAINT FK_Connection_Target FOREIGN KEY (target_device_id) REFERENCES Devices(device_id),
    CONSTRAINT CK_Connection_Status CHECK (status IN ('pending','accepted','rejected','cancelled','expired')),
    CONSTRAINT CK_Connection_DifferentDevices CHECK (source_device_id <> target_device_id)
) ENGINE=InnoDB;

/* 07 RemoteSessions */
CREATE TABLE RemoteSessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    it_user_id INT NOT NULL,
    target_user_id INT NOT NULL,
    source_device_id INT NOT NULL,
    target_device_id INT NOT NULL,
    server_id INT NULL,
    connection_type VARCHAR(10) NOT NULL DEFAULT 'direct',
    start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME NULL,
    duration_seconds INT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'started',
    quality_score TINYINT NULL,
    it_ip_address VARCHAR(45) NULL,
    notes TEXT NULL,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT FK_Session_Request FOREIGN KEY (request_id) REFERENCES ConnectionRequests(request_id),
    CONSTRAINT FK_Session_IT FOREIGN KEY (it_user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Session_TargetUser FOREIGN KEY (target_user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Session_Source FOREIGN KEY (source_device_id) REFERENCES Devices(device_id),
    CONSTRAINT FK_Session_Target FOREIGN KEY (target_device_id) REFERENCES Devices(device_id),
    CONSTRAINT FK_Session_Server FOREIGN KEY (server_id) REFERENCES Servers(server_id),
    CONSTRAINT CK_Session_Type CHECK (connection_type IN ('direct','relay')),
    CONSTRAINT CK_Session_Status CHECK (status IN ('started','ended','failed')),
    CONSTRAINT CK_Session_Quality CHECK (quality_score IS NULL OR quality_score BETWEEN 1 AND 5),
    CONSTRAINT CK_Session_Duration CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
    CONSTRAINT CK_Session_Times CHECK (end_time IS NULL OR end_time >= start_time),
    CONSTRAINT CK_Session_Relay CHECK (connection_type <> 'direct' OR server_id IS NULL)
) ENGINE=InnoDB;

/* 08 Permissions: one row per grant; history retained */
CREATE TABLE Permissions (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    device_id INT NOT NULL,
    permission_type VARCHAR(20) NOT NULL,
    granted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    granted_by INT NULL,
    expires_at DATETIME NULL,
    revoked_at DATETIME NULL,
    revoked_by INT NULL,
    notes TEXT NULL,
    status TINYINT(1) NOT NULL DEFAULT 1,
    deleted_at DATETIME NULL,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT FK_Permissions_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Permissions_Device FOREIGN KEY (device_id) REFERENCES Devices(device_id),
    CONSTRAINT FK_Permissions_GrantedBy FOREIGN KEY (granted_by) REFERENCES Users(user_id),
    CONSTRAINT FK_Permissions_RevokedBy FOREIGN KEY (revoked_by) REFERENCES Users(user_id),
    CONSTRAINT CK_Permissions_Type CHECK (permission_type IN ('view','control','file_transfer','full')),
    CONSTRAINT CK_Permissions_Expiry CHECK (expires_at IS NULL OR expires_at > granted_at),
    CONSTRAINT CK_Permissions_Revoked CHECK (revoked_at IS NULL OR revoked_at >= granted_at)
) ENGINE=InnoDB;

/* 09 Notifications: reference_id is polymorphic; cannot be a single FK */
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NULL,
    type VARCHAR(40) NOT NULL,
    reference_id INT NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME NULL,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT FK_Notifications_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Notifications_Type CHECK (type IN ('support_request','permission_granted','permission_revoked','session_started','session_ended','general'))
) ENGINE=InnoDB;

/* 10 ActivityLogs: target_type + target_id are polymorphic */
CREATE TABLE ActivityLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    device_id INT NULL,
    action VARCHAR(80) NOT NULL,
    description VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    target_type VARCHAR(30) NULL,
    target_id INT NULL,
    user_agent VARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'success',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Logs_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Logs_Device FOREIGN KEY (device_id) REFERENCES Devices(device_id),
    CONSTRAINT CK_Logs_Status CHECK (status IN ('success','failed'))
) ENGINE=InnoDB;

/* Settings: system configuration; do not store secrets in plaintext */
CREATE TABLE Settings (
    `key` VARCHAR(100) NOT NULL,
    `value` TEXT NOT NULL,
    description VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT PK_Settings PRIMARY KEY (`key`)
) ENGINE=InnoDB;

INSERT INTO Settings (`key`, `value`, description) VALUES
    ('session_timeout_minutes', '60', 'Thời gian phiên tối đa (phút)'),
    ('max_login_attempts', '5', 'Số lần đăng nhập sai tối đa'),
    ('default_permission_hours', '24', 'Thời hạn quyền mặc định (giờ)');

/* Useful query indexes */
CREATE INDEX IX_Users_Department ON Users(department_id);
CREATE INDEX IX_Devices_Department ON Devices(department_id);
CREATE INDEX IX_Devices_User ON Devices(user_id);
CREATE INDEX IX_Support_StatusPriority ON SupportRequests(status, priority, created_at);
CREATE INDEX IX_Support_Employee ON SupportRequests(employee_id, created_at);
CREATE INDEX IX_Support_AssignedIT ON SupportRequests(assigned_it_id, status);
CREATE INDEX IX_Connection_Support ON ConnectionRequests(support_request_id);
CREATE INDEX IX_Connection_TargetStatus ON ConnectionRequests(target_device_id, status);
CREATE INDEX IX_Session_Request ON RemoteSessions(request_id);
CREATE INDEX IX_Session_ITTime ON RemoteSessions(it_user_id, start_time);
CREATE INDEX IX_Session_TargetTime ON RemoteSessions(target_user_id, start_time);
CREATE INDEX IX_Session_Server ON RemoteSessions(server_id);
CREATE INDEX IX_Permissions_Active ON Permissions(user_id, device_id, expires_at);
CREATE INDEX IX_Permissions_Expires ON Permissions(expires_at);
CREATE INDEX IX_Notifications_Unread ON Notifications(user_id, is_read, created_at);
CREATE INDEX IX_Logs_UserTime ON ActivityLogs(user_id, created_at);
CREATE INDEX IX_Logs_Target ON ActivityLogs(target_type, target_id);

SET FOREIGN_KEY_CHECKS = 1;

/* Example: top departments requesting support */
SELECT d.name AS department_name, COUNT(*) AS support_count
FROM SupportRequests sr
JOIN Users u ON u.user_id = sr.employee_id
JOIN Departments d ON d.department_id = u.department_id
GROUP BY d.department_id, d.name
ORDER BY support_count DESC;

/* Lưu ý:
   1. Cột updated_at trong MySQL tự động cập nhật khi có lệnh UPDATE thông qua cú pháp:
      ON UPDATE CURRENT_TIMESTAMP (không cần dùng trigger AFTER UPDATE như bên SQL Server).
   2. UNIQUE index trên cột NULL (email) trong MySQL mặc định cho phép nhiều giá trị NULL theo chuẩn ANSI SQL.
   3. Cột permissions dùng kiểu dữ liệu JSON gốc của MySQL, tự động kiểm tra cú pháp JSON hợp lệ.
   4. Tên cột `key` trong bảng Settings được bọc trong dấu backticks (`) vì KEY là từ khóa dành riêng trong MySQL.
*/
