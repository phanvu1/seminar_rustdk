class PermissionModel {
  final int permissionId;
  final int userId; // IT staff ID
  final String itName;
  final int deviceId;
  final String deviceName;
  final String vynexId;
  final String permissionType; // view, control, file_transfer, full
  final DateTime grantedAt;
  final DateTime? expiresAt; // null means 'forever' / Vĩnh viễn
  final DateTime? revokedAt;
  final String? notes;
  final bool status; // 1 = active, 0 = revoked/expired

  PermissionModel({
    required this.permissionId,
    required this.userId,
    required this.itName,
    required this.deviceId,
    required this.deviceName,
    required this.vynexId,
    required this.permissionType,
    required this.grantedAt,
    this.expiresAt,
    this.revokedAt,
    this.notes,
    this.status = true,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isValid => status && revokedAt == null && !isExpired;

  String get expiryLabel {
    if (revokedAt != null) return 'Đã thu hồi';
    if (expiresAt == null) return 'Vĩnh viễn (Forever)';
    if (isExpired) return 'Đã hết hạn';
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.inDays > 0) return 'Còn ${diff.inDays} ngày';
    if (diff.inHours > 0) return 'Còn ${diff.inHours} giờ';
    return 'Còn ${diff.inMinutes} phút';
  }

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      permissionId: json['permission_id'] is int ? json['permission_id'] : int.tryParse(json['permission_id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      itName: json['it_name'] ?? json['user_name'] ?? 'IT #${json['user_id']}',
      deviceId: json['device_id'] is int ? json['device_id'] : int.tryParse(json['device_id'].toString()) ?? 0,
      deviceName: json['device_name'] ?? 'Thiết bị #${json['device_id']}',
      vynexId: json['vynex_id'] ?? json['rustdesk_id'] ?? '',
      permissionType: json['permission_type'] ?? 'full',
      grantedAt: json['granted_at'] != null ? DateTime.parse(json['granted_at'].toString()) : DateTime.now(),
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      revokedAt: json['revoked_at'] != null ? DateTime.tryParse(json['revoked_at'].toString()) : null,
      notes: json['notes'],
      status: json['status'] == true || json['status'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permission_id': permissionId,
      'user_id': userId,
      'device_id': deviceId,
      'permission_type': permissionType,
      'granted_at': grantedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
      'notes': notes,
      'status': status ? 1 : 0,
    };
  }

  PermissionModel copyWith({
    DateTime? revokedAt,
    bool? status,
    String? notes,
  }) {
    return PermissionModel(
      permissionId: permissionId,
      userId: userId,
      itName: itName,
      deviceId: deviceId,
      deviceName: deviceName,
      vynexId: vynexId,
      permissionType: permissionType,
      grantedAt: grantedAt,
      expiresAt: expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}
