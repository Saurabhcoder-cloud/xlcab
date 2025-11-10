import 'package:flutter/material.dart';

import 'car.dart';

/// Details collected from the booking form.
@immutable
class BookingDetails {
  const BookingDetails({
    required this.car,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupDate,
    required this.pickupTime,
  });

  final Car car;
  final String pickupLocation;
  final String dropLocation;
  final DateTime pickupDate;
  final TimeOfDay pickupTime;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'car': car.toJson(),
        'pickup_location': pickupLocation,
        'drop_location': dropLocation,
        'pickup_date': pickupDate.toIso8601String(),
        'pickup_time': <String, int>{
          'hour': pickupTime.hour,
          'minute': pickupTime.minute,
        },
      };

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    final dynamic rawCar = json['car'];
    final Map<String, dynamic> carJson = rawCar is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawCar)
        : <String, dynamic>{};
    final dynamic rawTime = json['pickup_time'];
    final Map<String, dynamic> timeJson = rawTime is Map
        ? Map<String, dynamic>.from(rawTime as Map)
        : <String, dynamic>{};
    return BookingDetails(
      car: Car.fromJson(carJson),
      pickupLocation: json['pickup_location'] as String? ?? '',
      dropLocation: json['drop_location'] as String? ?? '',
      pickupDate: DateTime.tryParse(json['pickup_date'] as String? ?? '') ??
          DateTime.now(),
      pickupTime: TimeOfDay(
        hour: (timeJson['hour'] as num?)?.toInt() ?? 0,
        minute: (timeJson['minute'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
