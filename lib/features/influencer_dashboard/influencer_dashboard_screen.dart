import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class InfluencerDashboardScreen extends StatefulWidget {
  final Future<void> Function(int index, {int? subTab}) onSwitchTab; // Supports switching tab easily
  const InfluencerDashboardScreen({super.key, required this.onSwitchTab});

  @override
  State<InfluencerDashboardScreen> createState() => _InfluencerDashboardScreenState();
}

class _InfluencerDashboardScreenState extends State<InfluencerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    final affiliatesCount = service.affiliateLinks.length;
    
    // Compute total metrics dynamically to offer instant interaction
    int totalClicks = 0;
    int totalOrders = 0;
    double totalRevenue = 0.0;
    for (var a in service.affiliateLinks) {
      totalClicks += a.clicks;
      totalOrders += a.orders;
      totalRevenue += a.businessAmount;
    }
    final conversionRate = totalClicks > 0 ? (totalOrders / totalClicks) * 100 : 0.0;
    final influencerRevenue = totalRevenue * 0.15; // Simulated 15% revenue model

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildMetricsGrid(
            clicks: totalClicks,
            orders: totalOrders,
            conversion: conversionRate,
            revenue: totalRevenue,
            earnings: influencerRevenue,
            links: affiliatesCount,
          ),
          const SizedBox(height: 24),
          const Text(
            'Launch Creator Studios',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildStudioLaunchGrid(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF381E72), Color(0xFF130F26)],
        ),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Welcome, Active Creator!',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.black),
          ),
          SizedBox(height: 6),
          Text(
            'Generate advertising content, submit campaign proposals, verify secure OTPs, and track direct commission analytics.',
            style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid({
    required int clicks,
    required int orders,
    required double conversion,
    required double revenue,
    required double earnings,
    required int links,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        child: [
          const Text('Real-time Sponsored Performance', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildKPIBox('Sponsor Links', links.toString(), '+1 active', Colors.orangeAccent),
              const SizedBox(width: 8),
              _buildKPIBox('Total Clicks', clicks.toString(), 'Real-time', Colors.cyan),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKPIBox('Total Orders', orders.toString(), 'Processed', const Color(0xFFC4FF62)),
              const SizedBox(width: 8),
              _buildKPIBox('Conversion Rate', '${conversion.toStringAsFixed(1)}%', 'Performance', Colors.pinkAccent),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKPIBox('Contract Business', '\$${revenue.toStringAsFixed(2)}', 'Sales vol', Colors.cyanAccent),
              const SizedBox(width: 8),
              _buildKPIBox('Creator Earnings', '\$${earnings.toStringAsFixed(2)}', 'Est. 15%', const Color(0xFFC4FF62)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIBox(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0x13FFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.black)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioLaunchGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.45,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildLaunchCard('AI Script Generator', Icons.bolt, const Color(0xFFD0BCFF), () => widget.onSwitchTab(1, subTab: 0)),
        _buildLaunchCard('Voice Cloner', Icons.keyboard_voice, const Color(0xFFFF4B8A), () => _triggerNavigateDialog(context, 'VOICE')),
        _buildLaunchCard('Image to Video', Icons.slideshow, const Color(0xFFC4FF62), () => _triggerNavigateDialog(context, 'IMG2VID')),
        _buildLaunchCard('Photoshoot Studio', Icons.camera, Colors.pinkAccent, () => _triggerNavigateDialog(context, 'PHOTOSHOOT')),
        _buildLaunchCard('Apply Sponsorships', Icons.shopping_bag_outlined, Colors.amber, () => _triggerNavigateDialog(context, 'PRODUCTS')),
        _buildLaunchCard('Verify OTP Keys', Icons.lock_open, Colors.emerald, () => _triggerNavigateDialog(context, 'OTP')),
      ],
    );
  }

  Widget _buildLaunchCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2930),
          border: Border.all(color: const Color(0xFF49454F)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _triggerNavigateDialog(BuildContext context, String actionKey) {
    // Shows alert dialog confirming redirect
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        dropdownColor: const Color(0xFF2B2930),
        title: Text('Redirect to $actionKey Console', style: const TextStyle(color: Colors.white, fontSize: 15)),
        content: Text('Would you like to load the active $actionKey workshop module inside the platform menu?', style: const TextStyle(color: Color(0xFF938F99), fontSize: 12)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC4FF62)),
            child: const Text('Load', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              if (actionKey == 'VOICE') widget.onSwitchTab(1, subTab: 1); // tab index 1 is create!
              if (actionKey == 'IMG2VID') widget.onSwitchTab(1, subTab: 2);
              if (actionKey == 'PHOTOSHOOT') widget.onSwitchTab(1, subTab: 3);
              if (actionKey == 'PRODUCTS') widget.onSwitchTab(2, subTab: 1); // tab index 2 is projects!
              if (actionKey == 'OTP') widget.onSwitchTab(2, subTab: 2);
            },
          )
        ],
        backgroundColor: const Color(0xFF2B2930),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
