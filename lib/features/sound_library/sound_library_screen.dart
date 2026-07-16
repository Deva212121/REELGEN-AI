import 'package:flutter/material.dart';

class SoundLibraryScreen extends StatelessWidget {
  const SoundLibraryScreen({super.key});

  final List<String> _sounds = const [
    'Happy', 'Sad', 'Romantic', 'Party', 'Classical', 'Folk', 'Pop', 'Jazz',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Library'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _sounds.length,
          itemBuilder: (context, index) {
            final sound = _sounds[index];
            return Card(
              child: InkWell(
                onTap: () {
                  // Play sound preview
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 36,
                        color: const Color(0xFFC4FF62),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sound,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}