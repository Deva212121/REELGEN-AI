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
            const Text('Step 1: Select Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Product', border: OutlineInputBorder()),
              value: _selectedProductId,
              items: _products.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (value) => setState(() => _selectedProductId = value),
            ),
            const SizedBox(height: 16),

            const Text('Step 2: Select Marketing Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            _buildCheckbox('WhatsApp Status', 'Send product update on WhatsApp status', _includeWhatsApp, (val) => setState(() => _includeWhatsApp = val!)),
            _buildCheckbox('Instagram Stories', '3-5 stories per day with stickers', _includeInstagramStories, (val) => setState(() => _includeInstagramStories = val!)),
            _buildCheckbox('Instagram Reels', '1 reel per day with trending audio', _includeInstagramReels, (val) => setState(() => _includeInstagramReels = val!)),
            _buildCheckbox('Instagram Posts', '1 post per day with caption + hashtags', _includeInstagramPosts, (val) => setState(() => _includeInstagramPosts = val!)),
            _buildCheckbox('Facebook Posts', 'Share to Facebook + join groups', _includeFacebook, (val) => setState(() => _includeFacebook = val!)),
            _buildCheckbox('Paid Ads (Instagram + Facebook + Google)', '₹5000+ budget for ads', _includePaidAds, (val) => setState(() => _includePaidAds = val!)),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildButton('Reel Package', Icons.auto_awesome, const Color(0xFFC4FF62), _generateReelPackage),
                _buildButton('Marketing Plan', Icons.trending_up, const Color(0xFFD0BCFF), _generateMarketingPlan),
                _buildButton('Image Prompts', Icons.image, const Color(0xFFFF4B8A), _generateImagePrompts),
                _buildButton('Brand Identity', Icons.branding_watermark, const Color(0xFFC4FF62), _generateBrandIdentity),
              ],
            ),
            const SizedBox(height: 16),

            if (_generatedOutput != null)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: SelectableText(_generatedOutput!, style: const TextStyle(fontSize: 14, height: 1.5)))),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, String subtitle, bool value, Function(bool?) onChanged) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
      child: CheckboxListTile(title: Text(title), subtitle: Text(subtitle), value: value, onChanged: onChanged, activeColor: const Color(0xFFC4FF62)),
    );
  }

  Widget _buildButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isGenerating || _selectedProductId == null ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: color == const Color(0xFFFF4B8A) ? Colors.white : Colors.black),
    );
  }

  Future<void> _generateReelPackage() async {
    setState(() => _isGenerating = true);
    try {
      _generatedOutput = await _selloreService.generateReelPackage(_selectedProductId!, _influencerName);
      Fluttertoast.showToast(msg: 'Reel package generated!');
    } catch (e) { Fluttertoast.showToast(msg: 'Error: $e'); }
    setState(() => _isGenerating = false);
  }

  Future<void> _generateMarketingPlan() async {
    setState(() => _isGenerating = true);
    try {
      _generatedOutput = await _selloreService.generateMarketingPlan(
        _selectedProductId!, _includeWhatsApp, _includeInstagramStories, _includeInstagramReels,
        _includeInstagramPosts, _includeFacebook, _includePaidAds,
      );
      Fluttertoast.showToast(msg: 'Marketing plan generated!');
    } catch (e) { Fluttertoast.showToast(msg: 'Error: $e'); }
    setState(() => _isGenerating = false);
  }

  Future<void> _generateImagePrompts() async {
    setState(() => _isGenerating = true);
    try {
      _generatedOutput = await _selloreService.generateImagePrompts(_selectedProductId!);
      Fluttertoast.showToast(msg: 'Image prompts generated!');
    } catch (e) { Fluttertoast.showToast(msg: 'Error: $e'); }
    setState(() => _isGenerating = false);
  }

  Future<void> _generateBrandIdentity() async {
    setState(() => _isGenerating = true);
    try {
      _generatedOutput = await _selloreService.generateBrandIdentity(_selectedProductId!);
      Fluttertoast.showToast(msg: 'Brand identity generated!');
    } catch (e) { Fluttertoast.showToast(msg: 'Error: $e'); }
    setState(() => _isGenerating = false);
  }
}