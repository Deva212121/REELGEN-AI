import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    final logs = service.firestoreLogs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPlatformStatusCard(service),
          const SizedBox(height: 20),
          _buildDatabaseAuditLogViewer(logs),
        ],
      ),
    );
  }

  Widget _buildPlatformStatusCard(FirebaseService service) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.insights, color: Color(0xFFFDA4AF), size: 20),
              SizedBox(width: 8),
              Text('System Global Allocations', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricVal('MARKETPLACE POOL', service.marketplaceProducts.length.toString()),
              _buildMetricVal('CAMPAIGNS CODES', service.productPromotions.length.toString()),
              _buildMetricVal('RECORDS SYNCED', (service.marketplaceProducts.length + service.productPromotions.length + service.affiliateLinks.length).toString()),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Platform Execution KPIs', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildProgressLine('Influencer Active Enrolments', 0.82, const Color(0xFFFF4B8A)),
          const SizedBox(height: 8),
          _buildProgressLine('AI video clips generated / day', 0.65, const Color(0xFFD0BCFF)),
          const SizedBox(height: 8),
          _buildProgressLine('Vendor promotional allocations', 0.44, const Color(0xFFC4FF62)),
        ],
      ),
    );
  }

  Widget _buildMetricVal(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.black)),
        ],
      ),
    );
  }

  Widget _buildProgressLine(String label, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 10)),
            Text('${(pct * 100).toInt()}%', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }

  Widget _buildDatabaseAuditLogViewer(List<String> logs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange)),
                  const SizedBox(width: 8),
                  const Text('cloud_firestore database logs', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('LIVE STREAM', style: TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (logs.isEmpty)
            const Text(
              'No active transactions logged yet in this session. Logs emit in real-time when actions occur across dashboards.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    logs[index],
                    style: const TextStyle(color: Color(0xFF53C5D4), fontSize: 10, fontFamily: 'monospace', height: 1.3),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
