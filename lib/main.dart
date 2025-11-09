import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/booking_details.dart';
import 'models/car.dart';
import 'services/api_service.dart';
import 'services/app_storage.dart';

const Color kPrimaryYellow = Color(0xFFFFC107);
const Color kDarkBackground = Color(0xFF0D0D0D);
const Color kCardSurface = Color(0xFF151515);
const LinearGradient kAppBackgroundGradient = LinearGradient(
  colors: <Color>[
    kDarkBackground,
    Color(0xFF090909),
    Color(0xFF11100B),
    Color(0xFFFFC107),
  ],
  stops: <double>[0.0, 0.45, 0.78, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const String kWatermarkText = 'Developed by Saurabh Kushwaha – Demo Version';

/// Reusable XL Cab logo badge rendered with vector shapes instead of bitmap assets.
class XLCabLogoBadge extends StatelessWidget {
  const XLCabLogoBadge({
    super.key,
    this.size = 128,
    this.outerGradient = const LinearGradient(
      colors: [kPrimaryYellow, Color(0xFFFFE082)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.iconColor = kPrimaryYellow,
  });

  /// Overall diameter of the circular badge.
  final double size;

  /// Gradient applied to the outer circle to mimic the former logo glow.
  final Gradient outerGradient;

  /// Color for the central taxi glyph.
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final double padding = size * 0.18;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: outerGradient,
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.35),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.04,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Icon(
            Icons.local_taxi,
            size: size * 0.46,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Entry point of the XL Cab application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  runApp(const XLCabApp());
}

/// Root widget configuring global theme, navigation, and initial screen.
class XLCabApp extends StatelessWidget {
  const XLCabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryYellow,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme)
        .apply(bodyColor: Colors.white, displayColor: Colors.white);

    return MaterialApp(
      title: 'XL Cab',
      theme: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: kPrimaryYellow,
          secondary: kPrimaryYellow,
        ),
        primaryColor: kPrimaryYellow,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        appBarTheme: baseTheme.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kPrimaryYellow,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: kCardSurface,
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryYellow,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: kPrimaryYellow, width: 1.4),
          ),
          labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white54),
        ),
        bottomNavigationBarTheme: baseTheme.bottomNavigationBarTheme.copyWith(
          backgroundColor: const Color(0xFF101010),
          selectedItemColor: kPrimaryYellow,
          unselectedItemColor: Colors.white54,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kPrimaryYellow,
          selectionColor: Color(0x33FFC107),
          selectionHandleColor: kPrimaryYellow,
        ),
      ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Container(
        decoration: const BoxDecoration(gradient: kAppBackgroundGradient),
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
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

/// Primary action button with a subtle press animation.
class AnimatedPrimaryButton extends StatefulWidget {
  const AnimatedPrimaryButton({
    required this.child,
    required this.onPressed,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.expand = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expand;

  @override
  State<AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<AnimatedPrimaryButton> {
  double _scale = 1;

  void _updateScale(bool isPressed) {
    if (widget.onPressed == null) {
      return;
    }
    setState(() => _scale = isPressed ? 0.96 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? Colors.black;

    Widget button = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        elevation: widget.onPressed == null ? 0 : 10,
        shadowColor: backgroundColor.withOpacity(0.45),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => _updateScale(true),
          onTapCancel: () => _updateScale(false),
          onTapUp: (_) => _updateScale(false),
          child: Padding(
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
              child: IconTheme(
                data: IconThemeData(color: foregroundColor),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

/// Footer widget used to display the persistent build watermark.
class WatermarkFooter extends StatelessWidget {
  const WatermarkFooter({
    super.key,
    this.includeBottomSafeArea = true,
    this.bottomSpacing = 0,
  });

  final bool includeBottomSafeArea;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double safeBottom = includeBottomSafeArea
        ? MediaQuery.of(context).padding.bottom
        : 0;
    final TextStyle baseStyle = theme.textTheme.labelSmall ??
        theme.textTheme.bodySmall ??
        const TextStyle(fontSize: 12);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        12 + bottomSpacing + safeBottom,
      ),
      child: Text(
        kWatermarkText,
        style: baseStyle.copyWith(
          color: Colors.white60,
          fontSize: 11.5,
          letterSpacing: 0.35,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Convenience widget that wraps screen content with optional safe areas and watermark.
class ScreenShell extends StatelessWidget {
  const ScreenShell({
    required this.child,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.includeBottomSafeArea = true,
    this.footerSpacing = 0,
    super.key,
  });

  final Widget child;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool includeBottomSafeArea;
  final double footerSpacing;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (safeAreaTop || safeAreaBottom) {
      content = SafeArea(top: safeAreaTop, bottom: safeAreaBottom, child: content);
    }

    return Column(
      children: [
        Expanded(child: content),
        WatermarkFooter(
          includeBottomSafeArea: includeBottomSafeArea,
          bottomSpacing: footerSpacing,
        ),
      ],
    );
  }
}

/// Simple login screen collecting credentials before showing the splash screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final StoredUser? storedUser = AppStorage.user.value;
    if (storedUser != null && storedUser.email.isNotEmpty) {
      _emailController.text = storedUser.email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _deriveDisplayName(String email) {
    final String localPart = email.split('@').first;
    final Iterable<String> segments = localPart
        .split(RegExp(r'[._-]+'))
        .where((String segment) => segment.isNotEmpty)
        .map((String segment) =>
            segment[0].toUpperCase() + segment.substring(1).toLowerCase());
    final String formatted = segments.join(' ');
    return formatted.isEmpty ? email : formatted;
  }

  Future<void> _handleLogin() async {
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }

    if (form.validate()) {
      FocusScope.of(context).unfocus();
      final String email = _emailController.text.trim();
      final String displayName = _deriveDisplayName(email);
      try {
        await AppStorage.setLastUser(name: displayName, email: email);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save your login. Please try again.'),
          ),
        );
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, SplashScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ScreenShell(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const XLCabLogoBadge(size: 138),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome to XL Cab',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to continue exploring premium rides and effortless bookings.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          offset: const Offset(0, 18),
                          blurRadius: 45,
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex =
                                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!emailRegex.hasMatch(text)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (_) => _handleLogin(),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (text.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          AnimatedPrimaryButton(
                            onPressed: _handleLogin,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Login'),
                                SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms),
            ),
          ),
        ),
      ),
    );
  }
}

/// Splash screen displaying the XL Cab logo with a fade-in animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

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
    final theme = Theme.of(context);
    return Scaffold(
      body: ScreenShell(
        safeAreaTop: false,
        safeAreaBottom: false,
        includeBottomSafeArea: true,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: kAppBackgroundGradient),
          child: Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const XLCabLogoBadge(
                    size: 162,
                    outerGradient: LinearGradient(
                      colors: [Color(0xFFFFF59D), kPrimaryYellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'XL Cab',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 900.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
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
      body: ScreenShell(
        safeAreaTop: true,
        safeAreaBottom: false,
        includeBottomSafeArea: false,
        footerSpacing: 8,
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
    _carsFuture = ApiService.getCars();
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

        return LayoutBuilder(
          builder: (context, constraints) {
            const maxContentWidth = 640.0;
            final horizontalPadding = constraints.maxWidth > maxContentWidth
                ? (constraints.maxWidth - maxContentWidth) / 2 + 24
                : 20.0;

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28,
                horizontalPadding,
                28,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                final delay = (index * 80).ms;
                return _CarCard(car: car)
                    .animate(delay: delay)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.08, curve: Curves.easeOut);
              },
            );
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F1F1F), Color(0xFF141414)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openDetails(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          car.primaryImageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.directions_car,
                              size: 64,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '\\$${car.pricePerDay.toStringAsFixed(0)}/day',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: kPrimaryYellow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          car.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_seat, size: 18),
                                  const SizedBox(width: 6),
                                  Text('${car.seats} seats'),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward, color: kPrimaryYellow.withOpacity(0.8)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AnimatedPrimaryButton(
                          onPressed: () => _openDetails(context),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
    return ValueListenableBuilder<List<BookingDetails>>(
      valueListenable: AppStorage.bookings,
      builder: (context, bookings, _) {
        final List<BookingDetails> ordered =
            List<BookingDetails>.from(bookings.reversed);

        if (ordered.isEmpty) {
          final theme = Theme.of(context);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 94,
                    width: 94,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [kPrimaryYellow, Color(0xFFFFE082)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.directions_car, size: 42, color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No bookings yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your confirmed rides will appear here once you make a booking.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            const maxWidth = 640.0;
            final double horizontalPadding = constraints.maxWidth > maxWidth
                ? (constraints.maxWidth - maxWidth) / 2 + 24
                : 20.0;

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28,
                horizontalPadding,
                28,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: ordered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final booking = ordered[index];
                final schedule =
                    '${_formatDate(booking.pickupDate)} · ${booking.pickupTime.format(context)}';
                final theme = Theme.of(context);

                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF191919), Color(0xFF111111)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kPrimaryYellow.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  const Icon(Icons.local_taxi, color: kPrimaryYellow),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.car.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    schedule,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _BookingMetaRow(
                          icon: Icons.place_outlined,
                          label: 'Pickup',
                          value: booking.pickupLocation,
                        ),
                        const SizedBox(height: 12),
                        _BookingMetaRow(
                          icon: Icons.flag_outlined,
                          label: 'Drop',
                          value: booking.dropLocation,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: (index * 90).ms)
                    .fadeIn(duration: 380.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.08, curve: Curves.easeOut);
              },
            );
          },
        );
      },
    );
  }
}

class _BookingMetaRow extends StatelessWidget {
  const _BookingMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kPrimaryYellow.withOpacity(0.85), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.event_seat, color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.car.seats} seats',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kPrimaryYellow.withOpacity(0.2),
                                kPrimaryYellow.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kPrimaryYellow.withOpacity(0.4)),
                          ),
                          child: Text(
                            '\$${widget.car.pricePerDay.toStringAsFixed(2)}/day',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: kPrimaryYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.car.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.55,
                        color: Colors.white70,
                      ),
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedPrimaryButton(
                onPressed: _onBookNow,
                child: const Text('Book Now'),
              ),
              const WatermarkFooter(
                includeBottomSafeArea: false,
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

  Future<void> _submitForm() async {
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

    try {
      await ApiService.createBooking(details);
      await AppStorage.addBooking(details);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save booking. Please try again.'),
        ),
      );
      return;
    }
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      BookingConfirmationScreen.routeName,
      arguments: details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.car.name}')),
      body: ScreenShell(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: _cardDecoration,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.car.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${widget.car.pricePerDay.toStringAsFixed(2)} per day',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
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
                AnimatedPrimaryButton(
                  onPressed: _submitForm,
                  child: const Text('Confirm Booking'),
                ),
              ],
            ),
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
      body: ScreenShell(
        child: Padding(
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
              child: AnimatedPrimaryButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.routeName,
                  (route) => false,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
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
      body: const ScreenShell(child: ProfileContent()),
    );
  }
}

/// Shared profile layout used across the profile tab and routed screen.
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = ProfileScreen._bookingHistory;

    return ValueListenableBuilder<StoredUser?>(
      valueListenable: AppStorage.user,
      builder: (context, storedUser, _) {
        final _MockUser fallback = ProfileScreen._user;
        final _MockUser displayUser = _MockUser(
          name: (storedUser?.name.isNotEmpty ?? false)
              ? storedUser!.name
              : fallback.name,
          email: (storedUser?.email.isNotEmpty ?? false)
              ? storedUser!.email
              : fallback.email,
          phone: fallback.phone,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            const maxWidth = 720.0;
            final horizontalPadding = constraints.maxWidth > maxWidth
                ? (constraints.maxWidth - maxWidth) / 2 + 24
                : 20.0;

            return SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 48),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(user: displayUser)
                      .animate()
                      .fadeIn(duration: 450.ms, curve: Curves.easeOut)
                      .slideY(begin: 0.08, curve: Curves.easeOut),
                  const SizedBox(height: 32),
                  Text(
                    'Booking History',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (history.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration,
                      child: Text(
                        'No bookings yet. Start exploring our cars!',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ).animate().fadeIn(duration: 400.ms)
                  else
                    Column(
                      children: [
                        for (var i = 0; i < history.length; i++)
                          _BookingHistoryCard(item: history[i])
                              .animate(delay: (i * 90).ms)
                              .fadeIn(duration: 360.ms, curve: Curves.easeOut)
                              .slideY(begin: 0.08, curve: Curves.easeOut),
                      ],
                    ),
                  const SizedBox(height: 36),
                  AnimatedPrimaryButton(
                    expand: false,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    foregroundColor: kPrimaryYellow,
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('Log Out'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  gradient: const LinearGradient(
    colors: [Color(0xFF1C1C1C), Color(0xFF121212)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: Colors.white.withOpacity(0.08)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.45),
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
  ],
);

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final _MockUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kPrimaryYellow, Color(0xFFFFE082)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.person, size: 40, color: Colors.black),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ProfileDetailRow(
              icon: Icons.phone,
              label: 'Phone',
              value: user.phone,
            ),
            _ProfileDetailRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = dense ? Colors.transparent : Colors.white.withOpacity(0.05);
    final iconBackground = Colors.white.withOpacity(dense ? 0.08 : 0.12);
    final borderRadius = BorderRadius.circular(dense ? 14 : 18);
    final horizontalPadding = dense ? 8.0 : 16.0;
    final verticalPadding = dense ? 8.0 : 12.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: dense ? 4 : 6),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryYellow, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({required this.item});

  final _BookingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCompleted = item.status == 'Completed';
    final Color statusColor = isCompleted ? const Color(0xFF34D399) : kPrimaryYellow;

    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryYellow.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_car, color: kPrimaryYellow),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.carName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.dateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.45)),
                  ),
                  child: Text(
                    item.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ProfileDetailRow(
              icon: Icons.location_on,
              label: 'Pickup',
              value: item.pickupLocation,
              dense: true,
            ),
            _ProfileDetailRow(
              icon: Icons.flag,
              label: 'Drop-off',
              value: item.dropLocation,
              dense: true,
            ),
          ],
        ),
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
