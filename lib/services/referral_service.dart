class ReferralService {
  static const String _webHost = 'reelgen-ai-6ec95.web.app';
  static final RegExp _secureReferralCodePattern =
      RegExp(r'^[A-Za-z0-9]{16,64}$');

  // Generate unique referral link for influencer + product
  static String generateReferralLink({
    required String influencerId,
    required String productId,
  }) {
    return Uri(
      scheme: 'https',
      host: _webHost,
      pathSegments: <String>['product', productId],
      queryParameters: <String, String>{'ref': influencerId},
    ).toString();
  }

  // Generate a referral link without exposing the influencer ID.
  static String generateSecureReferralLink({
    required String productId,
    required String referralCode,
  }) {
    final normalizedProductId = productId.trim();
    final normalizedReferralCode = referralCode.trim();

    if (normalizedProductId.isEmpty) {
      throw const FormatException('A valid product ID is required.');
    }
    if (!isValidReferralCode(normalizedReferralCode)) {
      throw const FormatException('A valid secure referral code is required.');
    }

    return Uri(
      scheme: 'https',
      host: _webHost,
      pathSegments: <String>['product', normalizedProductId],
      queryParameters: <String, String>{'ref': normalizedReferralCode},
    ).toString();
  }

  // Extract influencer ID from referral link
  static String extractInfluencerId(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['ref'] ?? '';
    } on FormatException {
      return '';
    }
  }

  // Extract and validate the secure referral code from a URL.
  static String extractReferralCode(String url) {
    try {
      final uri = Uri.parse(url);
      final referralCode = uri.queryParameters['ref']?.trim() ?? '';
      return isValidReferralCode(referralCode) ? referralCode : '';
    } on FormatException {
      return '';
    }
  }

  // Extract product ID from referral link
  static String extractProductId(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.length == 2 && segments.first == 'product') {
        return segments.last.trim();
      }
      return '';
    } on FormatException {
      return '';
    }
  }

  static bool isValidReferralCode(String referralCode) {
    return _secureReferralCodePattern.hasMatch(referralCode.trim());
  }

  static bool isSupportedSecureReferralLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' &&
          uri.host == _webHost &&
          extractProductId(url).isNotEmpty &&
          extractReferralCode(url).isNotEmpty;
    } on FormatException {
      return false;
    }
  }
}
