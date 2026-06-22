import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ScriptGeneratorScreen extends StatefulWidget {
  const ScriptGeneratorScreen({super.key});

  @override
  State<ScriptGeneratorScreen> createState() => _ScriptGeneratorScreenState();
}

class _ScriptGeneratorScreenState extends State<ScriptGeneratorScreen> {
  final _firebaseService = FirebaseService();
  final _productController = TextEditingController(text: 'Super Hydrate Serum');
  final _categoryController = TextEditingController(text: 'Skincare');
  final _audienceController = TextEditingController(text: 'Beauty Creators & Gen Z');
  final _offerController = TextEditingController(text: 'Buy 1 Get 1 Free - limited stock!');
  
  String _selectedLanguage = 'English';
  String _selectedStyle = 'Product Promotion';
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    _productController.dispose();
    _categoryController.dispose();
    _audienceController.dispose();
    _offerController.dispose();
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleGenerate() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    _firebaseService.generateScriptModel(
      productName: _productController.text,
      category: _categoryController.text,
      audience: _audienceController.text,
      offer: _offerController.text,
      language: _selectedLanguage,
      style: _selectedStyle,
    );
    setState(() => _isGenerating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Script generated successfully & synced to Firestore!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _firebaseService.generatedScripts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormCard(),
          const SizedBox(height: 20),
          _buildLiveCollectionConsole(list),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF49454F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFFD0BCFF), size: 22),
              SizedBox(width: 8),
              Text(
                'AI Script Enginer',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Generates custom hook, captions, dialogue voiceovers, and marketing assets for any product.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
          const SizedBox(height: 20),
          _buildTextField('Product Name', _productController, Icons.shopping_basket),
          const SizedBox(height: 14),
          _buildTextField('Category', _categoryController, Icons.category),
          const SizedBox(height: 14),
          _buildTextField('Target Audience', _audienceController, Icons.people),
          const SizedBox(height: 14),
          _buildTextField('Attractive Offer', _offerController, Icons.local_offer),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Language',
                  value: _selectedLanguage,
                  items: ['Hindi', 'Marathi', 'English'],
                  onChanged: (val) => setState(() => _selectedLanguage = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Creative Style',
                  value: _selectedStyle,
                  items: [
                    'Product Promotion',
                    'Storytelling',
                    'Festival Offer',
                    'Motivation',
                    'Education',
                    'News',
                    'Local Marketing',
                    'Restaurant Promotion',
                    'Tourism Promotion',
                    'Business Promotion'
                  ],
                  onChanged: (val) => setState(() => _selectedStyle = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isGenerating
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4FF62),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _handleGenerate,
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text('GENERATE AI BRIEF', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFFD0BCFF), size: 18),
        filled: true,
        fillColor: const Color(0x0DFFFFFF),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF49454F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF49454F)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF2B2930),
              value: value,
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 12)),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD0BCFF)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCollectionConsole(List<GeneratedScript> items) {
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
                  const Text('cloud_firestore console', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('/generated_scripts', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (items.isEmpty)
            const Text(
              'No generated scripts found in Firestore documents. Input parameters and click Generate to run.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ...items.map((script) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF080D16), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('DOC: ${script.id} (Product: ${script.productName})', style: const TextStyle(color: Color(0xffa5f3fc), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('  "hook": "${script.hook}"', style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "script": "${script.script}"', style: const TextStyle(color: Color(0xffa5f3fc), fontSize: 9, fontFamily: 'monospace')),
                      Text('  "caption": "${script.caption}"', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontFamily: 'monospace')),
                      Text('  "hashtags": "${script.hashtags}"', style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "cta": "${script.cta}"', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "voiceoverText": "${script.voiceoverText}"', style: const TextStyle(color: Colors.orangeAccent, fontSize: 9, fontFamily: 'monospace')),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
