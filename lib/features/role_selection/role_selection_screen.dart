import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../main.dart';
import '../super_admin_dashboard/super_admin_dashboard_screen.dart';
import '../sub_admin_dashboard/sub_admin_dashboard_screen.dart';
import '../vendor_dashboard/vendor_dashboard_screen.dart';
import '../admin_dashboard/admin_dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final userRole = user?.role ?? 'INFLUENCER';
    final userName = user?.displayName ?? 'GEN CREATOR';

    // Sub-Admin → direct SubAdminDashboard
    if (userRole == 'SUB_ADMIN') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SubAdminDashboardScreen(),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Vendor → direct VendorDashboard
    if (userRole == 'VENDOR') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const VendorDashboardScreen(),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Influencer → direct InfluencerDashboard (UnifiedParentNavigationShell)
    if (userRole == 'INFLUENCER') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const UnifiedParentNavigationShell(),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Admin → direct AdminDashboard
    if (userRole == 'ADMIN') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Baaki roles (Super Admin) ke liye normal screen
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0A1E), Color(0xFF050308)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4FF62).withAlpha((0.12 * 255).round()),
                      border: Border.all(color: const Color(0xFFC4FF62), width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Welcome back, $userName!',
                      style: const TextStyle(
                        color: Color(0xFFC4FF62),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Your Workspace Context',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Each dashboard accesses unique Cloud Firestore document structures configured for different roles.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF938F99),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 40),
                _buildRoleCard(
                  context: context,
                  title: 'Super Admin',
                  role: 'SUPER_ADMIN',
                  desc: 'Full platform control, partner management, inventory allocation, and global analytics.',
                  icon: Icons.dashboard_customize,
                  accentColor: const Color(0xFFFFD700),
                  isSuperAdmin: true,
                ),
                const Spacer(),
                const Text(
                  'You can easily switch roles at the top of the portal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String role,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required bool isSuperAdmin,
  }) {
    return InkWell(
      onTap: () {
        if (role == 'SUPER_ADMIN') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SuperAdminDashboardScreen(),
            ),
          );
        } else {
          final service = FirebaseService();
          service.switchRole(role);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const UnifiedParentNavigationShell(),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSuperAdmin
              ? const Color(0xFF1A1A2E).withAlpha((0.8 * 255).round())
              : const Color(0xFF2B2930),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSuperAdmin ? const Color(0xFFFFD700) : const Color(0xFF49454F),
            width: isSuperAdmin ? 2 : 1,
          ),
          boxShadow: isSuperAdmin
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withAlpha((0.2 * 255).round()),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Color(0xFF938F99),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSuperAdmin ? Icons.star : Icons.arrow_forward_ios,
              color: isSuperAdmin ? const Color(0xFFFFD700) : const Color(0xFF938F99),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}