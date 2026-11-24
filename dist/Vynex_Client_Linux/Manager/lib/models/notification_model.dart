class NotificationModel {
  final int notificationId;
  final int userId;
  final String title;
  final String content;
  final String type; // support_request, permission_granted, permission_revoked, session_started, session_ended, general
  final int? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] is int ? json['notification_id'] : int.tryParse(json['notification_id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'general',
      referenceId: json['reference_id'] is int ? json['reference_id'] : int.tryParse(json['reference_id']?.toString() ?? ''),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'title': title,
      'content': content,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      content: content,
      type: type,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
