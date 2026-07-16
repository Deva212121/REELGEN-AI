import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/sellore_ai_service.dart';

class SelloreAIScreen extends StatefulWidget {
  const SelloreAIScreen({super.key});

  @override
  State<SelloreAIScreen> createState() => _SelloreAIScreenState();
}

class _SelloreAIScreenState extends State<SelloreAIScreen> {
  final SelloreAIService _selloreService = SelloreAIService();
  bool _isGenerating = false;
  String? _selectedProductId;
  String? _generatedOutput;
  final String _influencerName = 'influencer';

  // ---------- Checkboxes ----------
  bool _includeWhatsApp = true;
  bool _includeInstagramStories = true;
  bool _includeInstagramReels = true;
  bool _includeInstagramPosts = true;
  bool _includeFacebook = true;
  bool _includePaidAds = false;

  final List<String> _products = ['Kundan Earrings', 'Gold Necklace', 'Silver Ring', 'Diamond Pendant'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SelloreAI — Auto Reel Maker'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Step 1: Product Select ----------
            const Text(
              'Step 1: Select Product',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Product',
                border: OutlineInputBorder(),
              ),
              value: _selectedProductId,
              items: _products.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedProductId = value);
              },
            ),
            const SizedBox(height: 16),

            // ---------- Step 2: Marketing Options (Checkboxes) ----------
            const Text(
              'Step 2: Select Marketing Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // WhatsApp Status
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('WhatsApp Status'),
                subtitle: const Text('Send product update on WhatsApp status'),
                value: _includeWhatsApp,
                onChanged: (val) => setState(() => _includeWhatsApp = val!),
                activeColor: const Color(0xFFC4FF62),
              ),
            ),
            const SizedBox(height: 4),

            // Instagram Stories
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('Instagram Stories'),
                subtitle: const Text('3-5 stories per day with stickers'),
                value: _includeInstagramStories,
                onChanged: (val) => setState(() => _includeInstagramStories = val!),
                activeColor: const Color(0xFFC4FF62),
              ),
            ),
            const SizedBox(height: 4),

            // Instagram Reels
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('Instagram Reels'),
                subtitle: const Text('1 reel per day with trending audio'),
                value: _includeInstagramReels,
                onChanged: (val) => setState(() => _includeInstagramReels = val!),
                activeColor: const Color(0xFFC4FF62),
              ),
            ),
            const SizedBox(height: 4),

            // Instagram Posts
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('Instagram Posts'),
                subtitle: const Text('1 post per day with caption + hashtags'),
                value: _includeInstagramPosts,
                onChanged: (val) => setState(() => _includeInstagramPosts = val!),
                activeColor: const Color(0xFFC4FF62),
              ),
            ),
            const SizedBox(height: 4),

            // Facebook
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('Facebook Posts'),
                subtitle: const Text('Share to Facebook + join groups'),
                value: _includeFacebook,
                onChanged: (val) => setState(() => _includeFacebook = val!),
                activeColor: const Color(0xFFC4FF62),
              ),
            ),
            const SizedBox(height: 4),

            // Paid Ads
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: const Text('Paid Ads (Instagram + Facebook + Google)'),
                subtitle: const Text('₹5000+ budget for ads'),
                value: _includePaidAds,
                onChanged: (val) => setState(() => _includePaidAds = val!),
                activeColor: const Color(0xFFC4FF62),
              ),
            ),
            const SizedBox(height: 16),

            // ---------- Buttons ----------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating || _selectedProductId == null
                        ? null
                        : _generateReelPackage,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? 'Generating...' : 'Reel Package'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4FF62),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating || _selectedProductId == null
                        ? null
                        : _generateMarketingPlan,
                    icon: const Icon(Icons.trending_up),
                    label: Text(_isGenerating ? 'Generating...' : 'Marketing Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0BCFF),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---------- Output ----------
            if (_generatedOutput != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _generatedOutput!,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReelPackage() async {
    setState(() => _isGenerating = true);
    try {
      final result = await _selloreService.generateReelPackage(
        _selectedProductId!,
        _influencerName,
      );
      setState(() {
        _generatedOutput = result;
        _isGenerating = false;
      });
      Fluttertoast.showToast(msg: 'Reel package generated!');
    } catch (e) {
      setState(() => _isGenerating = false);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _generateMarketingPlan() async {
    setState(() => _isGenerating = true);
    try {
      final result = await _selloreService.generateMarketingPlan(
        _selectedProductId!,
        _includeWhatsApp,
        _includeInstagramStories,
        _includeInstagramReels,
        _includeInstagramPosts,
        _includeFacebook,
        _includePaidAds,
      );
      setState(() {
        _generatedOutput = result;
        _isGenerating = false;
      });
      Fluttertoast.showToast(msg: 'Marketing plan generated!');
    } catch (e) {
      setState(() => _isGenerating = false);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }
}