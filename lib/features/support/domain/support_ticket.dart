class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final String status;
  final String? adminReply;
  final String? adminId;
  final String channel;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.status,
    this.adminReply,
    this.adminId,
    required this.channel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      adminReply: json['admin_reply'] as String?,
      adminId: json['admin_id'] as String?,
      channel: json['channel'] as String? ?? 'in-app',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject': subject,
      'message': message,
      'status': status,
      'admin_reply': adminReply,
      'admin_id': adminId,
      'channel': channel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
