class ReelAgent {
  Future<String> generateCompletePackage(String product) async {
    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎬 REEL PACKAGE — $product
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[REEL CONCEPTS]
1. "The Unboxing" — Show product opening + first reaction
2. "The Styling" — Show how to style the product
3. "The Review" — Honest review + pros/cons
4. "The Transformation" — Before/after with product
5. "The Comparison" — Compare with similar products

[COMPLETE SCRIPT]
Duration: 30 seconds
Scene 1: [0-5 sec] - Hook: "Stop scrolling! This $product will change your life!"
Scene 2: [5-15 sec] - Product showcase: Show $product from all angles
Scene 3: [15-25 sec] - Benefits: Why $product is a must-have
Scene 4: [25-30 sec] - CTA: "Link in bio! Order now!"

[CAPTION]
✨ The $product you've been waiting for!
Limited stock — grab yours before it's gone!
Link in bio 👆

[HASHTAGS]
#${product.replaceAll(' ', '')} #Jewellery #SelloreAI #Influencer #Trending #Viral

[VIDEO PRODUCTION GUIDE]
Shot 1: [5 sec] [Close-up] [Natural Light] [Product on white background]
Shot 2: [10 sec] [Medium Shot] [Ring Light] [Model wearing product]
Shot 3: [10 sec] [Close-up] [Spotlight] [Product rotating]
Shot 4: [5 sec] [Wide Shot] [Natural Light] [Model smiling]

[EQUIPMENT SETUP]
Camera: 4K, 30fps
Lighting: Ring light + Softbox
Equipment: Tripod, Ring Light
Total Cost: ₹5,000-10,000

[EDITING INSTRUCTIONS]
App: InShot or CapCut
Transitions: Zoom, Fade
Background Music: Uplifting pop

[THUMBNAIL GUIDE]
Product close-up + "Limited Stock!" text

[TRACKING LINK]
Link: sellore.ai/t/influencer-${product.replaceAll(' ', '-').toLowerCase()}-${DateTime.now().day}

[POSTING PLAN]
Best Time: 12 PM - 2 PM or 7 PM - 9 PM
Platform: Instagram + YouTube Shorts

[PREDICTED PERFORMANCE]
Views: 5,000 - 50,000
Sales: 10 - 100
Your Commission: ₹500 - ₹5,000
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}