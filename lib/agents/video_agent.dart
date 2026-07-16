class VideoAgent {
  Future<String> generateVideoScript(String product) async {
    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎥 VIDEO SCRIPT — $product
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[VIDEO CONCEPT]
Hook: "Watch how this $product transforms your style!"
Duration: 60 seconds
Format: Product showcase + styling + benefits

[SCENE BREAKDOWN]
Scene 1: [0-10 sec] - Hook + Product reveal
Scene 2: [10-30 sec] - Product close-up + features
Scene 3: [30-50 sec] - Styling + outfit ideas
Scene 4: [50-60 sec] - CTA + Link

[VOICEOVER]
"This $product is a game-changer! Premium quality, affordable price, and perfect for every occasion. 
Order now and get free shipping!"

[BGM SUGGESTION]
Genre: Uplifting pop
Tempo: 120 BPM
Mood: Energetic, joyful

[VISUAL EFFECTS]
- Slow-motion product reveal
- Sparkle effect on product
- Text overlays with price + features
- Transition: Fade + Zoom
''';
  }
}