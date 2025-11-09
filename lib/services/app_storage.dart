import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking_details.dart';

/// Simple model representing a stored user profile retrieved from preferences.
@immutable
class StoredUser {
  const StoredUser({required this.name, required this.email});

  final String name;
  final String email;
}

/// Lightweight storage wrapper persisting user details and bookings locally.
class AppStorage {
  AppStorage._();

  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _bookingsKey = 'bookings';

  static late SharedPreferences _prefs;
  static final ValueNotifier<StoredUser?> user = ValueNotifier<StoredUser?>(null);
  static final ValueNotifier<List<BookingDetails>> bookings =
      ValueNotifier<List<BookingDetails>>(<BookingDetails>[]);

  /// Initializes shared preferences and hydrates cached values into memory.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final String? storedName = _prefs.getString(_userNameKey);
    final String? storedEmail = _prefs.getString(_userEmailKey);
    if (storedName != null || storedEmail != null) {
      final String resolvedName = (storedName?.trim().isNotEmpty ?? false)
          ? storedName!.trim()
          : (storedEmail ?? '').trim();
      user.value = StoredUser(
        name: resolvedName,
        email: (storedEmail ?? '').trim(),
      );
    }

    final List<String>? storedBookings = _prefs.getStringList(_bookingsKey);
    if (storedBookings != null) {
      final List<BookingDetails> decoded = <BookingDetails>[];
      for (final String entry in storedBookings) {
        try {
          final Map<String, dynamic> map =
              json.decode(entry) as Map<String, dynamic>;
          decoded.add(BookingDetails.fromJson(map));
        } catch (_) {
          // Ignore invalid or legacy entries.
        }
      }
      bookings.value = decoded;
    }
  }

  /// Persists the last successful login so it can be restored on the next launch.
  static Future<void> setLastUser({
    required String name,
    required String email,
  }) async {
    final StoredUser stored = StoredUser(name: name, email: email);
    user.value = stored;
    await _prefs.setString(_userNameKey, stored.name);
    await _prefs.setString(_userEmailKey, stored.email);
  }

  /// Adds a booking to local memory and writes through to persistent storage.
  static Future<void> addBooking(BookingDetails details) async {
    final List<BookingDetails> updated =
        List<BookingDetails>.from(bookings.value)..add(details);
    bookings.value = updated;
    final List<String> encoded =
        updated.map((BookingDetails b) => json.encode(b.toJson())).toList();
    await _prefs.setStringList(_bookingsKey, encoded);
  }
}
