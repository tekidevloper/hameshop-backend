class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images; // Multiple images
  final String category;
  final bool isRecommended;
  final double rating; // Average rating
  final int reviewCount; // Number of reviews

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    List<String>? images,
    required this.category,
    this.isRecommended = false,
    this.rating = 0.0,
    this.reviewCount = 0,
  }) : images = images ?? [imageUrl];

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      images: (json['images'] is List && (json['images'] as List).isNotEmpty)
          ? List<String>.from((json['images'] as List).map((e) => e.toString())) 
          : [json['imageUrl']?.toString() ?? ''],
      category: json['category']?.toString() ?? '',
      isRecommended: json['isRecommended'] == true || json['isRecommended'] == 'true',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'category': category,
      'isRecommended': isRecommended,
      'rating': rating,
      'reviewCount': reviewCount,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }
}
