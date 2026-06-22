import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class VoiceUploadScreen extends StatefulWidget {
  const VoiceUploadScreen({super.key});

  @override
  State<VoiceUploadScreen> createState() => _VoiceUploadScreenState();
}

class _VoiceUploadScreenState extends State<VoiceUploadScreen> {
  final _firebaseService = FirebaseService();
  final _nameController = TextEditingController(text: 'Creator Deep Vocal V1');
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    _nameController.dispose();
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _triggerUpload() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    _firebaseService.saveVoiceProfile(_nameController.text, '4.2 MB');
    setState(() => _isUploading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice profile clone uploaded and indexed successfully in Storage & DB!')),
    );
  }

  void _showSimulatedFilePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2B2930),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final mockFiles = [
          {'name': 'raw_vocal_studio_high_res.wav', 'size': '5.1 MB', 'desc': 'Studio Quality Deep Vocal Accent'},
          {'name': 'ambient_vocal_reverb_pro.mp3', 'size': '3.8 MB', 'desc': 'Reverb Rich Female Narrative Voice'},
          {'name': 'clean_speech_narrator_v2.wav', 'size': '6.2 MB', 'desc': 'Clear Professional Voice Actor Brief'},
          {'name': 'warm_talk_male_vocal.mp3', 'size': '2.9 MB', 'desc': 'Warm Tone Organic Podcast Track'},
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
                    'Simulated Audio File Pool',
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
                'Select a studio capture sample to load into the Cloner preview slot:',
                style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
              ),
              const SizedBox(height: 12),
              ...mockFiles.map((f) => InkWell(
                    onTap: () {
                      _nameController.text = f['desc']!;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF381E72),
                          content: Text('Loaded raw track proposal "${f['name']}" successfully!'),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x0DFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF49454F)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.audiotrack, color: Color(0xFFC4FF62), size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f['name']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final list = _firebaseService.voiceSamples;

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
                Row(
                  children: const [
                    Icon(Icons.mic, color: Color(0xFFC4FF62), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Voice Profiling & Storage Hub',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Record or drop a 10s voice sample here to analyze acoustic parameters and store it securely for video synthesized soundovers. (No real cloning, simulated storage backend).',
                  style: TextStyle(color: Color(0xFF938F99), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Voice Profile Description / Name',
                    labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 12),
                    prefixIcon: const Icon(Icons.description, color: Color(0xFFD0BCFF), size: 18),
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
                InkWell(
                  onTap: _showSimulatedFilePicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF49454F)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 36, color: Color(0xFFD0BCFF)),
                        const SizedBox(height: 8),
                        Text(
                          _isUploading ? 'Securing packets...' : 'Tap here to pick mock files or drag audio (.wav / .mp3)',
                          style: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isUploading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFC4FF62)))
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF381E72),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _triggerUpload,
                        icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: const Text('UPLOAD VOICE CLONING BRIEF', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStorageConsole(list),
        ],
      ),
    );
  }

  Widget _buildStorageConsole(List<VoiceSample> samples) {
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
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue)),
                  const SizedBox(width: 8),
                  const Text('firebase_storage console', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('/voice_samples', style: TextStyle(color: Color(0xFFC4FF62), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (samples.isEmpty)
            const Text(
              'No recorded storage files found. Upload a voice profile to begin database indexing representation.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: samples.length,
              itemBuilder: (context, index) {
                final item = samples[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080D16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.audiotrack, color: Color(0xFFC4FF62), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('ID: ${item.id} | Size: ${item.size} | Status: active_streamable', style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline, color: Color(0xFFC4FF62), size: 16),
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
