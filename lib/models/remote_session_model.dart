class RemoteSessionModel {
  final int sessionId;
  final int requestId;
  final int itUserId;
  final String itName;
  final int targetUserId;
  final String targetName;
  final int deviceId;
  final String deviceName;
  final String vynexId;
  final String connectionType; // direct, relay
  final int? qualityScore; // 1 to 5
  final String? itIpAddress;
  final String? notes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final String status; // started, ended, failed

  RemoteSessionModel({
    required this.sessionId,
    required this.requestId,
    required this.itUserId,
    required this.itName,
    required this.targetUserId,
    required this.targetName,
    required this.deviceId,
    required this.deviceName,
    required this.vynexId,
    this.connectionType = 'direct',
    this.qualityScore,
    this.itIpAddress,
    this.notes,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.status = 'started',
  });

  factory RemoteSessionModel.fromJson(Map<String, dynamic> json) {
    return RemoteSessionModel(
      sessionId: json['session_id'] is int ? json['session_id'] : int.tryParse(json['session_id'].toString()) ?? 0,
      requestId: json['request_id'] is int ? json['request_id'] : int.tryParse(json['request_id'].toString()) ?? 0,
      itUserId: json['it_user_id'] is int ? json['it_user_id'] : int.tryParse(json['it_user_id'].toString()) ?? 0,
      itName: json['it_name'] ?? 'IT #${json['it_user_id']}',
      targetUserId: json['target_user_id'] is int ? json['target_user_id'] : int.tryParse(json['target_user_id'].toString()) ?? 0,
      targetName: json['target_name'] ?? 'User #${json['target_user_id']}',
      deviceId: json['device_id'] is int ? json['device_id'] : int.tryParse(json['device_id']?.toString() ?? json['target_device_id']?.toString() ?? '0') ?? 0,
      deviceName: json['device_name'] ?? 'Thiết bị #${json['device_id']}',
      vynexId: json['vynex_id'] ?? json['rustdesk_id'] ?? '',
      connectionType: json['connection_type'] ?? 'direct',
      qualityScore: json['quality_score'] is int ? json['quality_score'] : int.tryParse(json['quality_score']?.toString() ?? ''),
      itIpAddress: json['it_ip_address'],
      notes: json['notes'],
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'].toString()) : (json['start_time'] != null ? DateTime.parse(json['start_time'].toString()) : DateTime.now()),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'].toString()) : (json['end_time'] != null ? DateTime.parse(json['end_time'].toString()) : null),
      durationSeconds: json['duration_seconds'] is int ? json['duration_seconds'] : int.tryParse(json['duration_seconds']?.toString() ?? ''),
      status: json['status'] ?? 'started',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'request_id': requestId,
      'it_user_id': itUserId,
      'target_user_id': targetUserId,
      'device_id': deviceId,
      'connection_type': connectionType,
      'quality_score': qualityScore,
      'it_ip_address': itIpAddress,
      'notes': notes,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': status,
    };
  }
}
