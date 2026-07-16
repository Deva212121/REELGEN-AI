class ImageAgent {
  Future<String> generateImagePrompts(String product) async {
    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🖼️ IMAGE PROMPTS — $product
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[PRODUCT IMAGE]
"A professional product photography shot of $product on a white background, studio lighting, high resolution, 4K"

[LIFESTYLE IMAGE]
"A woman wearing $product, smiling, natural lighting, modern outfit, premium quality, 4K"

[POSTER]
"Minimalist poster design for $product, elegant typography, pastel colors, modern aesthetic"

[THUMBNAIL]
"Eye-catching thumbnail for $product, bold text, high contrast, vibrant colors, 1080x1080"

[INSTAGRAM CREATIVE]
"Stylish Instagram post for $product, flat lay, soft colors, modern aesthetic, 1080x1080"

[FACEBOOK AD]
"Engaging Facebook ad creative for $product, lifestyle shot, bold CTA, 1200x628"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}