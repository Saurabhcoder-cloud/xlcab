# XL Cab Mobile App

A Flutter-based mobile application for the XL Cab car rental experience. The app features a modern yellow-and-black theme, a smooth onboarding flow, and persistent local storage for login and booking information.

## Key Screens
- **Login** – Collects the user email and password (no backend) before continuing.
- **Splash** – Animated logo reveal that transitions into the main experience.
- **Home** – Car catalogue sourced from bundled mock data with detailed cards.
- **Car Details** – Image carousel, pricing, and booking entry point.
- **Booking Form** – Schedule pickup/drop-off with validation and local persistence.
- **Booking Confirmation** – Animated success state with confetti feedback.
- **Bookings Tab** – Lists saved reservations from the current session or storage.
- **Profile** – Displays mock user information and booking history.

## Getting Started
1. Ensure the Flutter SDK (3.0 or newer) is installed and configured.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

## Preparing for Live APIs
- Network interactions are centralised inside [`lib/services/api_service.dart`](lib/services/api_service.dart).
- `ApiService.getCars()` currently reads from `assets/data/cars.json`; swap the body for an HTTP `GET` call to `/api/cars` and parse the JSON into `Car` objects when the backend is available.
- `ApiService.createBooking()` simulates latency; replace it with an HTTP `POST` to `/api/bookings` that serialises `BookingDetails.toJson()` and handles the server response.
- Once live data is in place, you can remove the bundled mock JSON asset if it is no longer needed.

## Building an Android Release APK
To produce a release build of the Android application, run:
```bash
flutter build apk --release
```
This command generates the signed (or unsigned if no keystore is configured) release package at:
```
build/app/outputs/flutter-apk/app-release.apk
```
You can distribute or archive the generated `app-release.apk` from that path. For more details about signing and deployment, refer to the [Flutter documentation](https://docs.flutter.dev/deployment/android).

