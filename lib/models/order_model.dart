class OrderModel {
  final String id;
  final List<OrderItem> items;
  final double total;
  final DateTime date;
  final String status; // 'pending', 'processing', 'shipped', 'delivered'
  final String paymentStatus; // 'unpaid', 'paid'
  final String customerName;
  final String customerEmail;
  final String? phoneNumber;
  final Map<String, dynamic>? shippingAddress;
  final String? trackingNumber;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
    required this.paymentStatus,
    required this.customerName,
    required this.customerEmail,
    this.phoneNumber,
    this.shippingAddress,
    this.trackingNumber,
  });

  double get totalAmount => total;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
      total: double.tryParse(json['totalAmount']?.toString() ?? '0.0') ?? 0.0,
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      customerName: json['customerName']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      shippingAddress: json['shippingAddress'],
      trackingNumber: json['trackingNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': total,
      'status': status,
      'paymentStatus': paymentStatus,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'phoneNumber': phoneNumber,
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
    };
  }
}

class OrderItem {
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  String get name => productName;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['productName']?.toString() ?? '',
      productImage: json['productImage']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
    };
  }
}
