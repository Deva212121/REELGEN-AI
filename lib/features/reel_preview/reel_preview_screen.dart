import 'package:flutter/material.dart';

class ReelPreviewScreen extends StatefulWidget {
  const ReelPreviewScreen({super.key});

  @override
  State<ReelPreviewScreen> createState() => _ReelPreviewScreenState();
}

class _ReelPreviewScreenState extends State<ReelPreviewScreen> {
  int _likes = 1248;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        maxHeight: 520,
        maxWidth: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF49454F), width: 2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF381E72), Color(0xFF0F0A1E)],
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 18, spreadRadius: 2)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Mock Dynamic Graphics Background
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.slow_motion_video, size: 60, color: Color(0xFFC4FF62)),
                  const SizedBox(height: 10),
                  const Text('REELGEN AI SCREENPLAY PLAYER', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.black, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Status: Live Streaming Simulation', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 10)),
                  ),
                ],
              ),
              // Gradient Overlay for visibility of lyrics / labels
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.6, 1.0],
                  ),
                ),
              ),
              // Floating Sidebar for interactive triggers
              Positioned(
                right: 12,
                bottom: 110,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.pink : Colors.white, size: 28),
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                          _isLiked ? _likes++ : _likes--;
                        });
                      },
                    ),
                    Text('$_likes', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.white, size: 26),
                      onPressed: () {},
                    ),
                    const Text('38', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white, size: 26),
                      onPressed: () {},
                    ),
                    const Text('114', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Core video metadata details details
              Positioned(
                left: 16,
                bottom: 16,
                right: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC4FF62)),
                          child: const Icon(Icons.person, size: 14, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        const Text('@creator_genius', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFC4FF62), borderRadius: BorderRadius.circular(4)),
                          child: const Text('JOINED', style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.black)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This skin serum changed my entire skincare routine forever! Unbelievable results in 48 hours. #skincare #hydration #review #gemini_briefs',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 10, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.audiotrack, size: 10, color: Color(0xFFD0BCFF)),
                          SizedBox(width: 6),
                          Text('Original Audio Cloned V1 - ReelGen AI', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
