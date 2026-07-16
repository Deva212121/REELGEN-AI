class TrackingAgent {
  static String generateTrackingLink(String influencer, String product) {
    return 'sellore.ai/t/$influencer-${product.replaceAll(' ', '-').toLowerCase()}-${DateTime.now().day}';
  }
}