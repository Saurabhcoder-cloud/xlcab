import 'package:flutter/material.dart';

/// Entry point of the XL Cab application.
void main() {
  runApp(const XLCabApp());
}

/// Root widget configuring global theme, navigation, and initial screen.
class XLCabApp extends StatelessWidget {
  const XLCabApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xFFFFC107);
    const Color darkBlack = Color(0xFF121212);

    return MaterialApp(
      title: 'XL Cab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryYellow,
          brightness: Brightness.dark,
        ),
        primaryColor: primaryYellow,
        scaffoldBackgroundColor: darkBlack,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlack,
          foregroundColor: primaryYellow,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryYellow,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case CarDetailsScreen.routeName:
            final car = settings.arguments as Car;
            return MaterialPageRoute(
              builder: (_) => CarDetailsScreen(car: car),
            );
          case BookingFormScreen.routeName:
            final car = settings.arguments as Car;
            return MaterialPageRoute(
              builder: (_) => BookingFormScreen(car: car),
            );
          case BookingConfirmationScreen.routeName:
            final details = settings.arguments as BookingDetails;
            return MaterialPageRoute(
              builder: (_) => BookingConfirmationScreen(details: details),
            );
        }
        return null;
      },
    );
  }
}

/// Model representing a car available for rent.
class Car {
  const Car({
    required this.name,
    required this.description,
    required this.pricePerDay,
    required this.seats,
    required this.imageUrl,
  });

  final String name;
  final String description;
  final double pricePerDay;
  final int seats;
  final String imageUrl;
}

/// Details collected from the booking form.
class BookingDetails {
  const BookingDetails({
    required this.car,
    required this.fullName,
    required this.phoneNumber,
    required this.pickupDate,
    required this.dropOffDate,
    required this.specialRequests,
  });

  final Car car;
  final String fullName;
  final String phoneNumber;
  final DateTime pickupDate;
  final DateTime dropOffDate;
  final String specialRequests;
}

/// Splash screen displaying the XL Cab logo with a fade-in animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 1;
        });
      }
    });

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.local_taxi,
                size: 128,
                color: Color(0xFFFFC107),
              ),
              SizedBox(height: 16),
              Text(
                'XL Cab',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFFFFC107),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home screen displaying a list of available cars for booking.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  List<Car> get _availableCars => const [
        Car(
          name: 'Executive Sedan',
          description: 'Comfortable ride ideal for business trips and airport transfers.',
          pricePerDay: 79.99,
          seats: 4,
          imageUrl: 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=600&q=80',
        ),
        Car(
          name: 'Luxury SUV',
          description: 'Spacious and premium SUV with ample room for families and luggage.',
          pricePerDay: 119.99,
          seats: 6,
          imageUrl: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=600&q=80',
        ),
        Car(
          name: 'City Hatchback',
          description: 'Compact and efficient vehicle perfect for urban adventures.',
          pricePerDay: 59.99,
          seats: 4,
          imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=80',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableCars.length,
        itemBuilder: (context, index) {
          final car = _availableCars[index];
          return _CarCard(car: car);
        },
      ),
    );
  }
}

/// Card widget summarising car information on the home screen.
class _CarCard extends StatelessWidget {
  const _CarCard({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        CarDetailsScreen.routeName,
        arguments: car,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                car.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Icon(Icons.directions_car, size: 48, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car.description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.event_seat, size: 18),
                      const SizedBox(width: 4),
                      Text('${car.seats} seats'),
                      const Spacer(),
                      Text('\$${car.pricePerDay.toStringAsFixed(2)}/day'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed view for a specific car, with booking call-to-action.
class CarDetailsScreen extends StatelessWidget {
  const CarDetailsScreen({required this.car, super.key});

  static const String routeName = '/car-details';

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(car.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  car.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: const Icon(Icons.directions_car, size: 64, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                car.description,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    label: Text('${car.seats} seats'),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    label: Text('\$${car.pricePerDay.toStringAsFixed(2)} per day'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    BookingFormScreen.routeName,
                    arguments: car,
                  );
                },
                icon: const Icon(Icons.assignment),
                label: const Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Booking form allowing customers to submit trip details.
class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({required this.car, super.key});

  static const String routeName = '/booking-form';

  final Car car;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _dropOffDateController = TextEditingController();
  final TextEditingController _specialRequestsController = TextEditingController();

  DateTime? _pickupDate;
  DateTime? _dropOffDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pickupDateController.dispose();
    _dropOffDateController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isPickup}) async {
    final initialDate = isPickup
        ? (_pickupDate ?? DateTime.now())
        : (_dropOffDate ?? _pickupDate ?? DateTime.now());
    final firstDate = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: isPickup ? 'Select pickup date' : 'Select drop-off date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFFFFC107)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = pickedDate;
          _pickupDateController.text = _formatDate(pickedDate);
          if (_dropOffDate != null && _dropOffDate!.isBefore(pickedDate)) {
            _dropOffDate = null;
            _dropOffDateController.clear();
          }
        } else {
          _dropOffDate = pickedDate;
          _dropOffDateController.text = _formatDate(pickedDate);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickupDate == null || _dropOffDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both pickup and drop-off dates.')),
      );
      return;
    }

    if (_dropOffDate!.isBefore(_pickupDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drop-off date cannot be before pickup date.')),
      );
      return;
    }

    final details = BookingDetails(
      car: widget.car,
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      pickupDate: _pickupDate!,
      dropOffDate: _dropOffDate!,
      specialRequests: _specialRequestsController.text,
    );

    Navigator.pushNamed(
      context,
      BookingConfirmationScreen.routeName,
      arguments: details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.car.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 8) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                controller: _pickupDateController,
                label: 'Pickup Date',
                icon: Icons.calendar_today,
                onTap: () => _selectDate(isPickup: true),
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                controller: _dropOffDateController,
                label: 'Drop-off Date',
                icon: Icons.event_available,
                onTap: () => _selectDate(isPickup: false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialRequestsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Special Requests (optional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable field to show a read-only text box that opens a date picker.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
      onTap: onTap,
    );
  }
}

/// Booking confirmation screen showing a summary of reservation details.
class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({required this.details, super.key});

  static const String routeName = '/booking-confirmation';

  final BookingDetails details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFFFC107), size: 72),
            const SizedBox(height: 16),
            Text(
              'Thank you, ${details.fullName}! Your booking is confirmed.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _BookingInfoRow(
              label: 'Car',
              value: details.car.name,
            ),
            _BookingInfoRow(
              label: 'Pickup Date',
              value: _formatDate(details.pickupDate),
            ),
            _BookingInfoRow(
              label: 'Drop-off Date',
              value: _formatDate(details.dropOffDate),
            ),
            _BookingInfoRow(
              label: 'Contact',
              value: details.phoneNumber,
            ),
            if (details.specialRequests.isNotEmpty)
              _BookingInfoRow(
                label: 'Special Requests',
                value: details.specialRequests,
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(
                  context,
                  ModalRoute.withName(HomeScreen.routeName),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

/// Small helper widget to format booking information rows.
class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

/// Profile screen displaying saved user information and preferences.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFC107),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(Icons.person, size: 48, color: Colors.black),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Alex Johnson',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'alex.johnson@example.com',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferred Pickup Locations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _ProfileListItem(icon: Icons.location_on, label: 'Downtown Office'),
            const _ProfileListItem(icon: Icons.location_on, label: 'Airport Terminal 1'),
            const SizedBox(height: 24),
            const Text(
              'Saved Payment Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _ProfileListItem(icon: Icons.credit_card, label: 'Visa ending in •••• 4242'),
            const SizedBox(height: 24),
            const Text(
              'Support',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _ProfileListItem(icon: Icons.phone, label: '+1 800 123 4567'),
            const _ProfileListItem(icon: Icons.email, label: 'support@xlcab.com'),
          ],
        ),
      ),
    );
  }
}

/// Simple reusable list tile for profile information.
class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC107)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
