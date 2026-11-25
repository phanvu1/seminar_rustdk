class SupportRequestModel {
  final int requestId;
  final int employeeId;
  final String employeeName;
  final int deviceId;
  final String deviceName;
  final String vynexId;
  final String? clientPassword; // Mật khẩu máy Client để IT/Admin tự động kết nối
  final String title;
  final String? description;
  final String priority; // low, normal, high, urgent
  final String status; // pending, accepted, in_progress, completed, rejected, cancelled
  final int? assignedItId;
  final String? assignedItName;
  final int? rating; // 1 to 5
  final String? feedback;
  final List<int> declinedItIds; // Danh sách ID kỹ thuật viên IT đã từ chối tiếp nhận
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  SupportRequestModel({
    required this.requestId,
    required this.employeeId,
    required this.employeeName,
    required this.deviceId,
    required this.deviceName,
    required this.vynexId,
    this.clientPassword,
    required this.title,
    this.description,
    this.priority = 'normal',
    this.status = 'pending',
    this.assignedItId,
    this.assignedItName,
    this.rating,
    this.feedback,
    this.declinedItIds = const [],
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  factory SupportRequestModel.fromJson(Map<String, dynamic> json) {
    List<int> parsedDeclined = [];
    if (json['declined_it_ids'] != null) {
      final str = json['declined_it_ids'].toString();
      parsedDeclined = str
          .split(',')
          .map((s) => int.tryParse(s.trim()) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    return SupportRequestModel(
      requestId: json['request_id'] is int ? json['request_id'] : int.tryParse(json['request_id'].toString()) ?? 0,
      employeeId: json['employee_id'] is int ? json['employee_id'] : int.tryParse(json['employee_id'].toString()) ?? 0,
      employeeName: json['employee_name'] ?? json['employee'] ?? 'Nhân viên #${json['employee_id']}',
      deviceId: json['device_id'] is int ? json['device_id'] : int.tryParse(json['device_id'].toString()) ?? 0,
      deviceName: json['device_name'] ?? 'Thiết bị #${json['device_id']}',
      vynexId: json['vynex_id'] ?? json['rustdesk_id'] ?? '',
      clientPassword: json['client_password'] ?? json['password'],
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'] ?? 'normal',
      status: json['status'] ?? 'pending',
      assignedItId: json['assigned_it_id'] is int ? json['assigned_it_id'] : int.tryParse(json['assigned_it_id']?.toString() ?? ''),
      assignedItName: json['assigned_it_name'],
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating']?.toString() ?? ''),
      feedback: json['feedback'],
      declinedItIds: parsedDeclined,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'employee_id': employeeId,
      'device_id': deviceId,
      'vynex_id': vynexId,
      'client_password': clientPassword,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'assigned_it_id': assignedItId,
      'rating': rating,
      'feedback': feedback,
      'declined_it_ids': declinedItIds.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  SupportRequestModel copyWith({
    String? status,
    int? assignedItId,
    String? assignedItName,
    String? clientPassword,
    DateTime? acceptedAt,
    DateTime? completedAt,
    int? rating,
    String? feedback,
    List<int>? declinedItIds,
  }) {
    return SupportRequestModel(
      requestId: requestId,
      employeeId: employeeId,
      employeeName: employeeName,
      deviceId: deviceId,
      deviceName: deviceName,
      vynexId: vynexId,
      clientPassword: clientPassword ?? this.clientPassword,
      title: title,
      description: description,
      priority: priority,
      status: status ?? this.status,
      assignedItId: assignedItId ?? this.assignedItId,
      assignedItName: assignedItName ?? this.assignedItName,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      declinedItIds: declinedItIds ?? this.declinedItIds,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
