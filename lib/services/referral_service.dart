class ReferralService {
  // Generate unique referral link for influencer + product
  static String generateReferralLink({
    required String influencerId,
    required String productId,
  }) {
    return 'https://reelgen-ai-6ec95.web.app/product/$productId?ref=$influencerId';
  }

  // Extract influencer ID from referral link
  static String extractInfluencerId(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['ref'] ?? '';
    } catch (e) {
      return '';
    }
  }

  // Extract product ID from referral link
  static String extractProductId(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final parts = path.split('/');
      if (parts.length >= 3 && parts[1] == 'product') {
        return parts[2];
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}