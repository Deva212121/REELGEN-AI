class MarketingAgent {
  Future<String> generateCompletePlan(
    String product,
    bool includeWhatsApp,
    bool includeInstagramStories,
    bool includeInstagramReels,
    bool includeInstagramPosts,
    bool includeFacebook,
    bool includePaidAds,
  ) async {
    String output = '';

    if (includeWhatsApp) {
      output += '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 WHATSAPP STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   - Status: "✨ New Arrival! ${product} — Best price in India. DM to order! 📩"
   - Frequency: 2 times per day (morning + evening)
   - Add product photo + price
   - Reply to every DM within 10 minutes
   - Use WhatsApp Business for professional look

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

''';
    }

    if (includeInstagramStories) {
      output += '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📸 INSTAGRAM STORIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   - Type: 3-5 stories per day
   - Content: Product showcase, behind-the-scenes, customer reviews
   - Stickers: Poll, Question, Countdown
   - Hashtags: #${product.replaceAll(' ', '')} #Jewellery #SelloreAI #Trending
   - Best Time: 12 PM - 2 PM or 7 PM - 9 PM

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

''';
    }

    if (includeInstagramReels) {
      output += '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎬 INSTAGRAM REELS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   - 1 reel per day (use SelloreAI Reel Generator)
   - Trending audio + viral hooks
   - Post at 12 PM or 7 PM
   - Add trending hashtags
   - Use "Add Yours" sticker for engagement

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

''';
    }

    if (includeInstagramPosts) {
      output += '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📷 INSTAGRAM POSTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   - 1 post per day (product + caption + hashtags)
   - High-quality image + engaging caption
   - Best time: 12 PM - 2 PM or 7 PM - 9 PM
   - Carousel posts for multiple products
   - Tag product in post

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

''';
    }

    if (includeFacebook) {
      output += '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📘 FACEBOOK POSTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   - Share Instagram posts to Facebook
   - Join jewellery groups (5-10 groups)
   - Post 2-3 times per week in groups
   - Use Facebook Marketplace for listings

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

''';
    }

    if (includePaidAds) {
      output += '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 PAID MARKETING — ₹5000+ Budget
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. INSTAGRAM ADS (₹2000)
   - Campaign Type: Engagement + Sales
   - Target: Women aged 25-45, interest in jewellery, fashion
   - Creative: Product video + carousel
   - Budget: ₹500/day for 4 days

2. FACEBOOK ADS (₹1500)
   - Campaign Type: Conversions
   - Target: Women aged 25-45, interest in jewellery, lifestyle
   - Creative: Product image + CTA button
   - Budget: ₹500/day for 3 days

3. GOOGLE ADS (₹1000)
   - Campaign Type: Search + Shopping
   - Keywords: ${product}, Buy ${product} online
   - Budget: ₹200/day for 5 days

4. YOUTUBE ADS (₹500)
   - Campaign Type: In-stream
   - Target: Women aged 25-45, interest in jewellery
   - Creative: 15-30 second video ad

5. INFLUENCER MARKETING (₹0-5000)
   - Micro-influencers (10k-50k followers)
   - Free product + commission
   - 2-3 influencers per campaign

6. RETARGETING (₹500)
   - Show ads to people who visited link
   - Instagram + Facebook retargeting

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

''';
    }

    if (output.isEmpty) {
      return '⚠️ Please select at least one marketing option.';
    }

    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 MARKETING PLAN — $product
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$output

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ MARKETING PLAN COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}