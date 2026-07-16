import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class BusinessTrackingScreen extends StatefulWidget {
  const BusinessTrackingScreen({super.key});

  @override
  State<BusinessTrackingScreen> createState() => _BusinessTrackingScreenState();
}

class _BusinessTrackingScreenState extends State<BusinessTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    final affiliates = service.affiliateLinks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Campaign Profit Ecosystem',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Audited conversion funnels, tracking metrics, and dynamic paychecks synced directly from affiliate_links in Firestore.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
          const SizedBox(height: 20),
          _buildPerformanceAnalyticsChart(affiliates),
          const SizedBox(height: 20),
          const Text(
            'Active Contract Links & Clicks Breakdown',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (affiliates.isEmpty)
            _buildEmptyAlertCard()
          else
            _buildAffiliatesListBreakdown(affiliates),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalyticsChart(List affiliates) {
    int aggregateClicks = 0;
    int aggregateOrders = 0;
    double aggregateBusiness = 0.0;
    for (var a in affiliates) {
aggregateClicks = aggregateClicks + ((a.clicks ?? 0) as num).toInt();
aggregateOrders = aggregateOrders + ((a.orders ?? 0) as num).toInt(); 
      aggregateBusiness += a.businessAmount;
    }
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2930), Color(0xFF1C1B1F)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Unified Channels Funnel', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildChartBar('Audience Click-throughs', aggregateClicks, 100, Colors.cyan),
          const SizedBox(height: 12),
          _buildChartBar('Sponsor Conversions', aggregateOrders, 100, const Color(0xFFC4FF62)),
          const SizedBox(height: 12),
          _buildChartBar('E-commerce Revenue (\$)', aggregateBusiness.toInt(), 500, const Color(0xFFD0BCFF)),
          const Divider(color: Color(0x33FFFFFF), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Contract Invoices:', style: TextStyle(color: Color(0xFF938F99), fontSize: 11)),
              Text('\$${(aggregateBusiness * 0.15).toStringAsFixed(2)} Active Receivables', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String title, int count, int maxValue, Color color) {
    final double fraction = maxValue > 0 ? (count / maxValue).clamp(0.01, 1.0) : 0.01;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF938F99), fontSize: 11)),
            Text(count.toString(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          decoration: BoxDecoration(color: const Color(0x13FFFFFF), borderRadius: BorderRadius.circular(5)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAlertCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: const Column(
        children: [
          Icon(Icons.query_stats, color: Colors.blueGrey, size: 36),
          SizedBox(height: 10),
          Text('No active campaign analytics synced.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 4),
          Text('Your referral links and click tracking stats will reflect here instantly once sponsorship OTP verifications are approved.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF938F99), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAffiliatesListBreakdown(List affiliates) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: affiliates.length,
      itemBuilder: (context, index) {
        final aff = affiliates[index];
        final conversion = aff.clicks > 0 ? (aff.orders / aff.clicks) * 100 : 0.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2930),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF49454F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(aff.productName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFC4FF62).withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(4)),
                    child: Text('RG CODE: ${aff.referralCode}', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('Clicks Volume', aff.clicks.toString()),
                  _buildMiniStat('Total Sales', aff.orders.toString()),
                  _buildMiniStat('Conversion rate', '${conversion.toStringAsFixed(1)}%'),
                  _buildMiniStat('Net Earned (15%)', '\$${(aff.businessAmount * 0.15).toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
