import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/firestore_models.dart';

class ImageToVideoScreen extends StatefulWidget {
  const ImageToVideoScreen({super.key});

  @override
  State<ImageToVideoScreen> createState() => _ImageToVideoScreenState();
}

class _ImageToVideoScreenState extends State<ImageToVideoScreen> {
  final _firebaseService = FirebaseService();
  final _textController = TextEditingController(text: 'Experience pure hydration with Super Serum!');
  int _imageCount = 4;
  String _selectedMusic = 'Lo-Fi Chill Ambient';
  bool _isProcessing = false;

  final List<String> _selectedLocalPhotos = [
    'Super_Serum_Product.jpg',
    'Matte_Lipstick_Texture.jpg',
    'Glow_Lotion_Swatch.jpg',
    'SPF50_Shield_Outdoor.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    _textController.dispose();
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showMockImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2B2930),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final mockPics = [
          {'file': 'Nourishing_Tonic_Studio.jpg', 'desc': 'Studio Shot of Tonic bottle with water splash', 'res': '1080x1920'},
          {'file': 'Collagen_Cream_Lid_Off.jpg', 'desc': 'Close-up of clinical collagen lotion jar', 'res': '1080x1920'},
          {'file': 'Lip_Plumper_Glossy.jpg', 'desc': 'Premium models wearing gloss shade lipstick', 'res': '1080x1920'},
          {'file': 'Detox_Clay_Mask_Jar.jpg', 'desc': 'Organic minerals with botanical leaf backdrop', 'res': '1080x1920'},
          {'file': 'Hydrating_Aerosol_Mist.jpg', 'desc': 'Mist spray nozzle macro shot with droplets', 'res': '1080x1920'},
        ];

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Simulated Photo Pool Picker',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(color: Color(0x33FFFFFF)),
              const Text(
                'Choose premium campaign catalog photos to upload to the slideshow compiler:',
                style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: mockPics.map((p) {
                    final isAlreadySelected = _selectedLocalPhotos.contains(p['file']!);
                    return InkWell(
                      onTap: () {
                        if (isAlreadySelected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('This image is already staged in compile queue.')),
                          );
                        } else {
                          setState(() {
                            _selectedLocalPhotos.add(p['file']!);
                            _imageCount = _selectedLocalPhotos.length;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF381E72),
                              content: Text('Uploaded "${p['file']}" to active compile queue!'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isAlreadySelected ? const Color(0x1FFFFFFF) : const Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isAlreadySelected ? const Color(0xFFC4FF62) : const Color(0xFF49454F)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image, color: Color(0xFFD0BCFF), size: 16),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['file']!,
                                    style: TextStyle(
                                      color: isAlreadySelected ? const Color(0xFFC4FF62) : Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(p['desc']!, style: const TextStyle(color: Colors.white38, fontSize: 9)),
                                ],
                              ),
                            ),
                            Text(p['res']!, style: const TextStyle(color: Color(0xFFFF4B8A), fontSize: 10, fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedFramesRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Compile Queue Frames:',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _showMockImagePicker,
              child: const Row(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFC4FF62), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'UPLOAD FRAMES',
                    style: TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _selectedLocalPhotos.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x05FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x3349454F)),
                ),
                child: const Text('No active images uploaded yet. Tap top right to select.', style: TextStyle(color: Colors.white24, fontSize: 10)),
              )
            : SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedLocalPhotos.length,
                  itemBuilder: (context, index) {
                    final item = _selectedLocalPhotos[index];
                    return Container(
                      width: 115,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF49454F)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.picture_in_picture, color: Color(0xFFD0BCFF), size: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedLocalPhotos.removeAt(index);
                                    _imageCount = _selectedLocalPhotos.length;
                                  });
                                },
                                child: const Icon(Icons.cancel, color: Colors.redAccent, size: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace'),
                          ),
                          Text(
                            'Frame #${index + 1}',
                            style: const TextStyle(color: Colors.white38, fontSize: 8),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  void _generateVideoProject() async {
    if (_selectedLocalPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 1 image frame to compile!')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    final selectedSoundId = _firebaseService.selectedReelSoundId;
    String finalMusic = _selectedMusic;
    if (selectedSoundId != null) {
      try {
        final activeObj = _firebaseService.soundLibrary.firstWhere((s) => s.id == selectedSoundId);
        finalMusic = '${activeObj.name} [Sound Library]';
      } catch (_) {}
    }
    _firebaseService.createImageVideo(_imageCount, _textController.text, finalMusic);
    setState(() => _isProcessing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Slideshow reel compiled & project saved into database!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = _firebaseService.imageVideoProjects;

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
                    Icon(Icons.video_camera_back_outlined, color: Color(0xFFD0BCFF), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Image to Video Compiler',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Compile brand photos, product shots, or photoshoot frames into responsive 9:16 high-conversion video reels with overlays and ambient audio loops.',
                  style: TextStyle(color: Color(0xFF938F99), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Number of Images:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    const Expanded(child: SizedBox()),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFC4FF62)),
                      onPressed: () {
                        if (_imageCount > 1) {
                          setState(() {
                            _imageCount--;
                            if (_selectedLocalPhotos.length > _imageCount) {
                              _selectedLocalPhotos.removeLast();
                            }
                          });
                        }
                      },
                    ),
                    Text('$_imageCount', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC4FF62)),
                      onPressed: () {
                        if (_imageCount < 15) {
                          setState(() {
                            _imageCount++;
                            _selectedLocalPhotos.add('Catalog_Item_Filler_$_imageCount.jpg');
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSelectedFramesRow(),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Visual Text Overlay / Hook Caption',
                    labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 12),
                    prefixIcon: const Icon(Icons.text_fields_outlined, color: Color(0xFFD0BCFF), size: 18),
                    filled: true,
                    fillColor: const Color(0x0DFFFFFF),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF49454F)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMusicDropdown(),
                const SizedBox(height: 24),
                _isProcessing
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0BCFF)))
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC4FF62),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _generateVideoProject,
                        icon: const Icon(Icons.slow_motion_video, size: 18),
                        label: const Text('COMPILE SLIDESHOW REEL', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildLogsConsole(projects),
        ],
      ),
    );
  }

  Widget _buildMusicDropdown() {
    final selectedSoundId = _firebaseService.selectedReelSoundId;
    var activeSoundName = '';
    if (selectedSoundId != null) {
      try {
        final sObj = _firebaseService.soundLibrary.firstWhere((s) => s.id == selectedSoundId);
        activeSoundName = sObj.name;
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ambient Audio Loop Track Picker', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontWeight: FontWeight.bold)),
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
              value: _selectedMusic,
              items: [
                'Lo-Fi Chill Ambient',
                'Upbeat Energetic Techno',
                'Cinematic Orchestral',
                'Corporate Minimal Pop',
                'Indie Acoustic Vibe'
              ].map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 12)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedMusic = val!),
              isExpanded: true,
              icon: const Icon(Icons.audiotrack, color: Color(0xFFD0BCFF)),
            ),
          ),
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
                        'This instrument choice overrides default selection upon compilation.',
                        style: TextStyle(color: Colors.white54, fontSize: 8),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.bolt, color: Color(0xFFC4FF62), size: 14),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogsConsole(List<ImageVideoProject> list) {
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
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.indigo)),
                  const SizedBox(width: 8),
                  const Text('image_video_projects DB', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('/image_video_projects', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (list.isEmpty)
            const Text(
              'No active image-video projects listed. Create one above to serialize parameters into Firestore document logs.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ...list.map((proj) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080D16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROJECT ID: ${proj.id}', style: const TextStyle(color: Color(0xffa5f3fc), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('  "total_frames": ${proj.imageCount},', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "overlay_markup": "${proj.textOverlay}",', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontFamily: 'monospace')),
                      Text('  "background_track": "${proj.music}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      const Text('  "status": "compiled_successfully"', style: TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace')),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
