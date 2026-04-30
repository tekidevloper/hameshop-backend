class RequestModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String category;
  final String status;
  final String? adminResponse;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;

  RequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.category,
    required this.status,
    this.adminResponse,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId'] is Map ? (json['userId']['id']?.toString() ?? json['userId']['_id']?.toString() ?? '') : (json['userId']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      status: json['status']?.toString() ?? 'open',
      adminResponse: json['adminResponse']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      userName: json['userId'] is Map ? json['userId']['name']?.toString() : null,
      userEmail: json['userId'] is Map ? json['userId']['email']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'category': category,
      'status': status,
      'adminResponse': adminResponse,
    };
  }
}
