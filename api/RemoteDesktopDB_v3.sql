/* RemoteDesktopDB_v3 v3 - SQL Server 2019+ | Execute on a fresh database */
IF DB_ID(N'RemoteDesktopDB_v3') IS NULL EXEC(N'CREATE DATABASE RemoteDesktopDB_v3');
GO
USE RemoteDesktopDB_v3;
GO
/* Roles: configurable application roles */
CREATE TABLE dbo.Roles (
 role_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Roles PRIMARY KEY,
 name VARCHAR(50) NOT NULL CONSTRAINT UQ_Roles_Name UNIQUE,
 description NVARCHAR(255) NULL,
 permissions NVARCHAR(MAX) NOT NULL CONSTRAINT DF_Roles_Permissions DEFAULT N'[]',
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Roles_Created DEFAULT SYSDATETIME(),
 updated_at DATETIME2(0) NULL,
 deleted_at DATETIME2(0) NULL,
 CONSTRAINT CK_Roles_JSON CHECK (ISJSON(permissions) = 1)
);
GO
INSERT INTO dbo.Roles(name,description,permissions) VALUES
 ('admin',N'Quản trị',N'["manage_users","manage_devices","manage_permissions"]'),
 ('it',N'Nhân viên IT',N'["handle_support","remote_control"]'),
 ('user',N'Nhân viên',N'["request_support"]'),
 ('manager',N'Quản lý',N'["view_reports"]');
GO

/* 01 Departments: manager FK is added after Users to resolve circular dependency */
CREATE TABLE dbo.Departments (
 department_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Departments PRIMARY KEY,
 name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Departments_Name UNIQUE,
 description NVARCHAR(255) NULL,
 manager_id INT NULL,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Departments_Created DEFAULT SYSDATETIME(),
 updated_at DATETIME2(0) NULL,
 deleted_at DATETIME2(0) NULL
);
GO
/* 02 Users */
CREATE TABLE dbo.Users (
 user_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
 department_id INT NULL,
 username NVARCHAR(50) NOT NULL CONSTRAINT UQ_Users_Username UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 full_name NVARCHAR(100) NOT NULL,
 email VARCHAR(254) NULL,
 phone VARCHAR(20) NULL,
 avatar_url NVARCHAR(500) NULL,
 role_id INT NOT NULL CONSTRAINT DF_Users_RoleID DEFAULT 3,
 status VARCHAR(20) NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'active',
 last_login DATETIME2(0) NULL,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Users_Created DEFAULT SYSDATETIME(),
 updated_at DATETIME2(0) NULL,
 deleted_at DATETIME2(0) NULL,
 CONSTRAINT FK_Users_Departments FOREIGN KEY (department_id) REFERENCES dbo.Departments(department_id),
 CONSTRAINT FK_Users_Roles FOREIGN KEY (role_id) REFERENCES dbo.Roles(role_id),
 CONSTRAINT CK_Users_Status CHECK (status IN ('active','inactive','locked'))
);
GO
ALTER TABLE dbo.Departments ADD CONSTRAINT FK_Departments_Manager FOREIGN KEY (manager_id) REFERENCES dbo.Users(user_id);
GO
CREATE UNIQUE INDEX UX_Users_Email ON dbo.Users(email) WHERE email IS NOT NULL;
GO
/* 03 Devices */
CREATE TABLE dbo.Devices (
 device_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Devices PRIMARY KEY,
 user_id INT NOT NULL,
 department_id INT NULL,
 device_name NVARCHAR(100) NOT NULL,
 rustdesk_id VARCHAR(100) NOT NULL,
 ip_address VARCHAR(45) NULL,
 mac_address VARCHAR(17) NULL,
 device_type VARCHAR(20) NOT NULL CONSTRAINT DF_Devices_Type DEFAULT 'desktop',
 os_name NVARCHAR(80) NULL,
 os_version NVARCHAR(80) NULL,
 status VARCHAR(20) NOT NULL CONSTRAINT DF_Devices_Status DEFAULT 'offline',
 last_online DATETIME2(0) NULL,
 last_heartbeat DATETIME2(0) NULL,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Devices_Created DEFAULT SYSDATETIME(),
 updated_at DATETIME2(0) NULL,
 deleted_at DATETIME2(0) NULL,
 CONSTRAINT UQ_Devices_Rustdesk UNIQUE (rustdesk_id),
 CONSTRAINT FK_Devices_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Devices_Department FOREIGN KEY (department_id) REFERENCES dbo.Departments(department_id),
 CONSTRAINT CK_Devices_Type CHECK (device_type IN ('desktop','laptop','server','other')),
 CONSTRAINT CK_Devices_Status CHECK (status IN ('online','offline','disabled'))
);
GO
/* 04 Servers - metadata for managed HBBS/HBBR, not their internal data */
CREATE TABLE dbo.Servers (
 server_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Servers PRIMARY KEY,
 server_name NVARCHAR(100) NOT NULL,
 server_type VARCHAR(10) NOT NULL,
 host VARCHAR(255) NOT NULL,
 port INT NOT NULL,
 status VARCHAR(20) NOT NULL CONSTRAINT DF_Servers_Status DEFAULT 'unknown',
 last_heartbeat DATETIME2(0) NULL,
 cpu_usage DECIMAL(5,2) NULL,
 ram_usage DECIMAL(5,2) NULL,
 version VARCHAR(40) NULL,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Servers_Created DEFAULT SYSDATETIME(),
 updated_at DATETIME2(0) NULL,
 CONSTRAINT CK_Servers_Type CHECK (server_type IN ('HBBS','HBBR')),
 CONSTRAINT CK_Servers_Port CHECK (port BETWEEN 1 AND 65535),
 CONSTRAINT CK_Servers_Status CHECK (status IN ('online','offline','unknown')),
 CONSTRAINT CK_Servers_CPU CHECK (cpu_usage IS NULL OR cpu_usage BETWEEN 0 AND 100),
 CONSTRAINT CK_Servers_RAM CHECK (ram_usage IS NULL OR ram_usage BETWEEN 0 AND 100),
 CONSTRAINT UQ_Servers_Endpoint UNIQUE (server_type,host,port)
);
GO
/* 05 SupportRequests: Employee -> IT helpdesk */
CREATE TABLE dbo.SupportRequests (
 request_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SupportRequests PRIMARY KEY,
 employee_id INT NOT NULL,
 device_id INT NOT NULL,
 title NVARCHAR(200) NOT NULL,
 description NVARCHAR(MAX) NULL,
 priority VARCHAR(10) NOT NULL CONSTRAINT DF_Support_Priority DEFAULT 'normal',
 status VARCHAR(20) NOT NULL CONSTRAINT DF_Support_Status DEFAULT 'pending',
 assigned_it_id INT NULL,
 accepted_at DATETIME2(0) NULL,
 completed_at DATETIME2(0) NULL,
 rating TINYINT NULL,
 feedback NVARCHAR(MAX) NULL,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Support_Created DEFAULT SYSDATETIME(),
 updated_at DATETIME2(0) NULL,
 CONSTRAINT FK_Support_Employee FOREIGN KEY (employee_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Support_Device FOREIGN KEY (device_id) REFERENCES dbo.Devices(device_id),
 CONSTRAINT FK_Support_AssignedIT FOREIGN KEY (assigned_it_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT CK_Support_Priority CHECK (priority IN ('low','normal','high','urgent')),
 CONSTRAINT CK_Support_Status CHECK (status IN ('pending','accepted','in_progress','completed','rejected','cancelled')),
 CONSTRAINT CK_Support_Rating CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
 CONSTRAINT CK_Support_Times CHECK (completed_at IS NULL OR completed_at >= created_at)
);
GO
/* 06 ConnectionRequests: IT device -> employee device */
CREATE TABLE dbo.ConnectionRequests (
 request_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ConnectionRequests PRIMARY KEY,
 support_request_id INT NULL,
 requester_id INT NOT NULL,
 source_device_id INT NOT NULL,
 target_device_id INT NOT NULL,
 status VARCHAR(20) NOT NULL CONSTRAINT DF_Connection_Status DEFAULT 'pending',
 message NVARCHAR(255) NULL,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Connection_Created DEFAULT SYSDATETIME(),
 responded_at DATETIME2(0) NULL,
 updated_at DATETIME2(0) NULL,
 deleted_at DATETIME2(0) NULL,
 CONSTRAINT FK_Connection_Support FOREIGN KEY (support_request_id) REFERENCES dbo.SupportRequests(request_id),
 CONSTRAINT FK_Connection_Requester FOREIGN KEY (requester_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Connection_Source FOREIGN KEY (source_device_id) REFERENCES dbo.Devices(device_id),
 CONSTRAINT FK_Connection_Target FOREIGN KEY (target_device_id) REFERENCES dbo.Devices(device_id),
 CONSTRAINT CK_Connection_Status CHECK (status IN ('pending','accepted','rejected','cancelled','expired')),
 CONSTRAINT CK_Connection_DifferentDevices CHECK (source_device_id <> target_device_id)
);
GO
/* 07 RemoteSessions */
CREATE TABLE dbo.RemoteSessions (
 session_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_RemoteSessions PRIMARY KEY,
 request_id INT NOT NULL,
 it_user_id INT NOT NULL,
 target_user_id INT NOT NULL,
 source_device_id INT NOT NULL,
 target_device_id INT NOT NULL,
 server_id INT NULL,
 connection_type VARCHAR(10) NOT NULL CONSTRAINT DF_Session_Type DEFAULT 'direct',
 start_time DATETIME2(0) NOT NULL CONSTRAINT DF_Session_Start DEFAULT SYSDATETIME(),
 end_time DATETIME2(0) NULL,
 duration_seconds INT NULL,
 status VARCHAR(20) NOT NULL CONSTRAINT DF_Session_Status DEFAULT 'started',
 quality_score TINYINT NULL,
 it_ip_address VARCHAR(45) NULL,
 notes NVARCHAR(MAX) NULL,
 updated_at DATETIME2(0) NULL,
 deleted_at DATETIME2(0) NULL,
 CONSTRAINT FK_Session_Request FOREIGN KEY (request_id) REFERENCES dbo.ConnectionRequests(request_id),
 CONSTRAINT FK_Session_IT FOREIGN KEY (it_user_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Session_TargetUser FOREIGN KEY (target_user_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Session_Source FOREIGN KEY (source_device_id) REFERENCES dbo.Devices(device_id),
 CONSTRAINT FK_Session_Target FOREIGN KEY (target_device_id) REFERENCES dbo.Devices(device_id),
 CONSTRAINT FK_Session_Server FOREIGN KEY (server_id) REFERENCES dbo.Servers(server_id),
 CONSTRAINT CK_Session_Type CHECK (connection_type IN ('direct','relay')),
 CONSTRAINT CK_Session_Status CHECK (status IN ('started','ended','failed')),
 CONSTRAINT CK_Session_Quality CHECK (quality_score IS NULL OR quality_score BETWEEN 1 AND 5),
 CONSTRAINT CK_Session_Duration CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
 CONSTRAINT CK_Session_Times CHECK (end_time IS NULL OR end_time >= start_time),
 CONSTRAINT CK_Session_Relay CHECK (connection_type <> 'direct' OR server_id IS NULL)
);
GO
/* 08 Permissions: one row per grant; history retained */
CREATE TABLE dbo.Permissions (
 permission_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Permissions PRIMARY KEY,
 user_id INT NOT NULL,
 device_id INT NOT NULL,
 permission_type VARCHAR(20) NOT NULL,
 granted_at DATETIME2(0) NOT NULL CONSTRAINT DF_Permissions_Granted DEFAULT SYSDATETIME(),
 granted_by INT NULL,
 expires_at DATETIME2(0) NULL,
 revoked_at DATETIME2(0) NULL,
 revoked_by INT NULL,
 notes NVARCHAR(MAX) NULL,
 status BIT NOT NULL CONSTRAINT DF_Permissions_Status DEFAULT 1,
 deleted_at DATETIME2(0) NULL,
 updated_at DATETIME2(0) NULL,
 CONSTRAINT FK_Permissions_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Permissions_Device FOREIGN KEY (device_id) REFERENCES dbo.Devices(device_id),
 CONSTRAINT FK_Permissions_GrantedBy FOREIGN KEY (granted_by) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Permissions_RevokedBy FOREIGN KEY (revoked_by) REFERENCES dbo.Users(user_id),
 CONSTRAINT CK_Permissions_Type CHECK (permission_type IN ('view','control','file_transfer','full')),
 CONSTRAINT CK_Permissions_Expiry CHECK (expires_at IS NULL OR expires_at > granted_at),
 CONSTRAINT CK_Permissions_Revoked CHECK (revoked_at IS NULL OR revoked_at >= granted_at)
);
GO
/* 09 Notifications: reference_id is polymorphic; cannot be a single FK */
CREATE TABLE dbo.Notifications (
 notification_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Notifications PRIMARY KEY,
 user_id INT NOT NULL,
 title NVARCHAR(200) NOT NULL,
 content NVARCHAR(MAX) NULL,
 type VARCHAR(40) NOT NULL,
 reference_id INT NULL,
 is_read BIT NOT NULL CONSTRAINT DF_Notifications_Read DEFAULT 0,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Notifications_Created DEFAULT SYSDATETIME(),
 read_at DATETIME2(0) NULL,
 updated_at DATETIME2(0) NULL,
 deleted_at DATETIME2(0) NULL,
 CONSTRAINT FK_Notifications_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT CK_Notifications_Type CHECK (type IN ('support_request','permission_granted','permission_revoked','session_started','session_ended','general'))
);
GO
/* 10 ActivityLogs: target_type + target_id are polymorphic */
CREATE TABLE dbo.ActivityLogs (
 log_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ActivityLogs PRIMARY KEY,
 user_id INT NOT NULL,
 device_id INT NULL,
 action VARCHAR(80) NOT NULL,
 description NVARCHAR(500) NULL,
 ip_address VARCHAR(45) NULL,
 target_type VARCHAR(30) NULL,
 target_id INT NULL,
 user_agent NVARCHAR(255) NULL,
 status VARCHAR(20) NOT NULL CONSTRAINT DF_Logs_Status DEFAULT 'success',
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Logs_Created DEFAULT SYSDATETIME(),
 CONSTRAINT FK_Logs_User FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
 CONSTRAINT FK_Logs_Device FOREIGN KEY (device_id) REFERENCES dbo.Devices(device_id),
 CONSTRAINT CK_Logs_Status CHECK (status IN ('success','failed'))
);
GO
/* Settings: system configuration; do not store secrets in plaintext */
CREATE TABLE dbo.Settings (
 [key] VARCHAR(100) NOT NULL CONSTRAINT PK_Settings PRIMARY KEY,
 [value] NVARCHAR(MAX) NOT NULL,
 description NVARCHAR(255) NULL,
 created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Settings_Created DEFAULT SYSDATETIME(),
 updated_at DATETIME2(0) NULL
);
GO
INSERT INTO dbo.Settings([key],[value],description) VALUES
 ('session_timeout_minutes',N'60',N'Thời gian phiên tối đa (phút)'),
 ('max_login_attempts',N'5',N'Số lần đăng nhập sai tối đa'),
 ('default_permission_hours',N'24',N'Thời hạn quyền mặc định (giờ)');
GO

/* Useful query indexes */
CREATE INDEX IX_Users_Department ON dbo.Users(department_id);
CREATE INDEX IX_Devices_Department ON dbo.Devices(department_id);
CREATE INDEX IX_Devices_User ON dbo.Devices(user_id);
CREATE INDEX IX_Support_StatusPriority ON dbo.SupportRequests(status,priority,created_at);
CREATE INDEX IX_Support_Employee ON dbo.SupportRequests(employee_id,created_at);
CREATE INDEX IX_Support_AssignedIT ON dbo.SupportRequests(assigned_it_id,status);
CREATE INDEX IX_Connection_Support ON dbo.ConnectionRequests(support_request_id);
CREATE INDEX IX_Connection_TargetStatus ON dbo.ConnectionRequests(target_device_id,status);
CREATE INDEX IX_Session_Request ON dbo.RemoteSessions(request_id);
CREATE INDEX IX_Session_ITTime ON dbo.RemoteSessions(it_user_id,start_time);
CREATE INDEX IX_Session_TargetTime ON dbo.RemoteSessions(target_user_id,start_time);
CREATE INDEX IX_Session_Server ON dbo.RemoteSessions(server_id);
CREATE INDEX IX_Permissions_Active ON dbo.Permissions(user_id,device_id,expires_at) WHERE status = 1 AND deleted_at IS NULL;
CREATE INDEX IX_Permissions_Expires ON dbo.Permissions(expires_at);
CREATE INDEX IX_Notifications_Unread ON dbo.Notifications(user_id,is_read,created_at);
CREATE INDEX IX_Logs_UserTime ON dbo.ActivityLogs(user_id,created_at);
CREATE INDEX IX_Logs_Target ON dbo.ActivityLogs(target_type,target_id);
GO
/* Example: top departments requesting support */
SELECT d.name AS department_name, COUNT(*) AS support_count
FROM dbo.SupportRequests sr
JOIN dbo.Users u ON u.user_id = sr.employee_id
JOIN dbo.Departments d ON d.department_id = u.department_id
GROUP BY d.department_id,d.name
ORDER BY support_count DESC;
GO
/* Updated_at is set by application UPDATE statements; SQL Server has no MySQL ON UPDATE syntax.
   Permission check must validate status=1, deleted_at IS NULL, revoked_at IS NULL,
   and (expires_at IS NULL OR expires_at > SYSDATETIME()).
   Application/service must validate role and department authorization, matching session
   participants to the accepted connection request, and valid workflow transitions.
   Passwords: store strong salted password hashes, never plaintext or remote access passwords.
*/


/* Automatic updated_at maintenance on UPDATE (SQL Server AFTER UPDATE triggers). */
CREATE TRIGGER dbo.TR_Roles_UpdatedAt ON dbo.Roles
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Roles AS target
 INNER JOIN inserted AS i ON target.[role_id] = i.[role_id];
END;
GO
CREATE TRIGGER dbo.TR_Departments_UpdatedAt ON dbo.Departments
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Departments AS target
 INNER JOIN inserted AS i ON target.[department_id] = i.[department_id];
END;
GO
CREATE TRIGGER dbo.TR_Users_UpdatedAt ON dbo.Users
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Users AS target
 INNER JOIN inserted AS i ON target.[user_id] = i.[user_id];
END;
GO
CREATE TRIGGER dbo.TR_Devices_UpdatedAt ON dbo.Devices
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Devices AS target
 INNER JOIN inserted AS i ON target.[device_id] = i.[device_id];
END;
GO
CREATE TRIGGER dbo.TR_Servers_UpdatedAt ON dbo.Servers
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Servers AS target
 INNER JOIN inserted AS i ON target.[server_id] = i.[server_id];
END;
GO
CREATE TRIGGER dbo.TR_SupportRequests_UpdatedAt ON dbo.SupportRequests
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.SupportRequests AS target
 INNER JOIN inserted AS i ON target.[request_id] = i.[request_id];
END;
GO
CREATE TRIGGER dbo.TR_ConnectionRequests_UpdatedAt ON dbo.ConnectionRequests
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.ConnectionRequests AS target
 INNER JOIN inserted AS i ON target.[request_id] = i.[request_id];
END;
GO
CREATE TRIGGER dbo.TR_RemoteSessions_UpdatedAt ON dbo.RemoteSessions
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.RemoteSessions AS target
 INNER JOIN inserted AS i ON target.[session_id] = i.[session_id];
END;
GO
CREATE TRIGGER dbo.TR_Permissions_UpdatedAt ON dbo.Permissions
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Permissions AS target
 INNER JOIN inserted AS i ON target.[permission_id] = i.[permission_id];
END;
GO
CREATE TRIGGER dbo.TR_Notifications_UpdatedAt ON dbo.Notifications
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Notifications AS target
 INNER JOIN inserted AS i ON target.[notification_id] = i.[notification_id];
END;
GO
CREATE TRIGGER dbo.TR_Settings_UpdatedAt ON dbo.Settings
AFTER UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF TRIGGER_NESTLEVEL() > 1 RETURN;
 UPDATE target SET updated_at = SYSDATETIME()
 FROM dbo.Settings AS target
 INNER JOIN inserted AS i ON target.[key] = i.[key];
END;
GO
