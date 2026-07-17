import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'models/product_model.dart';
import 'services/firebase_service.dart';
import 'services/influencer_product_service.dart';
import 'features/login/login_screen.dart';
import 'features/influencer_dashboard/influencer_dashboard_screen.dart';
import 'features/vendor_dashboard/vendor_dashboard_screen.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';
import 'features/super_admin_dashboard/super_admin_dashboard_screen.dart';
import 'features/sub_admin_dashboard/sub_admin_dashboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/ai_script_generator/sellore_ai_screen.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/product_promotion_otp/otp_verification_screen.dart';
import 'features/influencer_business_tracking/business_tracking_screen.dart';
import 'features/reel_tracking/reel_tracking_screen.dart';
import 'features/reel_preview/reel_preview_screen.dart';
import 'features/parcel_tracking/parcel_tracking_screen.dart';
import 'features/sound_library/sound_library_screen.dart';
import 'features/customer_order/customer_order_screen.dart';
import 'features/notifications/notification_screen.dart';
import 'features/search/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    if (kDebugMode) {
      print('Crashlytics: ${errorDetails.exception}');
    }
  };

  if (!kDebugMode) {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  runApp(const ReelGenApp());
}

class ReelGenApp extends StatelessWidget {
  const ReelGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SelloreAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD0BCFF),
        scaffoldBackgroundColor: const Color(0xFF130F26),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD0BCFF),
          secondary: Color(0xFFFF4B8A),
          surface: Color(0xFF2B2930),
          error: Colors.redAccent,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'sans-serif', color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/customer-order': (context) {
          final productId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return CustomerOrderScreen(productId: productId);
        },
        '/notifications': (context) => const NotificationScreen(),
        '/search': (context) => const SearchScreen(),
        '/otp-verification': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return OtpVerificationScreen(
            verificationId: args?['verificationId'] ?? '',
            email: args?['email'] ?? '',
            password: args?['password'] ?? '',
            role: args?['role'] ?? '',
          );
        },
      },
    );
  }
}

class UnifiedParentNavigationShell extends StatefulWidget {
  const UnifiedParentNavigationShell({super.key});

  @override
  State<UnifiedParentNavigationShell> createState() => _UnifiedParentNavigationShellState();
}

class _UnifiedParentNavigationShellState extends State<UnifiedParentNavigationShell> {
  int _currentIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();
  final InfluencerProductService _influencerProductService =
      InfluencerProductService();

  int _activeCreateSubTab = 0;
  int _activeProjectsSubTab = 0;
  int _activeAnalyticsSubTab = 0;
  bool _disclaimerAccepted = false;

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _switchCoreTabFromOutside(int index, {int? subTab}) {
    setState(() {
      _currentIndex = index;
      if (subTab != null) {
        if (index == 1) {
          _activeCreateSubTab = subTab;
        } else if (index == 2) {
          _activeProjectsSubTab = subTab;
        } else if (index == 3) {
          _activeAnalyticsSubTab = subTab;
        }
      }
    });
  }

  Future<void> _activateCatalogProduct(Product product) async {
    await _influencerProductService.activateProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;
    final currentRole = user?.role ?? 'INFLUENCER';
    final normalizedRole = _normalizeRole(currentRole);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF130F26),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(colors: [Color(0xFFD0BCFF), Color(0xFFFF4B8A)]),
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'SelloreAI',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF381E72),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD0BCFF), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield, size: 10, color: Color(0xFFC4FF62)),
                  const SizedBox(width: 4),
                  Text(
                    currentRole,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF130F26), Color(0xFF07040B)],
          ),
        ),
        child: _buildBodyTab(currentRole),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2B2930),
        selectedItemColor: const Color(0xFFC4FF62),
        unselectedItemColor: const Color(0xFF938F99),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: _getBottomNavItems(normalizedRole),
      ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavItems(String role) {
    if (role == 'INFLUENCER') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.video_call_outlined), activeIcon: Icon(Icons.video_call), label: 'Create'),
        BottomNavigationBarItem(icon: Icon(Icons.movie_filter_outlined), activeIcon: Icon(Icons.movie_filter), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analytics'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    }
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analytics'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  Widget _buildBodyTab(String role) {
    final normalizedRole = _normalizeRole(role);

    switch (_currentIndex) {
      case 0:
        if (normalizedRole == 'INFLUENCER') return const InfluencerDashboardScreen();
        if (normalizedRole == 'VENDOR') return const VendorDashboardScreen();
        if (normalizedRole == 'ADMIN') return const AdminDashboardScreen();
        if (normalizedRole == 'SUPER_ADMIN') return const SuperAdminDashboardScreen();
        if (normalizedRole == 'SUB_ADMIN') return const SubAdminDashboardScreen();
        return const Center(child: Text('Workspace loading...'));

      case 1:
        if (normalizedRole != 'INFLUENCER') {
          return const Center(child: Text('Access Denied'));
        }
        return Column(
          children: [
            _buildHorizontalSubNav(
              currentIndex: _activeCreateSubTab,
              onTap: (val) => setState(() => _activeCreateSubTab = val),
              items: ['SelloreAI', 'Sound Library'],
            ),
            Expanded(
              child: IndexedStack(
                index: _activeCreateSubTab,
                children: const [
                  SelloreAIScreen(),
                  SoundLibraryScreen(),
                ],
              ),
            ),
          ],
        );

      case 2:
        if (normalizedRole != 'INFLUENCER') {
          return const Center(child: Text('Access Denied'));
        }
        return Column(
          children: [
            _buildHorizontalSubNav(
              currentIndex: _activeProjectsSubTab,
              onTap: (val) => setState(() => _activeProjectsSubTab = val),
              items: ['Reels Play', 'Catalog', 'Contract OTP', 'Track Cargo'],
            ),
            Expanded(
              child: IndexedStack(
                index: _activeProjectsSubTab,
                children: [
                  const ReelPreviewScreen(),
                  CatalogScreen.influencer(
                    onSellProduct: _activateCatalogProduct,
                  ),
                  const OtpVerificationScreen(
                    verificationId: '',
                    email: '',
                    password: '',
                    role: '',
                  ),
                  const ParcelTrackingScreen(),
                ],
              ),
            ),
          ],
        );

      case 3:
        return Column(
          children: [
            _buildHorizontalSubNav(
              currentIndex: _activeAnalyticsSubTab,
              onTap: (val) => setState(() => _activeAnalyticsSubTab = val),
              items: ['Conversions Invoices', 'Social Reel Reach'],
            ),
            Expanded(
              child: IndexedStack(
                index: _activeAnalyticsSubTab,
                children: const [
                  BusinessTrackingScreen(),
                  ReelTrackingScreen(),
                ],
              ),
            ),
          ],
        );

      case 4:
        return const ProfileScreen();

      default:
        return const Center(child: Text('Hub section loading...'));
    }
  }

  String _normalizeRole(String role) {
    if (role == 'CREATOR') return 'INFLUENCER';
    if (role == 'MERCHANT') return 'VENDOR';
    if (role == 'AUDITOR') return 'ADMIN';
    return role;
  }

  Widget _buildHorizontalSubNav({
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<String> items,
  }) {
    return Container(
      height: 44,
      color: const Color(0xFF2B2930),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isSelected = currentIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFFC4FF62) : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                items[index],
                style: TextStyle(
                  color: isSelected ? const Color(0xFFC4FF62) : const Color(0xFF938F99),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
