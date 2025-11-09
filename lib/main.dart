import 'dart:convert';
import 'dart:math' as math;

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

/// Available navigation tabs for the primary scaffold.
enum HomeTab { home, bookings, profile }

/// Home screen hosting the bottom navigation and tab content.
class HomeScreen extends StatefulWidget {
  const HomeScreen({this.initialTab = HomeTab.home, super.key});

  static const String routeName = '/home';

  final HomeTab initialTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentTab = HomeTab.values[index];
    });
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_currentTab) {
      case HomeTab.home:
        return AppBar(
          title: const Text('Available Rides'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
              onPressed: () => _onTabSelected(HomeTab.profile.index),
            ),
          ],
        );
      case HomeTab.bookings:
        return AppBar(
          title: const Text('My Bookings'),
        );
      case HomeTab.profile:
        return ProfileScreen.buildAppBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab.index,
          children: const [
            HomeCatalogueTab(),
            BookingListScreen(),
            ProfileContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index,
        onTap: _onTabSelected,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Tab content displaying the list of available cars for booking.
class HomeCatalogueTab extends StatefulWidget {
  const HomeCatalogueTab({super.key});

  @override
  State<HomeCatalogueTab> createState() => _HomeCatalogueTabState();
}

class _HomeCatalogueTabState extends State<HomeCatalogueTab> {
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
    return FutureBuilder<List<Car>>(
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

/// Tab displaying bookings made during the current session.
class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final bookings =
        List<BookingDetails>.from(BookingFormScreen.temporaryBookings.reversed);

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.directions_car, size: 64, color: Color(0xFFFFC107)),
              SizedBox(height: 16),
              Text(
                'No bookings yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Your confirmed rides will appear here once you make a booking.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final schedule =
            '${_formatDate(booking.pickupDate)} · ${booking.pickupTime.format(context)}';

        return Container(
          decoration: _cardDecoration.copyWith(
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_taxi, color: Color(0xFFFFC107)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      booking.car.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _BookingInfoRow(label: 'Schedule', value: schedule),
              _BookingInfoRow(label: 'Pickup', value: booking.pickupLocation),
              _BookingInfoRow(label: 'Drop-off', value: booking.dropLocation),
            ],
          ),
        );
      },
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
class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({required this.details, super.key});

  static const String routeName = '/booking-confirmation';

  final BookingDetails details;

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScaleAnimation;
  late final Animation<double> _contentFadeAnimation;
  late final Animation<double> _confettiProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _iconScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _contentFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1, curve: Curves.easeIn),
    );
    _confettiProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.8, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BookingDetails details = widget.details;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: _ConfettiBurst(animation: _confettiProgress),
                  ),
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.0)
                        .animate(_iconScaleAnimation),
                    child: FadeTransition(
                      opacity: _contentFadeAnimation,
                      child: const Text(
                        '✅',
                        style: TextStyle(fontSize: 96),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your booking has been successfully placed!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                ],
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomeScreen.routeName,
                    (route) => false,
                  ),
                  child: const Text('Back to Home'),
                ),
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

class _ConfettiBurst extends StatelessWidget {
  const _ConfettiBurst({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: _ConfettiPainter(progress: animation.value),
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static const List<_ConfettiPiece> _pieces = <_ConfettiPiece>[
    _ConfettiPiece(angle: -75, maxDistance: 120, sway: 10, fallSpeed: 18,
        color: Color(0xFFFFC107), size: 6),
    _ConfettiPiece(angle: -40, maxDistance: 140, sway: 6, fallSpeed: 26,
        color: Color(0xFF4CAF50), size: 5),
    _ConfettiPiece(angle: 0, maxDistance: 150, sway: 8, fallSpeed: 20,
        color: Color(0xFFFF5722), size: 7),
    _ConfettiPiece(angle: 40, maxDistance: 140, sway: 7, fallSpeed: 24,
        color: Color(0xFF29B6F6), size: 5.5),
    _ConfettiPiece(angle: 75, maxDistance: 120, sway: 9, fallSpeed: 18,
        color: Color(0xFFFFEB3B), size: 6.5),
    _ConfettiPiece(angle: -120, maxDistance: 110, sway: 6, fallSpeed: 22,
        color: Color(0xFFFF4081), size: 5.5),
    _ConfettiPiece(angle: 120, maxDistance: 110, sway: 6, fallSpeed: 22,
        color: Color(0xFF8BC34A), size: 5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    for (final _ConfettiPiece piece in _pieces) {
      final double radians = piece.angle * math.pi / 180;
      final double distance = piece.maxDistance * progress;
      final double swayOffset =
          math.sin((progress * 6 * math.pi) + radians) * piece.sway;
      final double x = center.dx + math.cos(radians) * distance + swayOffset;
      final double y = center.dy + math.sin(radians) * distance +
          (progress * piece.fallSpeed);
      final Paint paint = Paint()
        ..color = piece.color.withOpacity((1 - progress).clamp(0, 1).toDouble());
      canvas.drawCircle(Offset(x, y), piece.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.angle,
    required this.maxDistance,
    required this.sway,
    required this.fallSpeed,
    required this.color,
    required this.size,
  });

  final double angle;
  final double maxDistance;
  final double sway;
  final double fallSpeed;
  final Color color;
  final double size;
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

/// Profile screen displaying high-level user information and booking history.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  static const _MockUser _user = _MockUser(
    name: 'Alex Johnson',
    email: 'alex.johnson@example.com',
    phone: '+1 (555) 987-1234',
  );

  static const List<_BookingHistoryItem> _bookingHistory = <_BookingHistoryItem>[
    _BookingHistoryItem(
      carName: 'Tesla Model 3',
      pickupLocation: 'Downtown Hub',
      dropLocation: 'Airport Terminal 1',
      dateLabel: '12 Aug 2024 · 10:00 AM',
      status: 'Completed',
    ),
    _BookingHistoryItem(
      carName: 'BMW 5 Series',
      pickupLocation: 'City Center',
      dropLocation: 'Harbor Bay',
      dateLabel: '28 Jul 2024 · 6:30 PM',
      status: 'Completed',
    ),
    _BookingHistoryItem(
      carName: 'Mercedes GLC',
      pickupLocation: 'Corporate Plaza',
      dropLocation: 'Downtown Hotel',
      dateLabel: '04 Jul 2024 · 8:15 AM',
      status: 'Upcoming',
    ),
  ];

  static PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text('Profile'),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit profile',
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: const SafeArea(
        child: ProfileContent(),
      ),
    );
  }
}

/// Shared profile layout used across the profile tab and routed screen.
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(user: ProfileScreen._user),
          const SizedBox(height: 24),
          const Text(
            'Booking History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (ProfileScreen._bookingHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration,
              child: const Text('No bookings yet. Start exploring our cars!'),
            )
          else
            Column(
              children: ProfileScreen._bookingHistory
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BookingHistoryCard(item: item),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFC107),
                side: const BorderSide(color: Color(0xFFFFC107)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const BoxDecoration _cardDecoration = BoxDecoration(
  color: Color(0xFF1F1F1F),
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(BorderSide(color: Colors.white10)),
  boxShadow: [
    const BoxShadow(
      color: Colors.black54,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ],
);

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final _MockUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFC107),
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProfileDetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: user.phone,
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(
            icon: Icons.email,
            label: 'Email',
            value: user.email,
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({required this.item});

  final _BookingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration.copyWith(
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: Color(0xFFFFC107)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.carName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: item.status == 'Completed'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: item.status == 'Completed' ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(
            icon: Icons.calendar_today,
            label: 'Schedule',
            value: item.dateLabel,
          ),
          const SizedBox(height: 8),
          _ProfileDetailRow(
            icon: Icons.location_on,
            label: 'Pickup',
            value: item.pickupLocation,
          ),
          const SizedBox(height: 8),
          _ProfileDetailRow(
            icon: Icons.flag,
            label: 'Drop-off',
            value: item.dropLocation,
          ),
        ],
      ),
    );
  }
}

class _MockUser {
  const _MockUser({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;
}

class _BookingHistoryItem {
  const _BookingHistoryItem({
    required this.carName,
    required this.pickupLocation,
    required this.dropLocation,
    required this.dateLabel,
    required this.status,
  });

  final String carName;
  final String pickupLocation;
  final String dropLocation;
  final String dateLabel;
  final String status;
}
