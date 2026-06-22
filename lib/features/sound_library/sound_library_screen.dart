import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/firestore_models.dart';

class SoundLibraryScreen extends StatefulWidget {
  const SoundLibraryScreen({super.key});

  @override
  State<SoundLibraryScreen> createState() => _SoundLibraryScreenState();
}

class _SoundLibraryScreenState extends State<SoundLibraryScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Local active playbacks simulation stats
  String? _currentlyPlayingSoundId;
  bool _isPlaying = false;
  double _playbackPercentage = 0.35;
  late AnimationController _waveController;

  // Search & Filter state
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All'; // 'All', 'Classical', 'Western', 'Atmospheric', 'Custom'

  // Custom upload form controllers
  final _uploadNameController = TextEditingController();
  final _uploadArtistController = TextEditingController();
  String _uploadFileType = 'user_song'; // 'user_song' or 'user_instrumental'
  String _uploadDuration = '1:30';

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _firebaseService.addListener(_onFirebaseStateChanged);
  }

  void _onFirebaseStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _uploadNameController.dispose();
    _uploadArtistController.dispose();
    _firebaseService.removeListener(_onFirebaseStateChanged);
    super.dispose();
  }

  // Action: Choose track & preview
  void _togglePreview(SoundTrack sound) {
    setState(() {
      if (_currentlyPlayingSoundId == sound.id) {
        _isPlaying = !_isPlaying;
      } else {
        _currentlyPlayingSoundId = sound.id;
        _isPlaying = true;
        _playbackPercentage = 0.15;
      }
      
      // Log event
      if (_isPlaying) {
        _firebaseService.logEvent('AudioPreview: PLAY sound_library/${sound.id} ("${sound.name}") [Virtual Synthesizer Node Active]');
      } else {
        _firebaseService.logEvent('AudioPreview: PAUSED demo sound_library/${sound.id}');
      }
    });
  }

  // Action: Bind/Use Sound in Reel
  void _bindSoundToReel(SoundTrack sound) {
    _firebaseService.selectSoundForReel(sound.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFC4FF62),
        content: Text(
          'Sound Bounded Successfully! "${sound.name}" is now set as the active soundtrack for your next video reel generation.',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Action: Upload customized track
  void _submitCustomUpload() {
    final title = _uploadNameController.text.trim();
    final artist = _uploadArtistController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Please select or specify a title for your custom audio upload.'),
        ),
      );
      return;
    }

    _firebaseService.uploadCustomAudio(
      name: title,
      artist: artist.isNotEmpty ? artist : 'Self Creative',
      fileType: _uploadFileType,
      duration: _uploadDuration,
    );

    _uploadNameController.clear();
    _uploadArtistController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF381E72),
        content: Text(
          'Custom $_uploadFileType published! Real-time synced metadata registered in Firestore under sound_library.',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSounds = _firebaseService.soundLibrary;

    // Filter list
    final filteredSounds = allSounds.where((sound) {
      // search match
      final queryMatch = sound.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sound.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sound.artist.toLowerCase().contains(_searchQuery.toLowerCase());

      // category match
      bool categoryMatch = true;
      if (_selectedCategoryFilter == 'Classical') {
        categoryMatch = sound.category.contains('Indian') || sound.category.contains('Classical') || sound.category.contains('Folk');
      } else if (_selectedCategoryFilter == 'Western') {
        categoryMatch = sound.category.contains('Western') || sound.category.contains('Strings') || sound.category.contains('Keyboards') || sound.category.contains('Woodwind') || sound.category.contains('Percussion Kit');
      } else if (_selectedCategoryFilter == 'Atmospheric') {
        categoryMatch = sound.category.contains('Atmospheric') || sound.category.contains('Beats') || sound.category.contains('Melodic');
      } else if (_selectedCategoryFilter == 'Custom') {
        categoryMatch = sound.fileType != 'predefined';
      }

      return queryMatch && categoryMatch;
    }).toList();

    SoundTrack? selectedSoundObj;
    if (_currentlyPlayingSoundId != null) {
      try {
        selectedSoundObj = allSounds.firstWhere((s) => s.id == _currentlyPlayingSoundId);
      } catch (_) {
        selectedSoundObj = null;
      }
    }

    // fallback first if none selected
    selectedSoundObj ??= allSounds.isNotEmpty ? allSounds.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActiveSoundPreviewDeck(selectedSoundObj),
          const SizedBox(height: 18),
          _buildSearchAndFilters(),
          const SizedBox(height: 14),
          _buildSectionHeader('Available Tracks (${filteredSounds.length})', Icons.library_music_outlined),
          const SizedBox(height: 10),
          _buildTracksGridList(filteredSounds),
          const SizedBox(height: 24),
          _buildImportPublisherCard(),
          const SizedBox(height: 20),
          _buildVirtualMixerNote(),
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
            fontWeight: FontWeight.black,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSoundPreviewDeck(SoundTrack? selectedSound) {
    if (selectedSound == null) return const SizedBox();

    final isSelectedActiveInApp = _firebaseService.selectedReelSoundId == selectedSound.id;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B2930),
            Color(0xFF130F26),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelectedActiveInApp ? const Color(0xFFC4FF62).withOpacity(0.5) : const Color(0xFF49454F),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelectedActiveInApp ? const Color(0x33C4FF62) : const Color(0x13FFFFFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelectedActiveInApp ? Icons.check_circle : Icons.radio_button_off,
                      size: 10,
                      color: isSelectedActiveInApp ? const Color(0xFFC4FF62) : Colors.white38,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isSelectedActiveInApp ? 'ACTIVE ON GENERATOR' : 'NOT BOUND',
                      style: TextStyle(
                        color: isSelectedActiveInApp ? const Color(0xFFC4FF62) : Colors.white38,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'TYPE: ${selectedSound.fileType.replaceAll('_', ' ').toUpperCase()}',
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Play pause bubble
              GestureDetector(
                onTap: () => _togglePreview(selectedSound),
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFD0BCFF), Color(0xFFFF4B8A)],
                    ),
                  ),
                  child: Icon(
                    _isPlaying && _currentlyPlayingSoundId == selectedSound.id
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedSound.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selectedSound.category} • By ${selectedSound.artist}',
                      style: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Waveform Animation simulations
          Row(
            children: [
              const Text('0:10', style: TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace')),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return SizedBox(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(24, (index) {
                          double baseHeight = 4.0;
                          double multiplier = 20.0;
                          
                          // Synthesize wave animation
                          double activeScaling = 1.0;
                          if (_isPlaying && _currentlyPlayingSoundId == selectedSound!.id) {
                            activeScaling = 0.2 + (0.8 * (index % 3 == 0 
                              ? _waveController.value 
                              : (index % 2 == 0 ? 1.0 - _waveController.value : _waveController.value * 0.5)));
                          } else {
                            activeScaling = 0.15; // static idle look
                          }

                          double finalHeight = baseHeight + (multiplier * activeScaling * (index < 12 ? (index + 1) / 12 : (24 - index) / 12));

                          return Container(
                            width: 3.5,
                            height: finalHeight,
                            decoration: BoxDecoration(
                              color: (_isPlaying && _currentlyPlayingSoundId == selectedSound!.id)
                                  ? (index / 24 < _playbackPercentage ? const Color(0xFFC4FF62) : const Color(0xFFD0BCFF).withOpacity(0.4))
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                selectedSound.duration,
                style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4FF62),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () => _bindSoundToReel(selectedSound!),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text(
                    'USE THIS SOUND IN REEL',
                    style: TextStyle(fontWeight: FontWeight.black, fontSize: 11, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _playbackPercentage = (_playbackPercentage + 0.15) % 1.05;
                    _firebaseService.logEvent('VirtualPlayer: SEEK audio clip preview timeline to ${_playbackPercentage.toStringAsFixed(2)}%');
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF381E72),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD0BCFF).withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.forward_5, size: 14, color: Color(0xFFD0BCFF)),
                      SizedBox(width: 4),
                      Text('SEEK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final categories = ['All', 'Classical', 'Western', 'Atmospheric', 'Custom'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search TextField
        TextField(
          style: const TextStyle(color: Colors.white, fontSize: 12),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search instrument, category or artist...',
            hintStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 12),
            prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF938F99)),
            filled: true,
            fillColor: const Color(0xFF2B2930),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF49454F)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        
        // Horizontal Quick Filter Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategoryFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    cat == 'Atmospheric' ? 'Cinematic & Scenic' : cat == 'Custom' ? 'My Uploads' : cat,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFC4FF62),
                  backgroundColor: const Color(0x3349454F),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategoryFilter = cat;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTracksGridList(List<SoundTrack> sounds) {
    if (sounds.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2930),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF49454F)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.audiotrack_outlined, color: Colors.white24, size: 36),
              SizedBox(height: 12),
              Text(
                'No soundtracks match your query criteria.',
                style: TextStyle(color: Color(0xFF938F99), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                'Try clearing search or upload custom audios below.',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];
        final isSelectedPreview = _currentlyPlayingSoundId == sound.id;
        final isPlayingHere = isSelectedPreview && _isPlaying;
        final isApplied = _firebaseService.selectedReelSoundId == sound.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelectedPreview ? const Color(0x1F381E72) : const Color(0xFF2B2930),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isApplied 
                  ? const Color(0xFFC4FF62) 
                  : (isSelectedPreview ? const Color(0xFFD0BCFF).withOpacity(0.5) : const Color(0xFF49454F)),
            ),
          ),
          child: Row(
            children: [
              // Small play indicator bubble
              GestureDetector(
                onTap: () => _togglePreview(sound),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPlayingHere ? const Color(0xFFC4FF62) : const Color(0x13FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlayingHere ? Icons.pause : Icons.play_arrow,
                    size: 16,
                    color: isPlayingHere ? Colors.black : const Color(0xFFD0BCFF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sound.name,
                          style: TextStyle(
                            color: isApplied ? const Color(0xFFC4FF62) : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isApplied) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC4FF62),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('BOUND', style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sound.category} • ${sound.artist}',
                      style: const TextStyle(color: Color(0xFF938F99), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              
              // Duration view
              Text(
                sound.duration,
                style: const TextStyle(color: Colors.white24, fontSize: 10, fontFamily: 'monospace'),
              ),
              const SizedBox(width: 10),

              // Use button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  side: BorderSide(
                    color: isApplied ? const Color(0xFFC4FF62) : const Color(0xFFD0BCFF).withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _bindSoundToReel(sound),
                child: Text(
                  isApplied ? 'SELECTED' : 'BIND',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isApplied ? const Color(0xFFC4FF62) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportPublisherCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Creator Audio Upload Center', Icons.cloud_upload_outlined),
          const SizedBox(height: 12),
          const Text(
            'Upload custom recordings, music soundtracks, or original instrumental background audios into your private Firestore workspace.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 14),
          
          // Switch for file track level
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _uploadFileType = 'user_song'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _uploadFileType == 'user_song' ? const Color(0xFF381E72) : const Color(0x3349454F),
                      border: Border.all(
                        color: _uploadFileType == 'user_song' ? const Color(0xFFD0BCFF) : Colors.transparent,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.album_outlined, size: 16, color: Colors.white70),
                        SizedBox(height: 4),
                        Text('Original Song / Music', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _uploadFileType = 'user_instrumental'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _uploadFileType == 'user_instrumental' ? const Color(0xFF381E72) : const Color(0x3349454F),
                      border: Border.all(
                        color: _uploadFileType == 'user_instrumental' ? const Color(0xFFD0BCFF) : Colors.transparent,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.music_note_outlined, size: 16, color: Colors.white70),
                        SizedBox(height: 4),
                        Text('Instrumental Track', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Track Name
          TextField(
            controller: _uploadNameController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Audio Title / Sound Name',
              labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
              prefixIcon: const Icon(Icons.short_text, size: 14, color: Colors.white38),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
            ),
          ),
          const SizedBox(height: 10),

          // Artist Name
          TextField(
            controller: _uploadArtistController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Artist / Creative Owner',
              labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
              prefixIcon: const Icon(Icons.person_outline, size: 14, color: Colors.white38),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
            ),
          ),
          const SizedBox(height: 10),

          // Duration picker simulation
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _uploadDuration,
                  dropdownColor: const Color(0xFF2B2930),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Audio Duration Length',
                    labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
                    prefixIcon: const Icon(Icons.hourglass_bottom, size: 14, color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0x13FFFFFF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
                  ),
                  items: ['0:30', '0:45', '1:00', '1:30', '2:00', '3:15']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _uploadDuration = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF381E72),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Color(0xFFD0BCFF), width: 0.8),
            ),
            onPressed: _submitCustomUpload,
            icon: const Icon(Icons.cloud_done_outlined, size: 16),
            label: const Text(
              'PUBLISH TO FIRESTORE POOL',
              style: TextStyle(fontWeight: FontWeight.black, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualMixerNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFC4FF62).withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4FF62).withOpacity(0.15)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFC4FF62), size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'MVP Architecture Check: Physical audio mixers and DSP overlay components are mock-represented at simulation levels with Firestore database linkages.',
              style: TextStyle(color: Colors.white60, fontSize: 9, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
