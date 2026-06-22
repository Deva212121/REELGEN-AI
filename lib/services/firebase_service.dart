import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/firestore_models.dart';

class FirebaseService extends ChangeNotifier {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal() {
    // Seed initial data models to facilitate interactive preview
    _seedInitialCollections();
  }

  // Auth State
  FirestoreUser? _currentUser;
  FirestoreUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Real-time Firestore Local Collections List States
  final List<PromoProduct> marketplaceProducts = [];
  final List<ProductPromotion> productPromotions = [];
  final List<AffiliateLink> affiliateLinks = [];
  final List<GeneratedScript> generatedScripts = [];
  final List<VoiceSample> voiceSamples = [];
  final List<AvatarProfile> avatarProfiles = [];
  final List<PhotoshootProject> photoshootProjects = [];
  final List<ImageVideoProject> imageVideoProjects = [];
  final List<ParcelTracking> parcelTrackings = [];
  final List<VendorSettlement> vendorSettlements = [];
  final List<SoundTrack> soundLibrary = [];
  String? selectedReelSoundId;
  final List<AdvancedUploadProject> advancedUploadProjects = [];

  // Logs mimicking Firestore Transaction Audit Logs
  final List<String> firestoreLogs = [];

  void logEvent(String msg) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    firestoreLogs.insert(0, '[$timestamp UTC] $msg');
    notifyListeners();
  }

  void _seedInitialCollections() {
    marketplaceProducts.addAll([
      PromoProduct(id: 'prod_hydrate', name: 'Super Hydrate Serum', category: 'Skincare', vendorCode: 'VEN56879', payoutModel: '15% Commission (Est: \$4.50/click)'),
      PromoProduct(id: 'prod_peaks', name: 'Peak Nutrition Bites', category: 'Food & Beverage', vendorCode: 'VEN21844', payoutModel: '12% Commission (Est: \$2.10/order)'),
      PromoProduct(id: 'prod_sonic', name: 'Sonic Sound Waves XL', category: 'Electronics', vendorCode: 'VEN99301', payoutModel: '10% Commission (Est: \$15.00/order)'),
      PromoProduct(id: 'prod_earbuds', name: 'ReelGen Premium Earbuds', category: 'Electronics', vendorCode: 'VEN56879', payoutModel: '20% Commission (Est: \$19.99/order)'),
    ]);

    productPromotions.addAll([
      ProductPromotion(
        id: 'promo_7281',
        influencerId: '@active_creator',
        vendorId: 'vend_aqua',
        vendorCode: 'VEN56879',
        productId: 'prod_hydrate',
        productName: 'Super Hydrate Serum',
        approvalOtp: '483920',
        otpVerified: false,
        assignedAt: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'APPROVED',
      ),
      ProductPromotion(
        id: 'promo_9481',
        influencerId: '@active_creator',
        vendorId: 'vend_nutri',
        vendorCode: 'VEN21844',
        productId: 'prod_peaks',
        productName: 'Peak Nutrition Bites',
        approvalOtp: '',
        otpVerified: false,
        assignedAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'PENDING',
      ),
    ]);

    parcelTrackings.addAll([
      ParcelTracking(
        id: 'par_01',
        productName: 'Super Hydrate Serum',
        influencerId: '@active_creator',
        status: 'SHIPPED',
        customerConfirmed: null,
      ),
      ParcelTracking(
        id: 'par_02',
        productName: 'Peak Nutrition Bites',
        influencerId: '@active_creator',
        status: 'PACKED',
        customerConfirmed: null,
      )
    ]);

    vendorSettlements.addAll([
      VendorSettlement(
        settlementId: 'settle_101',
        vendorId: 'vend_aqua',
        vendorCode: 'VEN56879',
        orderId: 'ORD-7831',
        orderAmount: 120.00,
        settlementAmount: 102.00,
        settlementStatus: 'released',
        orderStatus: 'Settlement Released',
        orderDeliveredAt: DateTime.now().subtract(const Duration(days: 20)),
        releaseDate: DateTime.now().subtract(const Duration(days: 5)),
        releasedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      VendorSettlement(
        settlementId: 'settle_102',
        vendorId: 'vend_aqua',
        vendorCode: 'VEN56879',
        orderId: 'ORD-5291',
        orderAmount: 250.00,
        settlementAmount: 212.50,
        settlementStatus: 'processing',
        orderStatus: 'Settlement Processing',
        orderDeliveredAt: DateTime.now().subtract(const Duration(days: 10)),
        releaseDate: DateTime.now().add(const Duration(days: 5)),
        releasedAt: null,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
      VendorSettlement(
        settlementId: 'settle_103',
        vendorId: 'vend_aqua',
        vendorCode: 'VEN56879',
        orderId: 'ORD-4821',
        orderAmount: 95.00,
        settlementAmount: 80.75,
        settlementStatus: 'pending',
        orderStatus: 'Return Window Active',
        orderDeliveredAt: DateTime.now().subtract(const Duration(days: 4)),
        releaseDate: DateTime.now().add(const Duration(days: 11)),
        releasedAt: null,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      VendorSettlement(
        settlementId: 'settle_104',
        vendorId: 'vend_aqua',
        vendorCode: 'VEN56879',
        orderId: 'ORD-1903',
        orderAmount: 310.00,
        settlementAmount: 263.50,
        settlementStatus: 'pending',
        orderStatus: 'Shipped',
        orderDeliveredAt: null,
        releaseDate: null,
        releasedAt: null,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      VendorSettlement(
        settlementId: 'settle_105',
        vendorId: 'vend_nutri',
        vendorCode: 'VEN21844',
        orderId: 'ORD-6924',
        orderAmount: 80.00,
        settlementAmount: 68.00,
        settlementStatus: 'processing',
        orderStatus: 'Settlement Processing',
        orderDeliveredAt: DateTime.now().subtract(const Duration(days: 9)),
        releaseDate: DateTime.now().add(const Duration(days: 6)),
        releasedAt: null,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ]);

    soundLibrary.addAll([
      SoundTrack(
        id: 'snd_tabla',
        name: 'Tabla',
        category: 'Indian Percussion',
        artist: 'ReelGen Beats',
        audioUrl: 'https://example.com/audio/tabla.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '0:35',
      ),
      SoundTrack(
        id: 'snd_dhol',
        name: 'Dhol',
        category: 'Folk Rhythm',
        artist: 'ReelGen Beats',
        audioUrl: 'https://example.com/audio/dhol.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '0:42',
      ),
      SoundTrack(
        id: 'snd_dholak',
        name: 'Dholak',
        category: 'Classical Folk',
        artist: 'ReelGen Beats',
        audioUrl: 'https://example.com/audio/dholak.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '0:30',
      ),
      SoundTrack(
        id: 'snd_flute',
        name: 'Flute',
        category: 'Woodwind',
        artist: 'ReelGen Instrumentals',
        audioUrl: 'https://example.com/audio/flute.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '1:05',
      ),
      SoundTrack(
        id: 'snd_guitar',
        name: 'Guitar',
        category: 'Plucked Strings',
        artist: 'Studio Sessionist',
        audioUrl: 'https://example.com/audio/guitar.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '0:50',
      ),
      SoundTrack(
        id: 'snd_piano',
        name: 'Piano',
        category: 'Keyboards',
        artist: 'Studio Sessionist',
        audioUrl: 'https://example.com/audio/piano.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '1:20',
      ),
      SoundTrack(
        id: 'snd_violin',
        name: 'Violin',
        category: 'Bowed Strings',
        artist: 'Symphony Masters',
        audioUrl: 'https://example.com/audio/violin.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '1:10',
      ),
      SoundTrack(
        id: 'snd_harmonium',
        name: 'Harmonium',
        category: 'Bellows Wind',
        artist: 'Classical Ensemble',
        audioUrl: 'https://example.com/audio/harmonium.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '0:45',
      ),
      SoundTrack(
        id: 'snd_sitar',
        name: 'Sitar',
        category: 'Indian Strings',
        artist: 'Pandit Session',
        audioUrl: 'https://example.com/audio/sitar.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '1:15',
      ),
      SoundTrack(
        id: 'snd_shehnai',
        name: 'Shehnai',
        category: 'Festive Oboe',
        artist: 'Ustad Brass',
        audioUrl: 'https://example.com/audio/shehnai.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '0:40',
      ),
      SoundTrack(
        id: 'snd_drums',
        name: 'Drums',
        category: 'Percussion Kit',
        artist: 'Groove Band',
        audioUrl: 'https://example.com/audio/drums.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '0:55',
      ),
      SoundTrack(
        id: 'snd_cine_beats',
        name: 'Cinematic Beats',
        category: 'Atmospheric Beats',
        artist: 'Audio Architect',
        audioUrl: 'https://example.com/audio/cinematic.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '1:30',
      ),
      SoundTrack(
        id: 'snd_rom_instr',
        name: 'Romantic Instrumentals',
        category: 'Melodic Instrumental',
        artist: 'Heartstrings Duet',
        audioUrl: 'https://example.com/audio/romantic.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '1:45',
      ),
      SoundTrack(
        id: 'snd_fest_beats',
        name: 'Festival Beats',
        category: 'High-Energy Beats',
        artist: 'Dhol & Tasha Group',
        audioUrl: 'https://example.com/audio/festival.mp3',
        fileType: 'predefined',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '1:15',
      ),
    ]);

    advancedUploadProjects.addAll([
      AdvancedUploadProject(
        id: 'proj_adv_001',
        title: 'Festival Promo Assets #1',
        disclaimerConfirmed: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        files: [
          UploadedMediaItem(
            id: 'file_adv_01',
            name: 'Creative Portrait Session.jpg',
            type: 'Portrait Photo',
            size: '3.8 MB',
            url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
            order: 0,
          ),
          UploadedMediaItem(
            id: 'file_adv_02',
            name: 'Main Stage DSLR.jpg',
            type: 'DSLR Photo',
            size: '6.4 MB',
            url: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
            order: 1,
          ),
          UploadedMediaItem(
            id: 'file_adv_03',
            name: 'Hook Intro Sequence.mp4',
            type: 'Video',
            size: '22.1 MB',
            url: 'https://example.com/mock/dance.mp4',
            order: 2,
          ),
          UploadedMediaItem(
            id: 'file_adv_04',
            name: 'Tabla Folk Rhythm Loop.mp3',
            type: 'Instrumental Sound',
            size: '2.5 MB',
            url: 'https://example.com/mock/tabla_loop.mp3',
            order: 3,
          ),
        ],
      ),
    ]);

    logEvent('Firestore initialized: Collection templates prepared.');
    logEvent('Firestore seeded with 4 products, 2 promotions, 2 tracking parcels, 5 vendor settlements, 14 predefined instrument tracks, and advanced upload campaigns.');
  }

  // ------------------------------------
  // FIREBASE AUTHENTICATION SIMULATORS
  // ------------------------------------
  Future<bool> login(String email, String password, String role) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = FirestoreUser(
      uid: 'uid_${Random().nextInt(89999) + 10000}',
      email: email,
      role: role,
      displayName: email.split('@').first.toUpperCase(),
    );
    logEvent('Auth: Logged in as ${_currentUser!.displayName} (${_currentUser!.role})');
    return true;
  }

  Future<bool> loginWithGoogle(String role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = FirestoreUser(
      uid: 'uid_g_${Random().nextInt(89999) + 10000}',
      email: 'creator.google@gmail.com',
      role: role,
      displayName: 'GOOGLE_CREATOR',
    );
    logEvent('Auth: Google Social Sign-In success! Role: ${_currentUser!.role}');
    return true;
  }

  void switchRole(String newRole) {
    if (_currentUser != null) {
      _currentUser = FirestoreUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        role: newRole,
        displayName: _currentUser!.displayName,
      );
      logEvent('Auth: Switched context role to $newRole');
    }
  }

  void logout() {
    final name = _currentUser?.displayName ?? 'User';
    _currentUser = null;
    logEvent('Auth: $name signs out securely.');
  }

  // ------------------------------------
  // FIRESTORE OPERATIONS - REEL SPONSORS
  // ------------------------------------
  void submitPromotionRequest({
    required String influencerHandle,
    required PromoProduct product,
  }) {
    final newId = 'promo_${Random().nextInt(8999) + 1000}';
    final request = ProductPromotion(
      id: newId,
      influencerId: influencerHandle,
      vendorId: 'vend_${product.vendorCode.toLowerCase()}',
      vendorCode: product.vendorCode,
      productId: product.id,
      productName: product.name,
      approvalOtp: '',
      otpVerified: false,
      assignedAt: DateTime.now(),
      status: 'PENDING',
    );
    productPromotions.add(request);
    logEvent('Firestore: CREATE product_promotions/$newId [PENDING]');
  }

  void approvePromotionRequest(String docId) {
    final idx = productPromotions.indexWhere((p) => p.id == docId);
    if (idx != -1) {
      final otp = (Random().nextInt(899999) + 100000).toString();
      productPromotions[idx] = productPromotions[idx].copyWith(
        approvalOtp: otp,
        status: 'APPROVED',
      );
      logEvent('Firestore: UPDATE product_promotions/$docId set otp="$otp" [APPROVED]');
    }
  }

  bool verifyPromotionOtp(String docId, String enteredOtp) {
    final idx = productPromotions.indexWhere((p) => p.id == docId);
    if (idx != -1) {
      final promotion = productPromotions[idx];
      if (promotion.approvalOtp == enteredOtp && !promotion.otpVerified) {
        productPromotions[idx] = promotion.copyWith(
          otpVerified: true,
          status: 'VERIFIED',
        );
        logEvent('Firestore: UPDATE product_promotions/$docId [VERIFIED]');

        // Automatically Formulate Affiliate Code Tracking link in Firestore
        final refCode = 'RG-${promotion.productName.replaceAll(' ', '').toUpperCase().substring(0, 3)}-${Random().nextInt(899) + 100}';
        final trackLink = 'https://reelgen.ai/promote/${promotion.productId}?ref=$refCode';
        
        final affiliate = AffiliateLink(
          id: 'aff_${Random().nextInt(8999) + 1000}',
          influencerId: promotion.influencerId,
          vendorId: promotion.vendorId,
          productId: promotion.productId,
          productName: promotion.productName,
          referralCode: refCode,
          trackingLink: trackLink,
          clicks: 0,
          orders: 0,
          conversions: 0.0,
          businessAmount: 0.0,
        );
        affiliateLinks.add(affiliate);
        logEvent('Firestore: CREATE affiliate_links/${affiliate.id} (Ref: $refCode)');
        return true;
      }
    }
    return false;
  }

  // Simulate Clicks & Growth metrics Live!
  void simulateEngagement(String affiliateId, {required bool isOrder}) {
    final idx = affiliateLinks.indexWhere((a) => a.id == affiliateId);
    if (idx != -1) {
      final aff = affiliateLinks[idx];
      final newClicks = aff.clicks + 1;
      final newOrders = isOrder ? aff.orders + 1 : aff.orders;
      
      final priceMap = {
        'prod_hydrate': 35.0,
        'prod_peaks': 15.0,
        'prod_sonic': 149.0,
        'prod_earbuds': 99.0
      };
      
      final itemPrice = priceMap[aff.productId] ?? 50.0;
      final extraRevenue = isOrder ? itemPrice : 0.0;
      final newBusiness = aff.businessAmount + extraRevenue;
      final newRate = newClicks > 0 ? (newOrders / newClicks) * 100.0 : 0.0;

      affiliateLinks[idx] = aff.copyWith(
        clicks: newClicks,
        orders: newOrders,
        conversions: double.parse(newRate.toStringAsFixed(1)),
        businessAmount: double.parse(newBusiness.toStringAsFixed(2)),
      );

      logEvent('Firestore: UPDATE affiliate_links/${aff.id} metrics: CJK=$newClicks, ORD=$newOrders, Vol=\$$newBusiness');
    }
  }

  // ------------------------------------
  // BRAND STORES PRODUCT CREATIONS
  // ------------------------------------
  void submitOwnProduct({
    required String name,
    required String category,
    required String vendorCode,
    required String payout,
  }) {
    final newId = 'prod_own_${Random().nextInt(8999) + 1000}';
    final product = PromoProduct(
      id: newId,
      name: name,
      category: category,
      vendorCode: vendorCode,
      payoutModel: payout,
    );
    marketplaceProducts.insert(0, product);
    logEvent('Firestore: CREATE marketplace_products/$newId [Own Brand Listing Uploaded]');
  }

  // ------------------------------------
  // PARCEL TRACKING STATE MUTATORS
  // ------------------------------------
  void updateParcelTransit(String id, String newStatus) {
    final idx = parcelTrackings.indexWhere((p) => p.id == id);
    if (idx != -1) {
      parcelTrackings[idx] = parcelTrackings[idx].copyWith(status: newStatus);
      logEvent('Firestore: UPDATE parcel_tracking/$id -> status: $newStatus');
    }
  }

  void customerConfirmParcel(String id, bool received, String proof) {
    final idx = parcelTrackings.indexWhere((p) => p.id == id);
    if (idx != -1) {
      parcelTrackings[idx] = parcelTrackings[idx].copyWith(
        customerConfirmed: received,
        proofImage: proof,
        status: received ? 'DELIVERED' : 'SHIPPED',
      );
      logEvent('Firestore: UPDATE parcel_tracking/$id -> CustomerConfirmed: $received, Proof: $proof');
    }
  }

  // ------------------------------------
  // AI CREATION ACTIONS
  // ------------------------------------
  void generateScriptModel({
    required String productName,
    required String category,
    required String audience,
    required String offer,
    required String language,
    required String style,
  }) {
    final id = 'script_${Random().nextInt(8999) + 1000}';
    
    // Aesthetic translation snippets mimicking Gemini API output
    final sampleScripts = [
      'Hey creators! Check this out...',
      'You will not believe what this can do today...',
      'Tired of poor quality? Say hello to...'
    ];
    final selectedScript = sampleScripts[Random().nextInt(3)];

    final gen = GeneratedScript(
      id: id,
      productName: productName,
      hook: '🔥 GET NOTICED UNBOXING THIS! [$style Style for $audience audience]',
      script: '$selectedScript: The premium ($productName) designed precisely for categories in $category. Incredible offer active: "$offer"!',
      caption: 'Transform your vibes instantly with #$productName! 🔥 Enjoy exclusive benefits now.',
      hashtags: '#reelgen #$category #viralreels #marketing #offer #${language.toLowerCase()}',
      cta: '👉 Click my bio tracking link to secure your orders immediately before stocks sell out out!',
      voiceoverText: '[Excited tone] Introducing the game changer: $productName. Elevate your standard right now with this premium masterpiece.',
    );

    generatedScripts.insert(0, gen);
    logEvent('Firestore: CREATE generated_scripts/$id [Gemini AI Generated]');
  }

  void saveVoiceProfile(String name, String size) {
    final id = 'voice_${Random().nextInt(8999) + 1000}';
    voiceSamples.insert(0, VoiceSample(
      id: id,
      name: name,
      size: size,
      uploadedAt: DateTime.now(),
    ));
    logEvent('FirebaseStorage: UPLOAD voice_samples/$id.wav ($size) [Cloned Voice Saved]');
  }

  void createAvatarProfile(String name, String type, String imgName, String voice) {
    final id = 'avatar_${Random().nextInt(8999) + 1000}';
    avatarProfiles.insert(0, AvatarProfile(
      id: id,
      name: name,
      type: type,
      faceImageName: imgName,
      voiceName: voice,
    ));
    logEvent('Firestore: CREATE avatar_profiles/$id [Talking Avatar Registered]');
  }

  void createPhotoshootStudio(String style, String effect, String music, int count) {
    final id = 'photo_${Random().nextInt(8999) + 1000}';
    photoshootProjects.insert(0, PhotoshootProject(
      id: id,
      style: style,
      effect: effect,
      music: music,
      itemsCount: count,
      createdAt: DateTime.now(),
    ));
    logEvent('Firestore: CREATE photoshoot_projects/$id [Photoshoot Production Generated]');
  }

  void createImageVideo(int imageCount, String overlay, String music) {
    final id = 'imgvid_${Random().nextInt(8999) + 1000}';
    imageVideoProjects.insert(0, ImageVideoProject(
      id: id,
      imageCount: imageCount,
      textOverlay: overlay,
      music: music,
    ));
    logEvent('Firestore: CREATE image_video_projects/$id [Slideshow Visual Created]');
  }

  // ------------------------------------
  // VENDOR SETTLEMENT CYCLE MUTATORS
  // ------------------------------------
  void addSimulatedOrder(String vCode, double amount) {
    final id = 'settle_${Random().nextInt(89999) + 10000}';
    final oId = 'ORD-${Random().nextInt(8999) + 1000}';
    final settlement = VendorSettlement(
      settlementId: id,
      vendorId: vCode == 'VEN56879' ? 'vend_aqua' : 'vend_${vCode.toLowerCase()}',
      vendorCode: vCode,
      orderId: oId,
      orderAmount: amount,
      settlementAmount: double.parse((amount * 0.85).toStringAsFixed(2)), // standard settlement amount: e.g. 85%
      settlementStatus: 'pending',
      orderStatus: 'Placed',
      createdAt: DateTime.now(),
    );
    vendorSettlements.insert(0, settlement);
    logEvent('Firestore: CREATE vendor_settlements/$id [Placed] Order $oId: \$$amount');
    notifyListeners();
  }

  void advanceSettlementFlow(String id) {
    final idx = vendorSettlements.indexWhere((s) => s.settlementId == id);
    if (idx != -1) {
      final s = vendorSettlements[idx];
      String nextOrderStatus = s.orderStatus;
      String nextSettlementStatus = s.settlementStatus;
      DateTime? deliveredAt = s.orderDeliveredAt;
      DateTime? rDate = s.releaseDate;
      DateTime? rAt = s.releasedAt;

      if (s.orderStatus == 'Placed') {
        nextOrderStatus = 'Packed';
      } else if (s.orderStatus == 'Packed') {
        nextOrderStatus = 'Shipped';
      } else if (s.orderStatus == 'Shipped') {
        nextOrderStatus = 'Delivered';
      } else if (s.orderStatus == 'Delivered') {
        nextOrderStatus = 'Return Window Active';
        deliveredAt = DateTime.now();
        rDate = DateTime.now().add(const Duration(days: 15));
      } else if (s.orderStatus == 'Return Window Active') {
        nextOrderStatus = 'Settlement Processing';
        nextSettlementStatus = 'processing';
      } else if (s.orderStatus == 'Settlement Processing') {
        if (s.isHeld) {
          logEvent('Firestore: BIOCKED release on vendor_settlements/$id - Currently Held by Admin! Please clear hold first.');
          return;
        }
        nextOrderStatus = 'Settlement Released';
        nextSettlementStatus = 'released';
        rAt = DateTime.now();
      }

      vendorSettlements[idx] = s.copyWith(
        orderStatus: nextOrderStatus,
        settlementStatus: nextSettlementStatus,
        orderDeliveredAt: deliveredAt,
        releaseDate: rDate,
        releasedAt: rAt,
      );

      logEvent('Firestore: UPDATE vendor_settlements/$id set orderStatus="$nextOrderStatus", settlementStatus="$nextSettlementStatus"');
      notifyListeners();
    }
  }

  void toggleSettlementHold(String id, bool hold, {String? reason}) {
    final idx = vendorSettlements.indexWhere((s) => s.settlementId == id);
    if (idx != -1) {
      final s = vendorSettlements[idx];
      vendorSettlements[idx] = s.copyWith(
        isHeld: hold,
        holdReason: hold ? (reason ?? 'Risk Assessment') : null,
      );
      logEvent('Firestore: UPDATE vendor_settlements/$id set isHeld=$hold [Reason: ${hold ? (reason ?? "Risk Assessment") : "None"}]');
      notifyListeners();
    }
  }

  // ------------------------------------
  // MUSICAL INSTRUMENT SOUND LIBRARY MUTATORS
  // ------------------------------------
  void uploadCustomAudio({
    required String name,
    required String artist,
    required String fileType, // "user_song" or "user_instrumental"
    String duration = '2:15',
  }) {
    final id = 'usr_snd_${Random().nextInt(8999) + 1000}';
    final customSound = SoundTrack(
      id: id,
      name: name,
      category: fileType == 'user_song' ? 'Uploaded Songs' : 'Uploaded Instrumentals',
      artist: artist.isNotEmpty ? artist : 'Self-uploaded Creator',
      audioUrl: 'https://example.com/audio_uploads/custom_$id.mp3',
      fileType: fileType,
      createdAt: DateTime.now(),
      duration: duration,
    );
    soundLibrary.insert(0, customSound);
    logEvent('Firestore: CREATE sound_library/$id - [Uploaded ${fileType == "user_song" ? "Music/Song" : "Instrumental Audio"}] "$name" by $artist');
    notifyListeners();
  }

  void selectSoundForReel(String soundId) {
    selectedReelSoundId = soundId;
    final idx = soundLibrary.indexWhere((s) => s.id == soundId);
    final name = idx != -1 ? soundLibrary[idx].name : 'Unknown';
    logEvent('AppState: SELECT sound_library/$soundId ("$name") selected as the active Reel background audio track.');
    notifyListeners();
  }

  // ------------------------------------
  // ADVANCED UPLOAD SYSTEM MUTATORS (FIRESTORE)
  // ------------------------------------
  void saveAdvancedUploadProject({
    required String title,
    required List<UploadedMediaItem> files,
    required bool disclaimerConfirmed,
  }) {
    final id = 'proj_adv_${Random().nextInt(89999) + 10000}';
    final newProj = AdvancedUploadProject(
      id: id,
      title: title.isNotEmpty ? title : 'Untitled Upload Project',
      files: List.from(files),
      disclaimerConfirmed: disclaimerConfirmed,
      createdAt: DateTime.now(),
    );
    advancedUploadProjects.insert(0, newProj);
    logEvent('Firestore: CREATE advanced_uploads/$id - Campaign "${newProj.title}" containing ${files.length} custom assets.');
    notifyListeners();
  }

  void deleteAdvancedUploadProject(String id) {
    final idx = advancedUploadProjects.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final title = advancedUploadProjects[idx].title;
      advancedUploadProjects.removeAt(idx);
      logEvent('Firestore: DELETE advanced_uploads/$id - Campaign "$title" and its associated assets removed from pool.');
      notifyListeners();
    }
  }
}

