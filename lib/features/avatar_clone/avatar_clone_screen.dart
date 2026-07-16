import 'package:flutter/material.dart';
import '../../models/firestore_models.dart';
import '../../services/firebase_service.dart';

class AvatarCloneScreen extends StatefulWidget {
  const AvatarCloneScreen({super.key});

  @override
  State<AvatarCloneScreen> createState() => _AvatarCloneScreenState();
}

class _AvatarCloneScreenState extends State<AvatarCloneScreen> {
  final _firebaseService = FirebaseService();
  final _nameController = TextEditingController(text: 'Sales Rep Avatar V1');
  final _scriptController = TextEditingController(text: 'Hello valued buyer, unbox this premium serum right now for amazing skin benefits!');
  String _selectedType = 'Sales Avatar';
  String _selectedVoice = 'Creator Deep Vocal V1';
  bool _isRendering = false;
  String _selectedFaceFile = 'face_profile_mask.png';

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    _nameController.dispose();
    _scriptController.dispose();
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _generateAvatar() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isRendering = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    _firebaseService.createAvatarProfile(
      _nameController.text.trim(),
      _selectedType,
      _selectedFaceFile,
      _selectedVoice,
    );
    setState(() => _isRendering = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Avatar Clone synthesized & registered into Firestore!')),
    );
  }

  void _showFacePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2B2930),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final mockFaces = [
          {'file': 'actor_male_kyle_face.png', 'desc': 'Male Caucasian, 20s Clean Shaven Model', 'size': '820 KB'},
          {'file': 'actor_female_sarah_face.png', 'desc': 'Female Asian, Professional Host Style', 'size': '940 KB'},
          {'file': 'host_portrait_vanguard.png', 'desc': 'Ambassador Suit Portrait, Warm Demeanor', 'size': '1.2 MB'},
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
                    'Simulated Face Asset Pool',
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
                'Choose a simulated actor face avatar token to feed into the synthesizer engine:',
                style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
              ),
              const SizedBox(height: 12),
              ...mockFaces.map((f) => InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFaceFile = f['file']!;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF381E72),
                          content: Text('Loaded texture template "${f['file']}" successfully!'),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedFaceFile == f['file'] ? const Color(0x13FFFFFF) : const Color(0x05FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedFaceFile == f['file'] ? const Color(0xFFC4FF62) : const Color(0xFF49454F),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.face, color: Color(0xFFC4FF62), size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f['file']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                Text(f['desc']!, style: const TextStyle(color: Colors.white38, fontSize: 9)),
                              ],
                            ),
                          ),
                          Text(f['size']!, style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 10, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaceUploadBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Target Face Silhouette:', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _showFacePickerSheet,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x0DFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF49454F)),
            ),
            child: Row(
              children: [
                const Icon(Icons.portrait, color: Color(0xFFD0BCFF), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedFaceFile, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      const Text('Tap to upload/select high-res face portrait', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                ),
                const Icon(Icons.cloud_upload_outlined, color: Color(0xFFC4FF62), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _firebaseService.avatarProfiles;

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
                    Icon(Icons.face_retouching_natural, color: Color(0xFFD0BCFF), size: 22),
                    SizedBox(width: 8),
                    Text('AI Avatar Synthesizer Studio', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Map a face structure photo, assign a cloned voice token, and feed a promotion speech script to synthesize a life-like Talking Avatar representation. (Future integration: full face animation).',
                  style: TextStyle(color: Color(0xFF938F99), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Avatar Profile Designation',
                    labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 12),
                    prefixIcon: const Icon(Icons.badge, color: Color(0xFFD0BCFF), size: 18),
                    filled: true,
                    fillColor: const Color(0x0DFFFFFF),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF49454F))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
                  ),
                ),
                const SizedBox(height: 14),
                _buildDropdown(
                  label: 'Avatar Specialization Persona',
                  value: _selectedType,
                  items: ['Sales Avatar', 'Talking Avatar', 'Teacher Avatar'],
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
                const SizedBox(height: 14),
                _buildFaceUploadBlock(),
                const SizedBox(height: 14),
                _buildDropdown(
                  label: 'Voiceover Token',
                  value: _selectedVoice,
                  items: ['Creator Deep Vocal V1', 'Brand Energetic Narrator', 'Soft Whisper Accent'],
                  onChanged: (val) => setState(() => _selectedVoice = val!),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _scriptController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Spoken Script Transcription',
                    labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 12),
                    prefixIcon: const Icon(Icons.edit_note, color: Color(0xFFD0BCFF), size: 18),
                    filled: true,
                    fillColor: const Color(0x0DFFFFFF),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF49454F))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
                  ),
                ),
                const SizedBox(height: 20),
                _isRendering
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4FF62)))
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC4FF62),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _generateAvatar,
                        icon: const Icon(Icons.center_focus_strong, size: 18),
                        label: const Text('SYNTHESIZE TALKING PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildActiveProfileConsole(list),
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

  Widget _buildActiveProfileConsole(List<AvatarProfile> profiles) {
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
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent)),
                  const SizedBox(width: 8),
                  const Text('avatar_profiles DB', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('/avatar_profiles', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (profiles.isEmpty)
            const Text(
              'No registered visual avatar model profiles in database. Synthesize one to index document representation.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final item = profiles[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF080D16), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PROFILE ID: ${item.id}', style: const TextStyle(color: Color(0xffa5f3fc), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF381E72), borderRadius: BorderRadius.circular(4)),
                            child: Text(item.type, style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('  "name": "${item.name}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "voice_sample": "${item.voiceName}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "face_mesh_reference": "${item.faceImageName}",', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontFamily: 'monospace')),
                      const Text('  "render_status": "READY_AND_DEPLOYED"', style: TextStyle(color: Colors.cyan, fontSize: 9, fontFamily: 'monospace')),
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
