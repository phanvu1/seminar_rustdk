-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: RemoteDesktopDB_v3
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ActivityLogs`
--

DROP TABLE IF EXISTS `ActivityLogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ActivityLogs` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `device_id` int DEFAULT NULL,
  `action` varchar(80) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `target_type` varchar(30) DEFAULT NULL,
  `target_id` int DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'success',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `FK_Logs_Device` (`device_id`),
  KEY `IX_Logs_UserTime` (`user_id`,`created_at`),
  KEY `IX_Logs_Target` (`target_type`,`target_id`),
  CONSTRAINT `FK_Logs_Device` FOREIGN KEY (`device_id`) REFERENCES `Devices` (`device_id`),
  CONSTRAINT `FK_Logs_User` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `CK_Logs_Status` CHECK ((`status` in (_utf8mb4'success',_utf8mb4'failed')))
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ActivityLogs`
--

LOCK TABLES `ActivityLogs` WRITE;
/*!40000 ALTER TABLE `ActivityLogs` DISABLE KEYS */;
INSERT INTO `ActivityLogs` VALUES (1,1,2,'LOGIN','Quản trị viên đăng nhập hệ thống Dashboard Vynex Manager','10.13.13.2','AUTH',NULL,NULL,'success','2026-11-23 04:42:53'),(3,1,2,'GRANT_PERMISSION','Admin cấp quyền điều khiển máy Mai (Ubuntu Linux) cho IT Gia Bảo','10.13.13.2','PERMISSION',NULL,NULL,'success','2026-11-23 05:12:53'),(9,1,2,'UPDATE_DEVICE','Admin cập nhật hệ điều hành Ubuntu Linux 24.04 LTS cho máy Mai','10.13.13.2','DEVICE',NULL,NULL,'success','2026-11-23 06:32:53'),(17,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-23 15:01:10'),(18,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-23 15:13:02'),(21,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-23 15:22:05'),(25,1,17,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy Mai cho IT #18','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-23 17:09:58'),(27,1,2,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy PC-IT-ADMIN (Host Windows) cho IT #20','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 05:00:46'),(28,1,2,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy PC-IT-ADMIN (Host Windows) cho IT #20','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 05:00:50'),(29,1,2,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy PC-IT-ADMIN (Host Windows) cho IT #20','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 05:01:08'),(30,1,2,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy PC-IT-ADMIN (Host Windows) cho IT #20','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 05:01:50'),(31,1,2,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy PC-IT-ADMIN (Host Windows) cho IT #20','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 05:02:00'),(32,1,17,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy Mai cho IT #18','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 07:20:44'),(33,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 07:22:21'),(34,1,17,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy Mai cho IT #18','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 07:22:24'),(37,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 07:25:35'),(38,1,17,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy Mai cho IT #18','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 07:25:35'),(41,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 11:03:35'),(42,23,NULL,'LOGIN','Người dùng @dat (Nguyễn Thành Đạt) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 11:04:14'),(43,23,NULL,'LOGIN','Người dùng @dat (Nguyễn Thành Đạt) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 15:19:09'),(44,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 15:25:13'),(45,1,19,'PERMISSION_REJECTED','Admin từ chối cấp quyền điều khiển máy Mai cho IT #23','127.0.0.1','PERMISSION',NULL,NULL,'success','2026-11-24 15:47:40'),(46,24,NULL,'LOGIN','Người dùng @mai (Phạm Thị Mai) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 16:45:39'),(47,25,NULL,'LOGIN','Người dùng @vu (Vũ) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 16:53:29'),(48,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 17:05:34'),(49,25,NULL,'LOGIN','Người dùng @vu (Vũ) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 17:05:45'),(50,1,NULL,'LOGIN','Người dùng @admin (Nguyễn Văn An (Admin)) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 17:08:57'),(51,25,NULL,'LOGIN','Người dùng @vu (Vũ) đăng nhập thành công','127.0.0.1','USER',NULL,NULL,'success','2026-11-24 17:09:17');
/*!40000 ALTER TABLE `ActivityLogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Branches`
--

DROP TABLE IF EXISTS `Branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Branches` (
  `branch_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `code` varchar(20) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `ip_subnet` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`branch_id`),
  UNIQUE KEY `UQ_Branches_Code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Branches`
--

LOCK TABLES `Branches` WRITE;
/*!40000 ALTER TABLE `Branches` DISABLE KEYS */;
INSERT INTO `Branches` VALUES (1,'Trụ sở A - Hà Nội','BRANCH_A','Hà Nội','10.13.13.0/24','2026-11-12 15:37:47'),(2,'Trụ sở B - Đà Nẵng','BRANCH_B','Đà Nẵng','10.13.14.0/24','2026-11-12 15:37:47'),(3,'Trụ sở C - TP. Hồ Chí Minh','BRANCH_C','TP. Hồ Chí Minh','10.13.15.0/24','2026-11-12 15:37:47');
/*!40000 ALTER TABLE `Branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ConnectionRequests`
--

DROP TABLE IF EXISTS `ConnectionRequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ConnectionRequests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `support_request_id` int DEFAULT NULL,
  `requester_id` int NOT NULL,
  `source_device_id` int NOT NULL,
  `target_device_id` int NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `message` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responded_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `FK_Connection_Requester` (`requester_id`),
  KEY `FK_Connection_Source` (`source_device_id`),
  KEY `IX_Connection_Support` (`support_request_id`),
  KEY `IX_Connection_TargetStatus` (`target_device_id`,`status`),
  CONSTRAINT `FK_Connection_Requester` FOREIGN KEY (`requester_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `FK_Connection_Source` FOREIGN KEY (`source_device_id`) REFERENCES `Devices` (`device_id`),
  CONSTRAINT `FK_Connection_Support` FOREIGN KEY (`support_request_id`) REFERENCES `SupportRequests` (`request_id`),
  CONSTRAINT `FK_Connection_Target` FOREIGN KEY (`target_device_id`) REFERENCES `Devices` (`device_id`),
  CONSTRAINT `CK_Connection_DifferentDevices` CHECK ((`source_device_id` <> `target_device_id`)),
  CONSTRAINT `CK_Connection_Status` CHECK ((`status` in (_utf8mb4'pending',_utf8mb4'accepted',_utf8mb4'rejected',_utf8mb4'cancelled',_utf8mb4'expired')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ConnectionRequests`
--

LOCK TABLES `ConnectionRequests` WRITE;
/*!40000 ALTER TABLE `ConnectionRequests` DISABLE KEYS */;
/*!40000 ALTER TABLE `ConnectionRequests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Departments`
--

DROP TABLE IF EXISTS `Departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Departments` (
  `department_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `UQ_Departments_Name` (`name`),
  KEY `FK_Departments_Manager` (`manager_id`),
  CONSTRAINT `FK_Departments_Manager` FOREIGN KEY (`manager_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Departments`
--

LOCK TABLES `Departments` WRITE;
/*!40000 ALTER TABLE `Departments` DISABLE KEYS */;
INSERT INTO `Departments` VALUES (1,'Phòng Kỹ thuật & CNTT','Quản trị hạ tầng mạng, máy chủ và hỗ trợ kỹ thuật',1,'2026-11-12 16:33:43','2026-11-20 15:56:42',NULL),(2,'Phòng Kế toán - Tài chính','Quản lý thu chi, hóa đơn điện tử và kiểm toán',NULL,'2026-11-12 16:33:43','2026-11-17 09:33:49',NULL),(3,'Phòng Kinh doanh & Tiếp thị','Bán hàng, phát triển đối tác và Marketing',NULL,'2026-11-23 15:04:03',NULL,NULL);
/*!40000 ALTER TABLE `Departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Devices`
--

DROP TABLE IF EXISTS `Devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Devices` (
  `device_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `department_id` int DEFAULT NULL,
  `device_name` varchar(100) NOT NULL,
  `rustdesk_id` varchar(100) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `mac_address` varchar(17) DEFAULT NULL,
  `device_type` varchar(20) NOT NULL DEFAULT 'desktop',
  `os_name` varchar(80) DEFAULT NULL,
  `os_version` varchar(80) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'offline',
  `last_online` datetime DEFAULT NULL,
  `last_heartbeat` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`device_id`),
  UNIQUE KEY `UQ_Devices_Rustdesk` (`rustdesk_id`),
  KEY `IX_Devices_Department` (`department_id`),
  KEY `IX_Devices_User` (`user_id`),
  CONSTRAINT `FK_Devices_Department` FOREIGN KEY (`department_id`) REFERENCES `Departments` (`department_id`),
  CONSTRAINT `FK_Devices_User` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `CK_Devices_Status` CHECK ((`status` in (_utf8mb4'online',_utf8mb4'offline',_utf8mb4'disabled'))),
  CONSTRAINT `CK_Devices_Type` CHECK ((`device_type` in (_utf8mb4'desktop',_utf8mb4'laptop',_utf8mb4'server',_utf8mb4'other')))
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Devices`
--

LOCK TABLES `Devices` WRITE;
/*!40000 ALTER TABLE `Devices` DISABLE KEYS */;
INSERT INTO `Devices` VALUES (2,25,1,'Vuz','1 848 383 706','10.13.13.2',NULL,'laptop','Windows 11 Pro',NULL,'offline','2026-11-24 11:01:54',NULL,'2026-11-12 16:33:43','2026-11-24 17:17:08',NULL),(18,23,1,'Máy của Đạt IT','438382440','10.13.13.7',NULL,'laptop','Windows 11 Pro',NULL,'offline','2026-11-24 21:11:28',NULL,'2026-11-24 09:53:34','2026-11-24 21:14:27',NULL),(19,24,2,'Mai','158939949','10.13.13.3',NULL,'laptop','Ubuntu Linux 24.04 LTS',NULL,'offline','2026-11-24 15:47:15',NULL,'2026-11-24 15:47:15','2026-11-24 17:17:09',NULL);
/*!40000 ALTER TABLE `Devices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Notifications`
--

DROP TABLE IF EXISTS `Notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` text,
  `type` varchar(40) NOT NULL,
  `reference_id` int DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `read_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`notification_id`),
  KEY `IX_Notifications_Unread` (`user_id`,`is_read`,`created_at`),
  CONSTRAINT `FK_Notifications_User` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Notifications`
--

LOCK TABLES `Notifications` WRITE;
/*!40000 ALTER TABLE `Notifications` DISABLE KEYS */;
INSERT INTO `Notifications` VALUES (66,1,'IT Nguyễn Thành Đạt yêu cầu cấp quyền máy Mai','[REQ:it_id=23,dev_id=19] IT Nguyễn Thành Đạt yêu cầu cấp quyền điều khiển máy Mai (ID: 158939949). Lý do: Yêu cầu quyền điều khiển từ xa thiết bị Mai','permission_request',19,1,'2026-11-24 15:47:32','2026-11-24 15:47:40','2026-11-24 15:47:40',NULL),(67,23,'Yêu cầu quyền máy Mai bị từ chối','Admin đã từ chối yêu cầu cấp quyền điều khiển máy Mai. Lý do: Admin từ chối yêu cầu kết nối thiết bị Mai','permission_rejected',19,0,'2026-11-24 15:47:40',NULL,NULL,NULL),(68,1,'IT Nguyễn Thành Đạt yêu cầu cấp quyền máy Mai','[REQ:it_id=23,dev_id=19] IT Nguyễn Thành Đạt yêu cầu cấp quyền điều khiển máy Mai (ID: 158939949). Lý do: Yêu cầu quyền điều khiển từ xa thiết bị Mai','permission_request',19,1,'2026-11-24 15:47:44','2026-11-24 15:47:49','2026-11-24 15:47:49',NULL),(69,23,'Admin đã cấp quyền máy Mai','Bạn đã được cấp quyền \'control\' thời hạn 24h trên máy Mai.','permission_granted',19,0,'2026-11-24 15:47:47',NULL,NULL,NULL),(70,23,'Quyền điều khiển máy #19 đã bị thu hồi','Admin đã thu hồi quyền truy cập thiết bị #19.','permission_revoked',19,0,'2026-11-24 15:52:00',NULL,NULL,NULL),(71,1,'IT Nguyễn Thành Đạt yêu cầu cấp quyền máy Mai','[REQ:it_id=23,dev_id=19] IT Nguyễn Thành Đạt yêu cầu cấp quyền điều khiển máy Mai (ID: 158939949). Lý do: Yêu cầu quyền điều khiển máy Mai','permission_request',19,1,'2026-11-24 15:52:06','2026-11-24 15:52:15','2026-11-24 15:52:15',NULL),(72,23,'Admin đã cấp quyền máy Mai','Bạn đã được cấp quyền \'control\' thời hạn 24h trên máy Mai.','permission_granted',19,0,'2026-11-24 15:52:12',NULL,NULL,NULL),(73,23,'Quyền điều khiển máy #19 đã bị thu hồi','Admin đã thu hồi quyền truy cập thiết bị #19.','permission_revoked',19,0,'2026-11-24 16:46:43',NULL,NULL,NULL),(74,1,'Yêu cầu hỗ trợ mới #: asdf','Nhân viên ID #24 đã gửi yêu cầu: \"asdf\"','support_request',0,0,'2026-11-24 16:55:09',NULL,NULL,NULL),(75,23,'Yêu cầu hỗ trợ mới #: asdf','Nhân viên ID #24 đã gửi yêu cầu: \"asdf\"','support_request',0,0,'2026-11-24 16:55:09',NULL,NULL,NULL),(76,25,'Yêu cầu hỗ trợ mới #: asdf','Nhân viên ID #24 đã gửi yêu cầu: \"asdf\"','support_request',0,0,'2026-11-24 16:55:09',NULL,NULL,NULL),(77,24,'Yêu cầu #5 bị từ chối','Kỹ thuật viên IT đã từ chối yêu cầu \"asdf\". Lý do: Không thuộc phạm vi hỗ trợ','support_request',5,0,'2026-11-24 16:55:23',NULL,NULL,NULL),(78,1,'Yêu cầu hỗ trợ mới #: dd','Nhân viên ID #24 đã gửi yêu cầu: \"dd\"','support_request',0,0,'2026-11-24 16:57:57',NULL,NULL,NULL),(79,23,'Yêu cầu hỗ trợ mới #: dd','Nhân viên ID #24 đã gửi yêu cầu: \"dd\"','support_request',0,0,'2026-11-24 16:57:57',NULL,NULL,NULL),(80,25,'Yêu cầu hỗ trợ mới #: dd','Nhân viên ID #24 đã gửi yêu cầu: \"dd\"','support_request',0,0,'2026-11-24 16:57:57',NULL,NULL,NULL),(81,24,'Yêu cầu #6 bị từ chối','Kỹ thuật viên IT đã từ chối yêu cầu \"dd\". Lý do: Không thuộc phạm vi hỗ trợ','support_request',6,0,'2026-11-24 16:58:04',NULL,NULL,NULL),(82,1,'Yêu cầu hỗ trợ mới #: gg','Nhân viên ID #24 đã gửi yêu cầu: \"gg\"','support_request',0,0,'2026-11-24 17:05:10',NULL,NULL,NULL),(83,23,'Yêu cầu hỗ trợ mới #: gg','Nhân viên ID #24 đã gửi yêu cầu: \"gg\"','support_request',0,0,'2026-11-24 17:05:10',NULL,NULL,NULL),(84,25,'Yêu cầu hỗ trợ mới #: gg','Nhân viên ID #24 đã gửi yêu cầu: \"gg\"','support_request',0,0,'2026-11-24 17:05:10',NULL,NULL,NULL),(85,24,'Yêu cầu #7 đã được tiếp nhận','Kỹ thuật viên IT đã tiếp nhận xử lý sự cố \"gg\".','support_request',7,0,'2026-11-24 17:05:22',NULL,NULL,NULL),(86,1,'IT Vũ yêu cầu cấp quyền máy Mai','[REQ:it_id=25,dev_id=19] IT Vũ yêu cầu cấp quyền điều khiển máy Mai (ID: 158939949) cho Ticket #7. Lý do: Xử lý sự cố ticket #7: gg','permission_request',7,0,'2026-11-24 17:05:25',NULL,NULL,NULL),(87,25,'Admin đã cấp quyền máy Mai','Bạn đã được cấp quyền \'control\' thời hạn 24h trên máy Mai.','permission_granted',19,0,'2026-11-24 17:05:39',NULL,NULL,NULL),(88,1,'IT Vũ yêu cầu cấp quyền máy Máy của Đạt IT','[REQ:it_id=25,dev_id=18] IT Vũ yêu cầu cấp quyền điều khiển máy Máy của Đạt IT (ID: 438382440). Lý do: Yêu cầu quyền truyền tệp tới máy Máy của Đạt IT (Vynex ID: 438382440)','permission_request',18,1,'2026-11-24 17:08:50','2026-11-24 17:09:10','2026-11-24 17:09:10',NULL),(89,25,'Admin đã cấp quyền máy Máy của Đạt IT','Bạn đã được cấp quyền \'control\' thời hạn 24h trên máy Máy của Đạt IT.','permission_granted',18,0,'2026-11-24 17:09:07',NULL,NULL,NULL),(90,1,'Yêu cầu hỗ trợ mới #8: Test Ticket Decline','Nhân viên ID #24 đã gửi yêu cầu: \"Test Ticket Decline\"','support_request',8,0,'2026-11-25 03:14:22',NULL,NULL,NULL),(91,23,'Yêu cầu hỗ trợ mới #8: Test Ticket Decline','Nhân viên ID #24 đã gửi yêu cầu: \"Test Ticket Decline\"','support_request',8,0,'2026-11-25 03:14:22',NULL,NULL,NULL),(92,25,'Yêu cầu hỗ trợ mới #8: Test Ticket Decline','Nhân viên ID #24 đã gửi yêu cầu: \"Test Ticket Decline\"','support_request',8,0,'2026-11-25 03:14:22',NULL,NULL,NULL),(93,24,'Yêu cầu #8 bị từ chối','Quản trị viên đã từ chối yêu cầu \"Test Ticket Decline\". Lý do: Không thể xử lý','support_request',8,0,'2026-11-25 03:14:22',NULL,NULL,NULL),(94,1,'Yêu cầu hỗ trợ mới #9: Test Ticket Decline','Nhân viên ID #24 đã gửi yêu cầu: \"Test Ticket Decline\"','support_request',9,0,'2026-11-25 03:16:31',NULL,NULL,NULL),(95,23,'Yêu cầu hỗ trợ mới #9: Test Ticket Decline','Nhân viên ID #24 đã gửi yêu cầu: \"Test Ticket Decline\"','support_request',9,0,'2026-11-25 03:16:31',NULL,NULL,NULL),(96,25,'Yêu cầu hỗ trợ mới #9: Test Ticket Decline','Nhân viên ID #24 đã gửi yêu cầu: \"Test Ticket Decline\"','support_request',9,0,'2026-11-25 03:16:31',NULL,NULL,NULL);
/*!40000 ALTER TABLE `Notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Permissions`
--

DROP TABLE IF EXISTS `Permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Permissions` (
  `permission_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `device_id` int NOT NULL,
  `permission_type` varchar(20) NOT NULL,
  `granted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `granted_by` int DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `revoked_by` int DEFAULT NULL,
  `notes` text,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`permission_id`),
  KEY `FK_Permissions_Device` (`device_id`),
  KEY `FK_Permissions_GrantedBy` (`granted_by`),
  KEY `FK_Permissions_RevokedBy` (`revoked_by`),
  KEY `IX_Permissions_Active` (`user_id`,`device_id`,`expires_at`),
  KEY `IX_Permissions_Expires` (`expires_at`),
  CONSTRAINT `FK_Permissions_Device` FOREIGN KEY (`device_id`) REFERENCES `Devices` (`device_id`),
  CONSTRAINT `FK_Permissions_GrantedBy` FOREIGN KEY (`granted_by`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `FK_Permissions_RevokedBy` FOREIGN KEY (`revoked_by`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `FK_Permissions_User` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `CK_Permissions_Expiry` CHECK (((`expires_at` is null) or (`expires_at` > `granted_at`))),
  CONSTRAINT `CK_Permissions_Revoked` CHECK (((`revoked_at` is null) or (`revoked_at` >= `granted_at`))),
  CONSTRAINT `CK_Permissions_Type` CHECK ((`permission_type` in (_utf8mb4'view',_utf8mb4'control',_utf8mb4'file_transfer',_utf8mb4'full')))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Permissions`
--

LOCK TABLES `Permissions` WRITE;
/*!40000 ALTER TABLE `Permissions` DISABLE KEYS */;
INSERT INTO `Permissions` VALUES (8,23,19,'control','2026-11-24 15:47:47',1,'2026-11-25 15:47:47','2026-11-24 15:51:59',NULL,'Admin duyệt theo yêu cầu của Nguyễn Thành Đạt',0,NULL,'2026-11-24 15:51:59'),(9,23,19,'control','2026-11-24 15:52:12',1,'2026-11-25 15:52:12','2026-11-24 16:46:43',NULL,'Admin duyệt theo yêu cầu của Nguyễn Thành Đạt',0,NULL,'2026-11-24 16:46:43'),(10,25,19,'control','2026-11-24 17:05:39',1,'2026-11-25 17:05:39',NULL,NULL,'Admin duyệt cấp quyền cho Vũ (Ticket #7)',1,NULL,NULL),(11,25,18,'control','2026-11-24 17:09:07',1,'2026-11-25 17:09:07',NULL,NULL,'Admin duyệt theo yêu cầu của Vũ',1,NULL,NULL);
/*!40000 ALTER TABLE `Permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RemoteSessions`
--

DROP TABLE IF EXISTS `RemoteSessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RemoteSessions` (
  `session_id` int NOT NULL AUTO_INCREMENT,
  `request_id` int DEFAULT NULL,
  `it_user_id` int NOT NULL,
  `target_user_id` int NOT NULL,
  `source_device_id` int NOT NULL,
  `target_device_id` int NOT NULL,
  `server_id` int DEFAULT NULL,
  `connection_type` varchar(10) NOT NULL DEFAULT 'direct',
  `start_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` datetime DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'started',
  `quality_score` tinyint DEFAULT NULL,
  `it_ip_address` varchar(45) DEFAULT NULL,
  `notes` text,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  KEY `FK_Session_Source` (`source_device_id`),
  KEY `FK_Session_Target` (`target_device_id`),
  KEY `IX_Session_Request` (`request_id`),
  KEY `IX_Session_ITTime` (`it_user_id`,`start_time`),
  KEY `IX_Session_TargetTime` (`target_user_id`,`start_time`),
  KEY `IX_Session_Server` (`server_id`),
  CONSTRAINT `FK_Session_IT` FOREIGN KEY (`it_user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `FK_Session_Server` FOREIGN KEY (`server_id`) REFERENCES `Servers` (`server_id`),
  CONSTRAINT `FK_Session_Source` FOREIGN KEY (`source_device_id`) REFERENCES `Devices` (`device_id`),
  CONSTRAINT `FK_Session_Target` FOREIGN KEY (`target_device_id`) REFERENCES `Devices` (`device_id`),
  CONSTRAINT `FK_Session_TargetUser` FOREIGN KEY (`target_user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `CK_Session_Duration` CHECK (((`duration_seconds` is null) or (`duration_seconds` >= 0))),
  CONSTRAINT `CK_Session_Quality` CHECK (((`quality_score` is null) or (`quality_score` between 1 and 5))),
  CONSTRAINT `CK_Session_Relay` CHECK (((`connection_type` <> _utf8mb4'direct') or (`server_id` is null))),
  CONSTRAINT `CK_Session_Status` CHECK ((`status` in (_utf8mb4'started',_utf8mb4'ended',_utf8mb4'failed'))),
  CONSTRAINT `CK_Session_Times` CHECK (((`end_time` is null) or (`end_time` >= `start_time`))),
  CONSTRAINT `CK_Session_Type` CHECK ((`connection_type` in (_utf8mb4'direct',_utf8mb4'relay')))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RemoteSessions`
--

LOCK TABLES `RemoteSessions` WRITE;
/*!40000 ALTER TABLE `RemoteSessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `RemoteSessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Roles`
--

DROP TABLE IF EXISTS `Roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `permissions` json NOT NULL DEFAULT (json_array()),
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `UQ_Roles_Name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Roles`
--

LOCK TABLES `Roles` WRITE;
/*!40000 ALTER TABLE `Roles` DISABLE KEYS */;
INSERT INTO `Roles` VALUES (1,'admin','Quản trị','[\"manage_users\", \"manage_devices\", \"manage_permissions\"]','2026-11-12 15:37:47',NULL,NULL),(2,'it','Nhân viên IT','[\"handle_support\", \"remote_control\"]','2026-11-12 15:37:47',NULL,NULL),(3,'user','Nhân viên','[\"request_support\"]','2026-11-12 15:37:47',NULL,NULL),(4,'manager','Quản lý','[\"view_reports\"]','2026-11-12 15:37:47',NULL,NULL);
/*!40000 ALTER TABLE `Roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Servers`
--

DROP TABLE IF EXISTS `Servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Servers` (
  `server_id` int NOT NULL AUTO_INCREMENT,
  `server_name` varchar(100) NOT NULL,
  `server_type` varchar(10) NOT NULL,
  `host` varchar(255) NOT NULL,
  `port` int NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'unknown',
  `last_heartbeat` datetime DEFAULT NULL,
  `cpu_usage` decimal(5,2) DEFAULT NULL,
  `ram_usage` decimal(5,2) DEFAULT NULL,
  `version` varchar(40) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`server_id`),
  UNIQUE KEY `UQ_Servers_Endpoint` (`server_type`,`host`,`port`),
  CONSTRAINT `CK_Servers_CPU` CHECK (((`cpu_usage` is null) or (`cpu_usage` between 0 and 100))),
  CONSTRAINT `CK_Servers_Port` CHECK ((`port` between 1 and 65535)),
  CONSTRAINT `CK_Servers_RAM` CHECK (((`ram_usage` is null) or (`ram_usage` between 0 and 100))),
  CONSTRAINT `CK_Servers_Status` CHECK ((`status` in (_utf8mb4'online',_utf8mb4'offline',_utf8mb4'unknown'))),
  CONSTRAINT `CK_Servers_Type` CHECK ((`server_type` in (_utf8mb4'HBBS',_utf8mb4'HBBR')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Servers`
--

LOCK TABLES `Servers` WRITE;
/*!40000 ALTER TABLE `Servers` DISABLE KEYS */;
/*!40000 ALTER TABLE `Servers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Settings`
--

DROP TABLE IF EXISTS `Settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Settings` (
  `key` varchar(100) NOT NULL,
  `value` text NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Settings`
--

LOCK TABLES `Settings` WRITE;
/*!40000 ALTER TABLE `Settings` DISABLE KEYS */;
INSERT INTO `Settings` VALUES ('default_permission_hours','24','Thời hạn quyền mặc định (giờ)','2026-11-12 15:37:48',NULL),('max_login_attempts','5','Số lần đăng nhập sai tối đa','2026-11-12 15:37:48',NULL),('session_timeout_minutes','60','Thời gian phiên tối đa (phút)','2026-11-12 15:37:48',NULL);
/*!40000 ALTER TABLE `Settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SupportRequests`
--

DROP TABLE IF EXISTS `SupportRequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SupportRequests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `device_id` int NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text,
  `client_password` varchar(100) DEFAULT NULL,
  `priority` varchar(10) NOT NULL DEFAULT 'normal',
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `assigned_it_id` int DEFAULT NULL,
  `accepted_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `rating` tinyint DEFAULT NULL,
  `feedback` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `declined_it_ids` varchar(255) DEFAULT '',
  PRIMARY KEY (`request_id`),
  KEY `FK_Support_Device` (`device_id`),
  KEY `IX_Support_StatusPriority` (`status`,`priority`,`created_at`),
  KEY `IX_Support_Employee` (`employee_id`,`created_at`),
  KEY `IX_Support_AssignedIT` (`assigned_it_id`,`status`),
  CONSTRAINT `FK_Support_AssignedIT` FOREIGN KEY (`assigned_it_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `FK_Support_Device` FOREIGN KEY (`device_id`) REFERENCES `Devices` (`device_id`),
  CONSTRAINT `FK_Support_Employee` FOREIGN KEY (`employee_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `CK_Support_Priority` CHECK ((`priority` in (_utf8mb4'low',_utf8mb4'normal',_utf8mb4'high',_utf8mb4'urgent'))),
  CONSTRAINT `CK_Support_Rating` CHECK (((`rating` is null) or (`rating` between 1 and 5))),
  CONSTRAINT `CK_Support_Status` CHECK ((`status` in (_utf8mb4'pending',_utf8mb4'accepted',_utf8mb4'in_progress',_utf8mb4'completed',_utf8mb4'rejected',_utf8mb4'cancelled'))),
  CONSTRAINT `CK_Support_Times` CHECK (((`completed_at` is null) or (`completed_at` >= `created_at`)))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SupportRequests`
--

LOCK TABLES `SupportRequests` WRITE;
/*!40000 ALTER TABLE `SupportRequests` DISABLE KEYS */;
INSERT INTO `SupportRequests` VALUES (5,24,19,'asdf','asdf','pnkubz','normal','rejected',NULL,NULL,NULL,NULL,'Không thuộc phạm vi hỗ trợ','2026-11-24 16:55:09','2026-11-24 16:55:23',''),(6,24,19,'dd','dd','avasdfsd','normal','rejected',NULL,NULL,NULL,NULL,'Không thuộc phạm vi hỗ trợ','2026-11-24 16:57:57','2026-11-24 16:58:04',''),(7,24,19,'gg','','pnkubz','normal','accepted',25,'2026-11-24 17:05:22',NULL,NULL,NULL,'2026-11-24 17:05:09','2026-11-24 17:05:22','');
/*!40000 ALTER TABLE `SupportRequests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `department_id` int DEFAULT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(254) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `role_id` int NOT NULL DEFAULT '3',
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `UQ_Users_Username` (`username`),
  UNIQUE KEY `UX_Users_Email` (`email`),
  KEY `FK_Users_Roles` (`role_id`),
  KEY `IX_Users_Department` (`department_id`),
  CONSTRAINT `FK_Users_Departments` FOREIGN KEY (`department_id`) REFERENCES `Departments` (`department_id`),
  CONSTRAINT `FK_Users_Roles` FOREIGN KEY (`role_id`) REFERENCES `Roles` (`role_id`),
  CONSTRAINT `CK_Users_Status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive',_utf8mb4'locked')))
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES (1,1,'admin','123','Nguyễn Văn An (Admin)','admin@vynex.vn','0901 234 567',NULL,1,'active',NULL,'2026-11-12 16:33:43','2026-11-22 16:14:08',NULL),(23,1,'dat','123','Nguyễn Thành Đạt','dat@vynex.vn','01234567891',NULL,2,'active',NULL,'2026-11-24 09:50:47',NULL,NULL),(24,2,'mai','123','Phạm Thị Mai','mai@vynex.vn','01234567891',NULL,3,'active',NULL,'2026-11-24 09:51:20',NULL,NULL),(25,1,'vu','123','Vũ','vu@vynex.vn','01234567891',NULL,2,'active',NULL,'2026-11-24 16:51:39',NULL,NULL);
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-25  3:59:33
