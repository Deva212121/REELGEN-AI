import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'features/login/login_screen.dart';
import 'features/role_selection/role_selection_screen.dart';
import 'features/influencer_dashboard/influencer_dashboard_screen.dart';
import 'features/vendor_dashboard/vendor_dashboard_screen.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';
import 'features/ai_script_generator/script_generator_screen.dart';
import 'features/voice_upload/voice_upload_screen.dart';
import 'features/image_to_video/image_to_video_screen.dart';
import 'features/photoshoot_studio/photoshoot_studio_screen.dart';
import 'features/product_selection/product_selection_screen.dart';
import 'features/product_promotion_otp/otp_verification_screen.dart';
import 'features/influencer_business_tracking/business_tracking_screen.dart';
import 'features/reel_tracking/reel_tracking_screen.dart';
import 'features/reel_preview/reel_preview_screen.dart';
import 'features/avatar_clone/avatar_clone_screen.dart';
import 'features/parcel_tracking/parcel_tracking_screen.dart';
import 'features/sound_library/sound_library_screen.dart';
import 'features/advanced_upload/advanced_upload_screen.dart';


void main() {
  runApp(const ReelGeneratorApp());
}

class ReelGeneratorApp extends StatelessWidget {
  const ReelGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REELGEN AI',
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
      home: const LoginScreen(), // Start securely at Login
    );
  }
}

// ------------------------------------
// UNIFIED PLATFORM APP NAVIGATOR SHELL
// ------------------------------------
class UnifiedParentNavigationShell extends StatefulWidget {
  const UnifiedParentNavigationShell({super.key});

  @override
  State<UnifiedParentNavigationShell> createState() => _UnifiedParentNavigationShellState();
}

class _UnifiedParentNavigationShellState extends State<UnifiedParentNavigationShell> {
  int _currentIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();

  // Sub-Navigation parameters inside tabs
  int _activeCreateSubTab = 0; // 0=Script, 1=Voice, 2=ImageToVideo, 3=Photoshoot, 4=Avatar
  int _activeProjectsSubTab = 0; // 0=Reel Preview, 1=Sponsors, 2=OTP Contract Secure
  int _activeAnalyticsSubTab = 0; // 1=Invoicing Revenue, 2=Reel Reach Graphs
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

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;
    final currentRole = user?.role ?? 'INFLUENCER';
    final name = user?.displayName ?? 'GEN CREATOR';

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
              'REELGEN AI',
              style: TextStyle(fontWeight: FontWeight.black, fontSize: 16, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          // Dynamic role contextual indicator
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.video_call_outlined), activeIcon: Icon(Icons.video_call), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_filter_outlined), activeIcon: Icon(Icons.movie_filter), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBodyTab(String role) {
    switch (_currentIndex) {
      case 0: // Home Tab context based on role
        if (role == 'INFLUENCER') return InfluencerDashboardScreen(onSwitchTab: (idx, {subTab}) async => _switchCoreTabFromOutside(idx, subTab: subTab));
        if (role == 'VENDOR') return const VendorDashboardScreen();
        if (role == 'ADMIN') return const AdminDashboardScreen();
        return const Center(child: Text('Workspace loading...'));

      case 1: // Create Tab Hub
        return Column(
          children: [
            _buildHorizontalSubNav(
              currentIndex: _activeCreateSubTab,
              onTap: (val) => setState(() => _activeCreateSubTab = val),
              items: ['AI Script', 'Voice Cloner', 'Slideshow', 'Studio Shoot', 'Avatar Profile', 'Sound Library', 'Advanced Upload'],
            ),
            Expanded(
              child: IndexedStack(
                index: _activeCreateSubTab,
                children: const [
                  ScriptGeneratorScreen(),
                  VoiceUploadScreen(),
                  ImageToVideoScreen(),
                  PhotoshootStudioScreen(),
                  AvatarCloneScreen(),
                  SoundLibraryScreen(),
                  AdvancedUploadScreen(),
                ],
              ),
            ),
          ],
        );

      case 2: // Projects - Link tracking & approvals
        return Column(
          children: [
            _buildHorizontalSubNav(
              currentIndex: _activeProjectsSubTab,
              onTap: (val) => setState(() => _activeProjectsSubTab = val),
              items: ['Reels Play', 'Marketplace', 'Contract OTP', 'Track Cargo'],
            ),
            Expanded(
              child: IndexedStack(
                index: _activeProjectsSubTab,
                children: const [
                  ReelPreviewScreen(),
                  ProductSelectionScreen(),
                  OtpVerificationScreen(),
                  ParcelTrackingScreen(),
                ],
              ),
            ),
          ],
        );

      case 3: // Analytics
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

      case 4: // Profile & switch role
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeaderCard(),
              const SizedBox(height: 20),
              _buildRoleSwitcherCard(role),
              const SizedBox(height: 20),
              _buildDisclaimerCard(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  _firebaseService.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('SECURE SIGN OUT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

      default:
        return const Center(child: Text('Hub section loading...'));
    }
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

  Widget _buildProfileHeaderCard() {
    final user = _firebaseService.currentUser;
    final name = user?.displayName ?? 'CREATOR';
    final email = user?.email ?? 'creator@reelgen.ai';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        border: Border.all(color: const Color(0xFF49454F)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF381E72)),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.black)),
                Text(email, style: const TextStyle(color: Color(0xFF938F99), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSwitcherCard(String active) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        border: Border.all(color: const Color(0xFF49454F)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Switch Workplace Context on Fly', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRoleSwitchBtn('INFLUENCER', 'Creator', active == 'INFLUENCER'),
              _buildRoleSwitchBtn('VENDOR', 'Merchant', active == 'VENDOR'),
              _buildRoleSwitchBtn('ADMIN', 'Auditor', active == 'ADMIN'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRoleSwitchBtn(String roleKey, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _firebaseService.switchRole(roleKey);
          setState(() {});
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF381E72) : const Color(0x13FFFFFF),
            border: Border.all(color: isSelected ? const Color(0xFFD0BCFF) : const Color(0xFF49454F)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF938F99),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        border: Border.all(color: const Color(0xFF49454F)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.gavel_outlined, color: Color(0xFFFF4B8A), size: 18),
              SizedBox(width: 8),
              Text('CONTENT DISCLAIMER POLICY', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '"I confirm that I own this content or have permission to use it. I am responsible for any copyright or legal issue related to uploaded content."',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontStyle: FontStyle.italic, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Checkbox(
                value: _disclaimerAccepted,
                activeColor: const Color(0xFFFF4B8A),
                onChanged: (val) => setState(() => _disclaimerAccepted = val!),
              ),
              const Expanded(
                child: Text('I agree to the copyright and legal conditions of ReelGen AI.', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
