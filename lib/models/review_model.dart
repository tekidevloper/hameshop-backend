class Review {
  final String id;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime date;
  final String? productId;
  final String? userId;

  Review({
    required this.id,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.date,
    this.productId,
    this.userId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Anonymous',
      userImage: json['userImage']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      date: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      productId: json['productId']?.toString(),
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'productId': productId,
      'userName': userName,
    };
  }
}
