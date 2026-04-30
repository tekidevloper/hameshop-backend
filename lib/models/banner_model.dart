class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final bool isActive;
  final int order;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.isActive = true,
    this.order = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      title: json['title']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == 'true',
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    );
  }
}
