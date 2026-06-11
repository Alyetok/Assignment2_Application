// lib/models/homestay.dart

class Homestay {
  final int? id;
  final String name;
  final String state;
  final String district;
  final String? description;
  final double? price;
  final String? imageUrl;
  final String? phone;
  final String? email;
  final List<String> amenities;

  Homestay({
    this.id,
    required this.name,
    required this.state,
    required this.district,
    this.description,
    this.price,
    this.imageUrl,
    this.phone,
    this.email,
    this.amenities = const [],
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    // Safely parse price — handles int, double, or String from API
    double? parsedPrice;
    final raw =
        json['price_min'] ?? json['price'] ?? json['rate'] ?? json['harga'];
    if (raw != null) {
      if (raw is int) {
        parsedPrice = raw.toDouble();
      } else if (raw is double) {
        parsedPrice = raw;
      } else {
        parsedPrice = double.tryParse(raw.toString());
      }
    }

    // Parse amenities list
    final amenitiesRaw = json['amenities'];
    List<String> amenitiesList = [];
    if (amenitiesRaw is List) {
      amenitiesList = amenitiesRaw.map((e) => e.toString()).toList();
    }

    return Homestay(
      id: json['id'] as int?,
      name: json['name']?.toString() ?? 'Unknown',
      state: json['state']?.toString() ?? 'Unknown',
      district: json['district']?.toString() ?? 'Unknown',
      description: json['description']?.toString(),
      price: parsedPrice,
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      phone: json['contact_phone']?.toString() ?? json['phone']?.toString(),
      email: json['email']?.toString(),
      amenities: amenitiesList,
    );
  }
}
