class DeviceModel {
  final int deviceId;
  final String vynexId; // rustdesk_id
  final String name; // device_name
  final int? userId;
  final String? userName;
  final int? departmentId;
  final String? departmentName;
  final String deviceType; // desktop, laptop, server, other
  final String? ipAddress;
  final String? macAddress;
  final String? osName;
  final String status; // online, offline, disabled
  final DateTime? lastHeartbeat;
  final DateTime? lastOnline;

  DeviceModel({
    required this.deviceId,
    required this.vynexId,
    required this.name,
    this.userId,
    this.userName,
    this.departmentId,
    this.departmentName,
    this.deviceType = 'desktop',
    this.ipAddress,
    this.macAddress,
    this.osName,
    this.status = 'offline',
    this.lastHeartbeat,
    this.lastOnline,
  });

  bool get isOnline => status.toLowerCase() == 'online';

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['device_id'] is int ? json['device_id'] : int.tryParse(json['device_id'].toString()) ?? 0,
      vynexId: json['vynex_id'] ?? json['rustdesk_id'] ?? '',
      name: json['name'] ?? json['device_name'] ?? 'Thiết bị #${json['device_id']}',
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      userName: json['user_name'] ?? json['full_name'],
      departmentId: json['department_id'] is int ? json['department_id'] : int.tryParse(json['department_id']?.toString() ?? ''),
      departmentName: json['department_name'],
      deviceType: json['device_type'] ?? 'desktop',
      ipAddress: json['ip_address'],
      macAddress: json['mac_address'],
      osName: json['os_name'] ?? 'Windows 11 Pro',
      status: json['status'] ?? (json['is_online'] == true ? 'online' : 'offline'),
      lastHeartbeat: json['last_heartbeat'] != null ? DateTime.tryParse(json['last_heartbeat'].toString()) : null,
      lastOnline: json['last_online'] != null ? DateTime.tryParse(json['last_online'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'rustdesk_id': vynexId,
      'device_name': name,
      'user_id': userId,
      'department_id': departmentId,
      'device_type': deviceType,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'status': status,
    };
  }

  DeviceModel copyWith({
    String? name,
    String? status,
    String? ipAddress,
    int? departmentId,
    String? departmentName,
    DateTime? lastHeartbeat,
  }) {
    return DeviceModel(
      deviceId: deviceId,
      vynexId: vynexId,
      name: name ?? this.name,
      userId: userId,
      userName: userName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      deviceType: deviceType,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress,
      osName: osName,
      status: status ?? this.status,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      lastOnline: lastOnline,
    );
  }
}
