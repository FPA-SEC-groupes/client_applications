import 'package:hello_way_client/models/image.dart';

class Product {
  int? id;
  String title;
  double price;
  String description;
  bool available;
  dynamic categorie;
  List<ImageModel>? images;
  bool? hasActivePromotion;
  int? percentage;

  Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.available,
    this.categorie,
    this.images,
    this.hasActivePromotion,
    this.percentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonImages = json['images'] ?? [];
    final images = jsonImages.map((image) => ImageModel.fromJson(image)).toList();

    if (json.containsKey('promotions')) {
      final List<dynamic> jsonPromotions = json['promotions'] ?? [];
      final promotion = jsonPromotions.isNotEmpty ? jsonPromotions[0] : null;
      return Product(
        id: json['idProduct'],
        title: json['productTitle'],
        price: json['price'],
        description: json['description'],
        categorie: json['categorie'],
        available: json['available'],
        hasActivePromotion: promotion != null,
        percentage: promotion != null ? promotion['percentage'] : 0,
        images: images,
      );
    } else {
      return Product(
        id: json['idProduct'],
        title: json['productTitle'],
        price: json['price'],
        description: json['description'],
        categorie: json['categorie'],
        available: json['available'],
        hasActivePromotion: json['hasActivePromotion'],
        percentage: json['percentage'],
        images: images,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'idProduct': id,
    'productTitle': title,
    'price': price,
    'description': description,
    'categorie': categorie,
    'available': available,
    'hasActivePromotion': hasActivePromotion,
    'percentage': percentage,
    'images': images?.map((image) => image.toJson()).toList(),
  };

  @override
  String toString() {
    return 'Product{productTitle: $title, price: $price, hasActivePromotion: $hasActivePromotion, percentage: $percentage, images: $images}';
  }
}
