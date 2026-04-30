class AddressModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? street,
    String? city,
    String? region,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }
}
