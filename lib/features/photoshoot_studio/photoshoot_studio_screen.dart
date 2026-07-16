import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/firestore_models.dart';

class PhotoshootStudioScreen extends StatefulWidget {
  const PhotoshootStudioScreen({super.key});

  @override
  State<PhotoshootStudioScreen> createState() => _PhotoshootStudioScreenState();
}

class _PhotoshootStudioScreenState extends State<PhotoshootStudioScreen> {
  final _firebaseService = FirebaseService();
  String _selectedStudioMode = 'Fashion Shoot';
  String _selectedEffect = 'DSLR Look';
  String _selectedMusic = 'Cinematic Golden Hour Acoustic';
  int _photosCount = 6;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _triggerRender() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    final selectedSoundId = _firebaseService.selectedReelSoundId;
    String finalMusic = _selectedMusic;
    if (selectedSoundId != null) {
      try {
        final activeSound = _firebaseService.soundLibrary.firstWhere((s) => s.id == selectedSoundId);
        finalMusic = '${activeSound.name} [Sound Library]';
      } catch (_) {}
    }
    _firebaseService.createPhotoshootStudio(
      _selectedStudioMode,
      _selectedEffect,
      finalMusic,
      _photosCount,
    );
    setState(() => _isGenerating = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photoshoot album compiled! Generated cinematic slideshow in Firestore!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _firebaseService.photoshootProjects;

    final selectedSoundId = _firebaseService.selectedReelSoundId;
    var activeSoundName = '';
    if (selectedSoundId != null) {
      try {
        final sObj = _firebaseService.soundLibrary.firstWhere((s) => s.id == selectedSoundId);
        activeSoundName = sObj.name;
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2930),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF49454F)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.camera_roll_outlined, color: Color(0xFFFDA4AF), size: 22),
                    SizedBox(width: 8),
                    Text('Photoshoot Studio Engine', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload model shots, product frames, wedding albums, or travel clips. Apply luxury effects such as DSLR look, Bokeh highlights, and cinematic transitions to export polished vertical reels.',
                  style: TextStyle(color: Color(0xFF938F99), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: 'Sponsorship / Portrait Focus style',
                  value: _selectedStudioMode,
                  items: [
                    'Wedding',
                    'Pre-Wedding',
                    'Birthday',
                    'Baby Shoot',
                    'Fashion Shoot',
                    'Model Shoot',
                    'Family Shoot',
                    'Couple Shoot',
                    'Travel Shoot',
                    'Event Shoot',
                    'Festival Shoot',
                    'Business Shoot',
                    'Product Shoot',
                    'Influencer Shoot',
                    'Portfolio Shoot'
                  ],
                  onChanged: (val) => setState(() => _selectedStudioMode = val!),
                ),
                const SizedBox(height: 14),
                _buildDropdown(
                  label: 'Optic Layer Effect Render',
                  value: _selectedEffect,
                  items: [
                    'DSLR Look',
                    'Portrait Mode',
                    'Cinematic Look',
                    'Golden Light',
                    'Bokeh',
                    'Vintage',
                    'Dreamy',
                    'Warm Tone',
                    'Film Grain',
                    'Smooth Transition',
                    'Rich Text Animation'
                  ],
                  onChanged: (val) => setState(() => _selectedEffect = val!),
                ),
                const SizedBox(height: 14),
                _buildDropdown(
                  label: 'Backing Theme Track',
                  value: _selectedMusic,
                  items: [
                    'Cinematic Golden Hour Acoustic',
                    'Vogue Runway Electronic',
                    'Romantic Violin Soft Beats',
                    'Vintage Nostalgia Film Pops'
                  ],
                  onChanged: (val) => setState(() => _selectedMusic = val!),
                ),
                if (activeSoundName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4FF62).withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC4FF62).withAlpha((0.3 * 255).round())),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Color(0xFFC4FF62), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SOUND LIBRARY ACTIVE: $activeSoundName',
                                style: const TextStyle(
                                  color: Color(0xFFC4FF62),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Using sound library choice over default selections.',
                                style: TextStyle(color: Colors.white54, fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.flash_on, color: Color(0xFFC4FF62), size: 14),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Photos Uploaded:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    const Expanded(child: SizedBox()),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Color(0xFFFF4B8A)),
                      onPressed: () {
                        if (_photosCount > 1) setState(() => _photosCount--);
                      },
                    ),
                    Text('$_photosCount', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFFF4B8A)),
                      onPressed: () {
                        if (_photosCount < 20) setState(() => _photosCount++);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _isGenerating
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFDA4AF)))
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4B8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _triggerRender,
                        icon: const Icon(Icons.video_library, size: 18),
                        label: const Text('GENERATE CINEMATIC REEL', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPhotoshootConsole(list),
        ],
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

  Widget _buildPhotoshootConsole(List<PhotoshootProject> list) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent)),
                  const SizedBox(width: 8),
                  const Text('photoshoot_projects DB', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('/photoshoot_projects', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (list.isEmpty)
            const Text(
              'No active shoots created in database. Fill parameters and generate albums.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final proj = list[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF080D16), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROJECT ID: ${proj.id}', style: const TextStyle(color: Color(0xffff79c6), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      const SizedBox(height: 6),
                      Text('  "album_type": "${proj.style}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "applied_filter": "${proj.effect}",', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontFamily: 'monospace')),
                      Text('  "back_beat_sound": "${proj.music}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "source_assets": ${proj.itemsCount} frames,', style: const TextStyle(color: Colors.cyan, fontSize: 9, fontFamily: 'monospace')),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
