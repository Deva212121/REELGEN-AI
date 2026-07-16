import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/firestore_models.dart';

class AdvancedUploadScreen extends StatefulWidget {
  const AdvancedUploadScreen({super.key});

  @override
  State<AdvancedUploadScreen> createState() => _AdvancedUploadScreenState();
}

class _AdvancedUploadScreenState extends State<AdvancedUploadScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();

  // Active staging files list (unsaved batch)
  final List<UploadedMediaItem> _stagingFiles = [];
  final _projectTitleController = TextEditingController(text: 'My Autumn Reels Shoot');
  
  // Custom file creation controllers
  final _customFileNameController = TextEditingController();
  String _selectedFileType = 'Photo'; // Default selected
  bool _disclaimerAccepted = false;

  // Active Preview State
  UploadedMediaItem? _previewingFile;
  bool _isPlayingAudioDemo = false;
  late AnimationController _pulseController;

  // Mock catalog of sample files user can "multi-add" instantly for convenience
  final List<Map<String, String>> _sampleAssetPool = [
    {'name': 'DSLR_GoldenHour_01.jpg', 'type': 'DSLR Photo', 'size': '5.2 MB', 'url': 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e'},
    {'name': 'Portrait_Model_Studio.jpg', 'type': 'Portrait Photo', 'size': '3.9 MB', 'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb'},
    {'name': 'Landscape_Drone_B_Roll.jpg', 'type': 'Photo', 'size': '2.1 MB', 'url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'},
    {'name': 'Teaser_Dance_Sponsorship.mp4', 'type': 'Video', 'size': '24.5 MB', 'url': 'https://example.com/assets/teaser_dance.mp4'},
    {'name': 'Violin_Intro_SubLayer.mp3', 'type': 'Instrumental Sound', 'size': '1.8 MB', 'url': 'https://example.com/assets/violin.mp3'},
    {'name': 'Bollywood_Festive_Voiceover.wav', 'type': 'Voiceover', 'size': '0.9 MB', 'url': 'https://example.com/assets/hindi_vo.wav'},
    {'name': 'Summer_Vibes_High_Tempo.mp3', 'type': 'Song', 'size': '6.1 MB', 'url': 'https://example.com/assets/summer_vibes.mp3'},
    {'name': 'Ambient_Synth_Lo_Fi.mp3', 'type': 'Music', 'size': '4.3 MB', 'url': 'https://example.com/assets/ambient.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _firebaseService.addListener(_onFirebaseStateChanged);

    // Seed initial staging files for interactive demo out-of-the-box
    _stagingFiles.addAll([
      UploadedMediaItem(
        id: 'stage_f_01',
        name: 'RAW_Camera_Shoot_09.png',
        type: 'DSLR Photo',
        size: '7.2 MB',
        url: 'https://images.unsplash.com/photo-1452784444945-3f422708fe5e',
        order: 0,
      ),
      UploadedMediaItem(
        id: 'stage_f_02',
        name: 'Product_Macro_Detail.jpg',
        type: 'Portrait Photo',
        size: '4.1 MB',
        url: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
        order: 1,
      ),
      UploadedMediaItem(
        id: 'stage_f_03',
        name: 'Background_HipHop_Beat.mp3',
        type: 'Music',
        size: '3.8 MB',
        url: 'https://example.com/mock/hiphop.mp3',
        order: 2,
      ),
    ]);
  }

  void _onFirebaseStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _projectTitleController.dispose();
    _customFileNameController.dispose();
    _firebaseService.removeListener(_onFirebaseStateChanged);
    super.dispose();
  }

  // Trigger simulated file selection dialog or picker
  void _addSampleItem(Map<String, String> sample) {
    if (!_disclaimerAccepted) {
      _showDisclaimerRequiredDialog();
      return;
    }

    setState(() {
      final orderId = _stagingFiles.length;
      _stagingFiles.add(UploadedMediaItem(
        id: 'stage_usr_${Random().nextInt(8999) + 1000}',
        name: sample['name']!,
        type: sample['type']!,
        size: sample['size']!,
        url: sample['url']!,
        order: orderId,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFC4FF62),
        content: Text(
          'Added "${sample['name']}" of type [${sample['type']}] into your local project batch.',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }

  // Browse the studio pool modal to simulate MULTIPLE FILE SELECT upload
  void _openBatchUploadSelector() {
    if (!_disclaimerAccepted) {
      _showDisclaimerRequiredDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF130F26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BROWSE HIGH-RES ASSET POOL',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Text(
                    'Simulate picking from high-fidelity cameras, sound recording hardware or studio files.',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _sampleAssetPool.length,
                      itemBuilder: (context, index) {
                        final item = _sampleAssetPool[index];
                        final isAlreadyAdded = _stagingFiles.any((f) => f.name == item['name']);

                        return Card(
                          color: const Color(0xFF2B2930),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(item['type']!),
                                color: const Color(0xFFC4FF62),
                                size: 16,
                              ),
                            ),
                            title: Text(
                              item['name']!,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${item['type']} • Size: ${item['size']}',
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                            trailing: isAlreadyAdded
                                ? const Text('ADDED', style: TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontWeight: FontWeight.w900))
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF381E72),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    onPressed: () {
                                      _addSampleItem(item);
                                      setModalState(() {});
                                    },
                                    child: const Text('ADD', style: TextStyle(fontSize: 10, color: Colors.white)),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white10),
                          ),
                          onPressed: () {
                            // Add all
                            int count = 0;
                            for (var item in _sampleAssetPool) {
                              if (!_stagingFiles.any((f) => f.name == item['name'])) {
                                _addSampleItem(item);
                                count++;
                              }
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Imported $count files to studio staging batch.')),
                            );
                          },
                          child: const Text('ADD ALL UNIQUE SAMPLES', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Create custom typed simulated file info
  void _addCustomTypedFile() {
    if (!_disclaimerAccepted) {
      _showDisclaimerRequiredDialog();
      return;
    }

    final name = _customFileNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Please enter a custom filename before adding.'),
        ),
      );
      return;
    }

    final formattedName = name.contains('.') ? name : '$name${_getExtensionForType(_selectedFileType)}';
    final randomSize = '${(Random().nextDouble() * 12 + 1).toStringAsFixed(1)} MB';

    setState(() {
      _stagingFiles.add(UploadedMediaItem(
        id: 'stage_usr_${Random().nextInt(8999) + 1000}',
        name: formattedName,
        type: _selectedFileType,
        size: randomSize,
        url: _mockUrlForType(_selectedFileType),
        order: _stagingFiles.length,
      ));
    });

    _customFileNameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFC4FF62),
        content: Text('Uploaded custom "$formattedName" as [$_selectedFileType] successfully!'),
      ),
    );
  }

  // Alert dialog warning the creator that the legal disclaimer is mandatory
  void _showDisclaimerRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1B2C),
          title: const Row(
            children: [
              Icon(Icons.gavel, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text('Legal Disclaimer Required', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Before uploading images, tracks, songs, or scripts, please review and confirm the copyright ownership check using the disclaimer checkbox at the top.',
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC4FF62)),
              onPressed: () {
                setState(() {
                  _disclaimerAccepted = true;
                });
                Navigator.pop(context);
              },
              child: const Text('ACCEPT NOW', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ),
          ],
        );
      },
    );
  }

  // Interactive Reordering mechanism: Move elements UP
  void _moveUp(int index) {
    if (index == 0) return; // Already first
    setState(() {
      final temp = _stagingFiles[index];
      _stagingFiles[index] = _stagingFiles[index - 1];
      _stagingFiles[index - 1] = temp;
      _firebaseService.logEvent('MediaStaging: REORDER swapped indexes $index and ${index - 1} for preview alignment.');
    });
  }

  // Interactive Reordering mechanism: Move elements DOWN
  void _moveDown(int index) {
    if (index == _stagingFiles.length - 1) return; // Already last
    setState(() {
      final temp = _stagingFiles[index];
      _stagingFiles[index] = _stagingFiles[index + 1];
      _stagingFiles[index + 1] = temp;
      _firebaseService.logEvent('MediaStaging: REORDER swapped indexes $index and ${index + 1} for preview alignment.');
    });
  }

  // Remove individual item from the staging array
  void _removeStagingFile(int index) {
    final title = _stagingFiles[index].name;
    setState(() {
      _stagingFiles.removeAt(index);
    });
    _firebaseService.logEvent('MediaStaging: REMOVE asset "$title" dropped from staging draft.');
  }

  // Sync state & save complete campaign in firebase service
  void _submitSaveCampaignProject() {
    final projectTitle = _projectTitleController.text.trim();
    if (projectTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please offer a friendly title for your saved studio project.')),
      );
      return;
    }

    if (_stagingFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files staged! Add at least 1 file to save the campaign workspace.')),
      );
      return;
    }

    if (!_disclaimerAccepted) {
      _showDisclaimerRequiredDialog();
      return;
    }

    // Save
    _firebaseService.saveAdvancedUploadProject(
      title: projectTitle,
      files: _stagingFiles,
      disclaimerConfirmed: _disclaimerAccepted,
    );

    // Leave entries registered, but clear unsaved staging array
    setState(() {
      _stagingFiles.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF381E72),
        content: Text(
          'Project "$projectTitle" securely saved & synced with standard legal disclaimers!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Interactive simulator logic: Preview designated item
  void _setPreviewFile(UploadedMediaItem file) {
    setState(() {
      _previewingFile = file;
      _isPlayingAudioDemo = false;
    });
    _firebaseService.logEvent('MediaPreview: LOADED raw object preview for "${file.name}" [Type: ${file.type}]');
  }

  @override
  Widget build(BuildContext context) {
    final listSavedProjects = _firebaseService.advancedUploadProjects;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAestheticHeaderBanner(),
          const SizedBox(height: 16),

          // MANDATORY DISCLAIMER
          _buildCopyrightDisclaimerSection(),
          const SizedBox(height: 18),

          // LIVE PREVIEW CONSOLE DRAWER
          _buildActiveLivePreviewDeck(),
          const SizedBox(height: 18),

          // ADD ASSET CONTROLS & BATCH EXPLORER
          _buildSectionHeader('SIMULATED FILE pickers', Icons.add_to_photos_outlined),
          const SizedBox(height: 10),
          _buildSimPickerChoiceGrid(),
          const SizedBox(height: 12),
          _buildSimDirectFileAdderForm(),
          const SizedBox(height: 18),

          // STAGING AREA FOR ACTIVE BATCH WITH REORDER / REMOVE PROPS
          _buildSectionHeader('STAGED WORKSPACE ASSETS (${_stagingFiles.length})', Icons.drive_folder_upload_outlined),
          const SizedBox(height: 10),
          _buildStagingFilesPlayground(),
          const SizedBox(height: 18),

          // SAVE CAMPAIGN FORM
          _buildSaveCampaignSubmitPanel(),
          const SizedBox(height: 24),

          // SAVED PLATFORM CAMPAIGNS
          _buildSectionHeader('Saved Studio Platforms (${listSavedProjects.length})', Icons.cloud_done_outlined),
          const SizedBox(height: 10),
          _buildSavedPlatformProjectsLedger(listSavedProjects),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC4FF62), size: 18),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildAestheticHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC4FF62).withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4FF62).withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC4FF62)),
            child: const Icon(Icons.drive_folder_upload, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ADVANCED STUDIO MEDIA UPLOADER', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Support camera assets, studio captures, multi-file reordering, and copyright checks.', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyrightDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _disclaimerAccepted ? const Color(0x13FFFFFF) : Colors.redAccent.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _disclaimerAccepted ? const Color(0xFF49454F) : Colors.redAccent.withAlpha((0.4 * 255).round()),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _disclaimerAccepted ? Icons.verified_user : Icons.gavel,
                color: _disclaimerAccepted ? const Color(0xFFC4FF62) : Colors.orangeAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'MANDATORY COPYRIGHT STIPULATION',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '"I confirm that I own this content or have permission to use it. I am responsible for any copyright or legal issue."',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _disclaimerAccepted,
                activeColor: const Color(0xFFC4FF62),
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white54, width: 1.5),
                onChanged: (val) {
                  setState(() {
                    _disclaimerAccepted = val ?? false;
                  });
                  _firebaseService.logEvent(
                    'Legals: Creator toggle checked - DisclaimerConfirmed=$_disclaimerAccepted',
                  );
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _disclaimerAccepted = !_disclaimerAccepted;
                    });
                  },
                  child: Text(
                    'I certify responsibility & copyright clearance compliance',
                    style: TextStyle(
                      color: _disclaimerAccepted ? const Color(0xFFC4FF62) : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLivePreviewDeck() {
    UploadedMediaItem? viewItem = _previewingFile;
    if (viewItem == null && _stagingFiles.isNotEmpty) {
      viewItem = _stagingFiles.first;
    }

    if (viewItem == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2930),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF49454F)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.video_library, color: Colors.white24, size: 36),
              SizedBox(height: 8),
              Text('Console Monitor Idle', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Stage or select physical items to display mock previews.', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    // Determine preview mock template based on asset category
    final isAudio = viewItem.type == 'Music' || viewItem.type == 'Song' || viewItem.type == 'Voiceover' || viewItem.type == 'Instrumental Sound';
    final isVideo = viewItem.type == 'Video';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF130F26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0BCFF).withAlpha((0.5 * 255).round()), width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Simulated Visual Window
          if (isAudio) ...[
            // Waveform simulation
            Container(
              height: 120,
              color: Colors.black26,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.audiotrack, color: Color(0xFFC4FF62), size: 30),
                  const SizedBox(height: 8),
                  Text(
                    'PLAYBACK: ${viewItem.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Animated waveform visual loops
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(12, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          double factor = _isPlayingAudioDemo ? (0.2 + (0.8 * Random().nextDouble())) : 0.15;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: 5,
                            height: 10 + (25 * factor),
                            decoration: BoxDecoration(
                              color: _isPlayingAudioDemo ? const Color(0xFFC4FF62) : Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ] else if (isVideo) ...[
            Container(
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1536440136628-849c177e76a1'), // cinema layout
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Simulated MP4 Player node: ${viewItem.name}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        const Text('0:15 / 1:30', style: TextStyle(color: Colors.white54, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Photo classes (DSLR, Portrait, regular)
            Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(viewItem.url),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'IMAGE PREVIEW: ${viewItem.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.photo_size_select_actual, color: Color(0xFFC4FF62), size: 16),
                  ],
                ),
              ),
            ),
          ],

          // Monitor Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF2B2930),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getIconForType(viewItem.type), color: const Color(0xFFC4FF62), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            viewItem.type.toUpperCase(),
                            style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(viewItem.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), softWrap: true, maxLines: 1),
                    ],
                  ),
                ),
                if (isAudio) ...[
                  IconButton(
                    icon: Icon(_isPlayingAudioDemo ? Icons.stop_circle : Icons.play_circle, color: const Color(0xFFC4FF62), size: 28),
                    onPressed: () {
                      setState(() {
                        _isPlayingAudioDemo = !_isPlayingAudioDemo;
                      });
                      _firebaseService.logEvent(
                        _isPlayingAudioDemo
                            ? 'VirtualPlayer: AUDIO start mock playback node and trigger visualizer waves'
                            : 'VirtualPlayer: AUDIO paused',
                      );
                    },
                  ),
                ],
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    viewItem.size,
                    style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimPickerChoiceGrid() {
    // Quick types to simulate instantaneous picker
    final typesList = [
      {'label': 'Photos', 'count': 'Photo'},
      {'label': 'Portrait Photos', 'count': 'Portrait Photo'},
      {'label': 'DSLR Raw Images', 'count': 'DSLR Photo'},
      {'label': 'Reels Videos', 'count': 'Video'},
      {'label': 'Studio Music', 'count': 'Music'},
      {'label': 'Full Songs', 'count': 'Song'},
      {'label': 'Voiceovers', 'count': 'Voiceover'},
      {'label': 'Instrumentals', 'count': 'Instrumental Sound'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select a preset to auto-stage immediately:',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _openBatchUploadSelector,
              child: const Row(
                children: [
                  Icon(Icons.folder_shared_outlined, color: Color(0xFFC4FF62), size: 14),
                  SizedBox(width: 4),
                  Text('BATCH STUDIO FILES', style: TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: typesList.map((type) {
            return InkWell(
              onTap: () {
                // Find a matching preset from sample pool or make up an instant one
                final foundPreset = _sampleAssetPool.firstWhere(
                  (element) => element['type'] == type['count'],
                  orElse: () => {
                    'name': 'Studio_Recording_${Random().nextInt(89) + 10}${_getExtensionForType(type['count']!)}',
                    'type': type['count']!,
                    'size': '${(Random().nextDouble() * 5 + 1).toStringAsFixed(1)} MB',
                    'url': _mockUrlForType(type['count']!),
                  },
                );
                _addSampleItem(foundPreset);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2930),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF49454F)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getIconForType(type['count']!), color: const Color(0xFFD0BCFF), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      type['label']!,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.add, color: Color(0xFFC4FF62), size: 11),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSimDirectFileAdderForm() {
    final fileTypes = [
      'Photo',
      'DSLR Photo',
      'Portrait Photo',
      'Video',
      'Music',
      'Song',
      'Voiceover',
      'Instrumental Sound'
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x0EFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: Color(0xFFD0BCFF), size: 14),
              SizedBox(width: 6),
              Text(
                'Manual Custom Metadata Injector',
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _customFileNameController,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Enter sound name or capture title...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                      filled: true,
                      fillColor: Colors.black26,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF49454F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF49454F)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF1F1B2C),
                    value: _selectedFileType,
                    style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontWeight: FontWeight.bold),
                    items: fileTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedFileType = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC4FF62),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(0, 38),
                ),
                onPressed: _addCustomTypedFile,
                child: const Text('ADD TO BATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStagingFilesPlayground() {
    if (_stagingFiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2930),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF49454F)),
        ),
        child: const Center(
          child: Text(
            'Staging array is empty. Use file pickers or presets above to pile items.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('*Use reorder keys to configure media sequence index', style: TextStyle(color: Colors.white38, fontSize: 9, fontStyle: FontStyle.italic)),
              Text('Drag-less Reorder Control', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _stagingFiles.length,
          itemBuilder: (context, index) {
            final f = _stagingFiles[index];
            final previewIcon = _getIconForType(f.type);

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2930),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF49454F)),
              ),
              child: Row(
                children: [
                  // Index bullet
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Preview image thumbnail or placeholder icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 42,
                      height: 42,
                      color: Colors.black26,
                      child: (f.type.contains('Photo') && f.url.startsWith('http'))
                          ? Image.network(f.url, fit: BoxFit.cover, errorBuilder: (c, o, s) => Icon(previewIcon, color: Colors.amber, size: 16))
                          : Icon(previewIcon, color: Colors.cyanAccent, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // File description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                f.type.toUpperCase(),
                                style: const TextStyle(color: Color(0xFF938F99), fontSize: 7, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              f.size,
                              style: const TextStyle(color: Colors.white38, fontSize: 8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Reorder buttons (Move Up / Down)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: index == 0 ? null : () => _moveUp(index),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: index == 0 ? Colors.white12 : const Color(0xFFC4FF62),
                          size: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: index == _stagingFiles.length - 1 ? null : () => _moveDown(index),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: index == _stagingFiles.length - 1 ? Colors.white12 : const Color(0xFFC4FF62),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Action Button Deck
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF381E72),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 28),
                    ),
                    onPressed: () => _setPreviewFile(f),
                    child: const Text('PREVIEW', style: TextStyle(fontSize: 9, color: Color(0xFFD0BCFF), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 4),

                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: () => _removeStagingFile(index),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveCampaignSubmitPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF381E72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.save_as, color: Color(0xFFC4FF62), size: 16),
              SizedBox(width: 8),
              Text('Save Campaign Draft', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _projectTitleController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Firestore Document Title',
              labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC4FF62),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _submitSaveCampaignProject,
            icon: const Icon(Icons.cloud_done),
            label: const Text(
              'SYNC & SAVE ENTIRE CAMPAIGN',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlatformProjectsLedger(List<AdvancedUploadProject> projects) {
    if (projects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2930),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF49454F)),
        ),
        child: const Center(
          child: Text(
            'No saved Advanced Upload projects registered in Firestore.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final p = projects[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2930),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF49454F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF381E72), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      '${p.files.length} FILES',
                      style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 16),
              
              // Small chips representing content composition
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: p.files.map((file) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getIconForType(file.type), color: const Color(0xFFC4FF62), size: 10),
                        const SizedBox(width: 4),
                        Text(
                          file.name,
                          style: const TextStyle(color: Colors.white30, fontSize: 8),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified, color: Color(0xFFC4FF62), size: 12),
                      SizedBox(width: 4),
                      Text('Copyright stipulations sealed', style: TextStyle(color: Colors.white54, fontSize: 9)),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          // Quick load campaign back into the active editing playground list
                          setState(() {
                            _stagingFiles.clear();
                            _stagingFiles.addAll(p.files);
                            _projectTitleController.text = p.title;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Campaign loaded into the active staging area! You can reorder or adjust files.')),
                          );
                        },
                        icon: const Icon(Icons.create, size: 12, color: Color(0xFFD0BCFF)),
                        label: const Text('EDIT', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => _firebaseService.deleteAdvancedUploadProject(p.id),
                        icon: const Icon(Icons.delete, size: 12, color: Colors.redAccent),
                        label: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Photo':
        return Icons.photo_library_outlined;
      case 'Portrait Photo':
        return Icons.portrait_outlined;
      case 'DSLR Photo':
        return Icons.camera_alt_outlined;
      case 'Video':
        return Icons.videocam_outlined;
      case 'Music':
        return Icons.album_outlined;
      case 'Song':
        return Icons.queue_music_outlined;
      case 'Voiceover':
        return Icons.record_voice_over_outlined;
      case 'Instrumental Sound':
        return Icons.music_note_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _getExtensionForType(String type) {
    if (type.contains('Photo')) return '.jpg';
    if (type == 'Video') return '.mp4';
    if (type == 'Voiceover' || type == 'Instrumental Sound') return '.wav';
    return '.mp3';
  }

  String _mockUrlForType(String type) {
    if (type == 'DSLR Photo') return 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e';
    if (type == 'Portrait Photo') return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb';
    return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e';
  }
}