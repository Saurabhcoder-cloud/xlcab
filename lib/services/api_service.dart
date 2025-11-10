import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/booking_details.dart';
import '../models/car.dart';

/// Provides an abstraction over the future XL Cab REST endpoints.
class ApiService {
  const ApiService._();

  /// Placeholder path for fetching available cars once the backend is ready.
  static const String carsEndpoint = '/api/cars';

  /// Placeholder path for posting new bookings once the backend is ready.
  static const String bookingsEndpoint = '/api/bookings';

  /// Returns the catalogue of cars.
  ///
  /// Currently reads from the bundled JSON asset. When the backend is live,
  /// replace the body of this method with an HTTP GET request to
  /// [carsEndpoint] and parse the response payload into [Car] objects.
  static Future<List<Car>> getCars() async {
    final String jsonString = await rootBundle.loadString('assets/data/cars.json');
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((dynamic item) => Car.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Sends a new booking to the backend.
  ///
  /// At the moment this simply simulates latency so the rest of the UI can be
  /// wired up. Replace the implementation with an HTTP POST to
  /// [bookingsEndpoint] that encodes [details.toJson()].
  static Future<void> createBooking(BookingDetails details) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
