import 'package:hello_way_client/models/image.dart';

class Space {
  final int id;
  final String title;
  final String? latitude; // Nullable because it might be null
  final String? longitude; // Nullable because it might be null
  final String? description; // Nullable because it might be null
  final num? rating;
  final int? numberOfRatings;
  final String? category;
  final int phoneNumber;
  List<ImageModel>? images;

  Space({
    required this.id,
    required this.title,
    this.latitude,
    this.longitude,
    this.description,
    required this.phoneNumber,
    this.rating,
    this.numberOfRatings,
    this.category,
    this.images,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    // Safely handle null values in JSON
    final List<dynamic>? jsonImages = json['images'];
    final images = jsonImages != null
        ? jsonImages.map((image) => ImageModel.fromJson(image)).toList()
        : null;

    return Space(
      id: json['id_space'] ?? 0, // Default value if null
      title: json['titleSpace'] ?? 'Unknown', // Default value if null
      latitude: json['latitude']?.toString(), // Convert to String if not null
      longitude: json['longitude']?.toString(), // Convert to String if not null
      description: json['description'] ?? '', // Default to empty string if null
      rating: json['rating'], // Can remain nullable
      numberOfRatings: json['numberOfRating'], // Can remain nullable
      category: json['spaceCategorie'], // Can remain nullable
      images: images, // Can remain nullable
      phoneNumber: json['phoneNumber'] ?? 0, // Default value if null
    );
  }

  Map<String, dynamic> toJson() => {
    'id_space': id,
    'titleSpace': title,
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
    'rating': rating,
    'numberOfRate': numberOfRatings,
    'spaceCategorie': category,
    'images': images?.map((image) => image.toJson()).toList(),
    'phoneNumber': phoneNumber,
  };
}
