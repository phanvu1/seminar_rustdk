class ActivityLogModel {
  final int logId;
  final int userId;
  final String userName;
  final int? deviceId;
  final String action;
  final String description;
  final String? ipAddress;
  final String? targetType;
  final String status; // success, failed
  final DateTime createdAt;

  ActivityLogModel({
    required this.logId,
    required this.userId,
    required this.userName,
    this.deviceId,
    required this.action,
    required this.description,
    this.ipAddress,
    this.targetType,
    this.status = 'success',
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      logId: json['log_id'] is int ? json['log_id'] : int.tryParse(json['log_id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      userName: json['user_name'] ?? 'User #${json['user_id']}',
      deviceId: json['device_id'] is int ? json['device_id'] : int.tryParse(json['device_id']?.toString() ?? ''),
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      ipAddress: json['ip_address'],
      targetType: json['target_type'],
      status: json['status'] ?? 'success',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }
}

class ServerMetricModel {
  final int serverId;
  final String serverName;
  final String serverType; // HBBS, HBBR
  final String host;
  final int port;
  final String status; // online, offline, unknown
  final double? cpuUsage;
  final double? ramUsage;
  final String? version;
  final DateTime? lastHeartbeat;

  ServerMetricModel({
    required this.serverId,
    required this.serverName,
    required this.serverType,
    required this.host,
    required this.port,
    this.status = 'online',
    this.cpuUsage,
    this.ramUsage,
    this.version,
    this.lastHeartbeat,
  });

  factory ServerMetricModel.fromJson(Map<String, dynamic> json) {
    return ServerMetricModel(
      serverId: json['server_id'] is int ? json['server_id'] : int.tryParse(json['server_id'].toString()) ?? 0,
      serverName: json['server_name'] ?? '',
      serverType: json['server_type'] ?? 'HBBS',
      host: json['host'] ?? '127.0.0.1',
      port: json['port'] is int ? json['port'] : int.tryParse(json['port'].toString()) ?? 21116,
      status: json['status'] ?? 'online',
      cpuUsage: json['cpu_usage'] != null ? double.tryParse(json['cpu_usage'].toString()) : null,
      ramUsage: json['ram_usage'] != null ? double.tryParse(json['ram_usage'].toString()) : null,
      version: json['version'] ?? '1.1.10',
      lastHeartbeat: json['last_heartbeat'] != null ? DateTime.tryParse(json['last_heartbeat'].toString()) : null,
    );
  }
}
