import 'package:flutter/material.dart';

/// Model representing a car available for rent.
@immutable
class Car {
  const Car({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerDay,
    required this.seats,
    required this.imageUrls,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    final num? rawPrice = json['price_per_day'] as num? ?? json['price'] as num?;
    final num? rawSeats = json['seats'] as num?;

    final List<dynamic>? rawImageList = json['image_urls'] as List<dynamic>?;
    final List<String> imageUrls;
    if (rawImageList != null && rawImageList.isNotEmpty) {
      imageUrls = rawImageList
          .whereType<String>()
          .where((url) => url.trim().isNotEmpty)
          .toList();
    } else {
      final String? singleUrl = json['image_url'] as String?;
      imageUrls = singleUrl == null || singleUrl.trim().isEmpty
          ? const <String>[
              'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=800&q=80'
            ]
          : <String>[singleUrl];
    }

    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pricePerDay: (rawPrice ?? 0).toDouble(),
      seats: rawSeats?.toInt() ?? 4,
      imageUrls: imageUrls,
    );
  }

  final String id;
  final String name;
  final String description;
  final double pricePerDay;
  final int seats;
  final List<String> imageUrls;

  /// Convenience accessor for the first image in the gallery.
  String get primaryImageUrl => imageUrls.first;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'price_per_day': pricePerDay,
        'seats': seats,
        'image_urls': imageUrls,
      };
}
