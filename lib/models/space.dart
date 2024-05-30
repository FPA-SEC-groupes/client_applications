

import 'package:hello_way_client/models/image.dart';

class Space {
  final int id;
  final String title;
  final String latitude;
  final String longitude;
  final String description;
  final num? rating;
  final int? numberOfRatings;
  final String? category;
  final int phoneNumber;
  List<ImageModel>? images;
  Space( {
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.phoneNumber,
    this.rating,
    required this.numberOfRatings,
     this.category,
    this.images,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonImages = json['images'];
    final images = jsonImages.map((image) => ImageModel.fromJson(image)).toList();
    return Space(
      id: json['id_space'],
      title: json['titleSpace'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
        rating: json['rating'],
      numberOfRatings: json['numberOfRate'],
      category: json['spaceCategorie'],
      images: images,
        phoneNumber:  json['phoneNumber'],
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

  };
}