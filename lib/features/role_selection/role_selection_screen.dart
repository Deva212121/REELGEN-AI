import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../influencer_dashboard/influencer_dashboard_screen.dart'; // We can construct a unified main shell in main.dart or direct to home
import '../../main.dart'; // Direct to unified platform navigator shell

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final userName = user?.displayName ?? 'GEN CREATOR';

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
                      color: const Color(0xFFC4FF62).withOpacity(0.12),
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
                    fontWeight: FontWeight.black,
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
                // Mode Selection Buttons with unique styling and details
                _buildRoleCard(
                  context: context,
                  title: 'Influencer Module',
                  role: 'INFLUENCER',
                  desc: 'List products, request briefs, generate AI reels, track clicks and claim orders volume.',
                  icon: Icons.movie_creation_outlined,
                  accentColor: const Color(0xFFD0BCFF),
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  context: context,
                  title: 'Brand Vendor Module',
                  role: 'VENDOR',
                  desc: 'Publish products, generate OTP keys, manage influencer approval list, and track shipping parcels.',
                  icon: Icons.storefront,
                  accentColor: const Color(0xFFC4FF62),
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  context: context,
                  title: 'Platform Inspector Admin',
                  role: 'ADMIN',
                  desc: 'Audit transaction activity logs, global KPIs, parcel reports, and oversee system allocations.',
                  icon: Icons.admin_panel_settings_outlined,
                  accentColor: const Color(0xFFFDA4AF),
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
  }) {
    return InkWell(
      onTap: () {
        final service = FirebaseService();
        service.switchRole(role);
        // Navigate across to unified mainframe shell
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const UnifiedParentNavigationShell()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2930),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF49454F), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
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
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF938F99), size: 14),
          ],
        ),
      ),
    );
  }
}
