import 'package:flutter/material.dart';

class ReelTrackingScreen extends StatelessWidget {
  const ReelTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Reel Social Metrics Monitor',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Keep track of impressions, organic views, average watch durations, and audience shares of published clips.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
          const SizedBox(height: 20),
          _buildOverallReachHeader(),
          const SizedBox(height: 20),
          const Text('Reels Performance Log', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildReelStatsCard(
            title: 'Hydrate Serum Unboxing Hook',
            views: '45.1K',
            likes: '8.4K',
            shares: '1.2K',
            watchTime: '12.4s (avg)',
            retention: 0.88,
            color: const Color(0xFFC4FF62),
          ),
          const SizedBox(height: 10),
          _buildReelStatsCard(
            title: 'Peak Nutrition Organic Storytelling',
            views: '12.8K',
            likes: '2.1K',
            shares: '344',
            watchTime: '8.1s (avg)',
            retention: 0.54,
            color: const Color(0xffa5f3fc),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallReachHeader() {
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
          const Text('ORGANIC VIEWERSHIP GROWTH', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('57,940 Total Views', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('+12.4% Organic traffic boost this week', style: TextStyle(color: Color(0xFFC4FF62), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Custom mini visual chart representation using borders
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartCol(30, 'Mon'),
              _buildChartCol(55, 'Tue'),
              _buildChartCol(40, 'Wed'),
              _buildChartCol(80, 'Thu'),
              _buildChartCol(95, 'Fri'),
              _buildChartCol(70, 'Sat'),
              _buildChartCol(110, 'Sun'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCol(double height, String day) {
    return Column(
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF381E72), Color(0xFFD0BCFF)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
      ],
    );
  }

  Widget _buildReelStatsCard({
    required String title,
    required String views,
    required String likes,
    required String shares,
    required String watchTime,
    required double retention,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatMetric('Views', views, color),
              _buildStatMetric('Likes', likes, Colors.white),
              _buildStatMetric('Shares', shares, Colors.white),
              _buildStatMetric('Watch-Time', watchTime, Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Retentive Audience Loopback:', style: TextStyle(color: Color(0xFF938F99), fontSize: 10)),
              Text('${(retention * 100).toInt()}% Completion', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: retention,
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
