import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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
          ? <String>[]
          : <String>[singleUrl];
    }

    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pricePerDay: (rawPrice ?? 0).toDouble(),
      seats: rawSeats?.toInt() ?? 4,
      imageUrls: imageUrls.isEmpty
          ? const <String>['https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=800&q=80']
          : imageUrls,
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
}

/// Details collected from the booking form.
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = _loadCars();
  }

  Future<List<Car>> _loadCars() async {
    final String jsonString = await rootBundle.loadString('assets/data/cars.json');
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((dynamic item) => Car.fromJson(item as Map<String, dynamic>))
        .toList();
  }

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
      body: FutureBuilder<List<Car>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load cars. Please try again later.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          }

          final cars = snapshot.data ?? <Car>[];
          if (cars.isEmpty) {
            return const Center(
              child: Text('No cars available at the moment.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return _CarCard(car: car);
            },
          );
        },
      ),
    );
  }
}

/// Card widget summarising car information on the home screen.
class _CarCard extends StatelessWidget {
  const _CarCard({required this.car});

  final Car car;

  void _openDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      CarDetailsScreen.routeName,
      arguments: car,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetails(context),
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
                  car.primaryImageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.directions_car, size: 48, color: Colors.white),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openDetails(context),
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detailed view for a specific car, with booking call-to-action.
class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({required this.car, super.key});

  static const String routeName = '/car-details';

  final Car car;

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBookNow() {
    Navigator.pushNamed(
      context,
      BookingFormScreen.routeName,
      arguments: widget.car,
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.car.imageUrls;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final url = images[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          return child;
                        }
                        return Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.directions_car,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final bool isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 20 : 8,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFFFC107) : Colors.white54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.car.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.event_seat, color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 8),
                        Text('${widget.car.seats} seats'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFC107)),
                          ),
                          child: Text(
                            '\$${widget.car.pricePerDay.toStringAsFixed(2)}/day',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFC107),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.car.description,
                      style: const TextStyle(height: 1.5, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _onBookNow,
              child: const Text('Book Now'),
            ),
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
  static final List<BookingDetails> temporaryBookings = <BookingDetails>[];

  final Car car;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropLocationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _dropLocationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initialDate = _selectedDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select pickup date',
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
        _selectedDate = pickedDate;
        _dateController.text = _formatDate(pickedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select pickup time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFFFFC107)),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both pickup date and time.')),
      );
      return;
    }

    final details = BookingDetails(
      car: widget.car,
      pickupLocation: _pickupLocationController.text.trim(),
      dropLocation: _dropLocationController.text.trim(),
      pickupDate: _selectedDate!,
      pickupTime: _selectedTime!,
    );

    BookingFormScreen.temporaryBookings.add(details);

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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.car.pricePerDay.toStringAsFixed(2)} per day',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _pickupLocationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a pickup location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dropLocationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Drop Location',
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a drop location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _PickerTextField(
                controller: _dateController,
                label: 'Pickup Date',
                icon: Icons.calendar_today,
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              _PickerTextField(
                controller: _timeController,
                label: 'Pickup Time',
                icon: Icons.access_time,
                onTap: _selectTime,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable field to show a read-only text box that opens a picker dialog.
class _PickerTextField extends StatelessWidget {
  const _PickerTextField({
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
              'Your ${details.car.name} booking is confirmed!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _BookingInfoRow(
              label: 'Car',
              value: details.car.name,
            ),
            _BookingInfoRow(
              label: 'Pickup Location',
              value: details.pickupLocation,
            ),
            _BookingInfoRow(
              label: 'Drop Location',
              value: details.dropLocation,
            ),
            _BookingInfoRow(
              label: 'Pickup Date',
              value: _formatDate(details.pickupDate),
            ),
            _BookingInfoRow(
              label: 'Pickup Time',
              value: details.pickupTime.format(context),
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

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }
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
