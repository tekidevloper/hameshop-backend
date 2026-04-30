enum UserRole { admin, customer }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final UserRole role;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.role = UserRole.customer,
    this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.customer,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null,
    );
  }
}
