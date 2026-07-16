import '../agents/reel_agent.dart';
import '../agents/marketing_agent.dart';
import '../agents/image_agent.dart';
import '../agents/brand_agent.dart';

class SelloreAIService {
  final ReelAgent _reelAgent = ReelAgent();
  final MarketingAgent _marketingAgent = MarketingAgent();
  final ImageAgent _imageAgent = ImageAgent();
  final BrandAgent _brandAgent = BrandAgent();

  Future<String> generateReelPackage(String product, String influencer) async {
    return await _reelAgent.generateCompletePackage(product);
  }

  Future<String> generateMarketingPlan(
    String product,
    bool includeWhatsApp,
    bool includeInstagramStories,
    bool includeInstagramReels,
    bool includeInstagramPosts,
    bool includeFacebook,
    bool includePaidAds,
  ) async {
    return await _marketingAgent.generateCompletePlan(
      product,
      includeWhatsApp,
      includeInstagramStories,
      includeInstagramReels,
      includeInstagramPosts,
      includeFacebook,
      includePaidAds,
    );
  }

  Future<String> generateImagePrompts(String product) async {
    return await _imageAgent.generateImagePrompts(product);
  }

  Future<String> generateBrandIdentity(String product) async {
    return await _brandAgent.generateBrandIdentity(product);
  }
}