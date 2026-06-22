// Firestore Models for ReelGen AI Platform

class FirestoreUser {
  final String uid;
  final String email;
  final String role; // "INFLUENCER", "VENDOR", "ADMIN"
  final String? displayName;

  FirestoreUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'role': role,
    'displayName': displayName,
  };
}

class PromoProduct {
  final String id;
  final String name;
  final String category;
  final String vendorCode;
  final String payoutModel;

  PromoProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.vendorCode,
    required this.payoutModel,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'vendorCode': vendorCode,
    'payoutModel': payoutModel,
  };
}

class ProductPromotion {
  final String id;
  final String influencerId;
  final String vendorId;
  final String vendorCode;
  final String productId;
  final String productName;
  final String approvalOtp;
  final bool otpVerified;
  final DateTime assignedAt;
  final String status; // "PENDING", "APPROVED", "VERIFIED"

  ProductPromotion({
    required this.id,
    required this.influencerId,
    required this.vendorId,
    required this.vendorCode,
    required this.productId,
    required this.productName,
    required this.approvalOtp,
    required this.otpVerified,
    required this.assignedAt,
    required this.status,
  });

  ProductPromotion copyWith({
    String? approvalOtp,
    bool? otpVerified,
    String? status,
    DateTime? assignedAt,
  }) {
    return ProductPromotion(
      id: id,
      influencerId: influencerId,
      vendorId: vendorId,
      vendorCode: vendorCode,
      productId: productId,
      productName: productName,
      approvalOtp: approvalOtp ?? this.approvalOtp,
      otpVerified: otpVerified ?? this.otpVerified,
      assignedAt: assignedAt ?? this.assignedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'influencerId': influencerId,
    'vendorId': vendorId,
    'vendorCode': vendorCode,
    'productId': productId,
    'productName': productName,
    'approvalOtp': approvalOtp,
    'otpVerified': otpVerified,
    'assignedAt': assignedAt.toIso8601String(),
    'status': status,
  };
}

class AffiliateLink {
  final String id;
  final String influencerId;
  final String vendorId;
  final String productId;
  final String productName;
  final String referralCode;
  final String trackingLink;
  final int clicks;
  final int orders;
  final double conversions; // Rate %
  final double businessAmount;

  AffiliateLink({
    required this.id,
    required this.influencerId,
    required this.vendorId,
    required this.productId,
    required this.productName,
    required this.referralCode,
    required this.trackingLink,
    required this.clicks,
    required this.orders,
    required this.conversions,
    required this.businessAmount,
  });

  AffiliateLink copyWith({
    int? clicks,
    int? orders,
    double? conversions,
    double? businessAmount,
  }) {
    return AffiliateLink(
      id: id,
      influencerId: influencerId,
      vendorId: vendorId,
      productId: productId,
      productName: productName,
      referralCode: referralCode,
      trackingLink: trackingLink,
      clicks: clicks ?? this.clicks,
      orders: orders ?? this.orders,
      conversions: conversions ?? this.conversions,
      businessAmount: businessAmount ?? this.businessAmount,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'influencerId': influencerId,
    'vendorId': vendorId,
    'productId': productId,
    'productName': productName,
    'referralCode': referralCode,
    'trackingLink': trackingLink,
    'clicks': clicks,
    'orders': orders,
    'conversions': conversions,
    'businessAmount': businessAmount,
  };
}

class GeneratedScript {
  final String id;
  final String productName;
  final String hook;
  final String script;
  final String caption;
  final String hashtags;
  final String cta;
  final String voiceoverText;

  GeneratedScript({
    required this.id,
    required this.productName,
    required this.hook,
    required this.script,
    required this.caption,
    required this.hashtags,
    required this.cta,
    required this.voiceoverText,
  });
}

class VoiceSample {
  final String id;
  final String name;
  final String size;
  final DateTime uploadedAt;

  VoiceSample({
    required this.id,
    required this.name,
    required this.size,
    required this.uploadedAt,
  });
}

class AvatarProfile {
  final String id;
  final String name;
  final String type; // "Talking", "Sales", "Teacher"
  final String faceImageName;
  final String voiceName;
  final double progress;

  AvatarProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.faceImageName,
    required this.voiceName,
    this.progress = 1.0,
  });
}

class PhotoshootProject {
  final String id;
  final String style; // "Wedding", "Birthday", "Product", etc.
  final String effect; // "Cinematic", "DSLR Look", etc.
  final String music;
  final int itemsCount;
  final DateTime createdAt;

  PhotoshootProject({
    required this.id,
    required this.style,
    required this.effect,
    required this.music,
    required this.itemsCount,
    required this.createdAt,
  });
}

class ImageVideoProject {
  final String id;
  final int imageCount;
  final String textOverlay;
  final String music;

  ImageVideoProject({
    required this.id,
    required this.imageCount,
    required this.textOverlay,
    required this.music,
  });
}

class ParcelTracking {
  final String id;
  final String productName;
  final String influencerId;
  final String status; // "PLACED", "PACKED", "SHIPPED", "TRANSIT", "DELIVERY", "DELIVERED"
  final bool? customerConfirmed; // true=received, false=not received, null=pending
  final String proofImage;

  ParcelTracking({
    required this.id,
    required this.productName,
    required this.influencerId,
    required this.status,
    this.customerConfirmed,
    this.proofImage = "",
  });

  ParcelTracking copyWith({
    String? status,
    bool? customerConfirmed,
    String? proofImage,
  }) {
    return ParcelTracking(
      id: id,
      productName: productName,
      influencerId: influencerId,
      status: status ?? this.status,
      customerConfirmed: customerConfirmed ?? this.customerConfirmed,
      proofImage: proofImage ?? this.proofImage,
    );
  }
}

class VendorSettlement {
  final String settlementId;
  final String vendorId;
  final String vendorCode;
  final String orderId;
  final double orderAmount;
  final double settlementAmount;
  final String settlementStatus; // "pending", "processing", "released"
  final DateTime? orderDeliveredAt;
  final DateTime? releaseDate;
  final DateTime? releasedAt;
  final DateTime createdAt;
  final String orderStatus; // "Placed", "Packed", "Shipped", "Delivered", "Return Window Active", "Settlement Processing", "Settlement Released"
  final bool isHeld;
  final String? holdReason;

  VendorSettlement({
    required this.settlementId,
    required this.vendorId,
    required this.vendorCode,
    required this.orderId,
    required this.orderAmount,
    required this.settlementAmount,
    required this.settlementStatus,
    this.orderDeliveredAt,
    this.releaseDate,
    this.releasedAt,
    required this.createdAt,
    required this.orderStatus,
    this.isHeld = false,
    this.holdReason,
  });

  VendorSettlement copyWith({
    String? settlementStatus,
    DateTime? orderDeliveredAt,
    DateTime? releaseDate,
    DateTime? releasedAt,
    String? orderStatus,
    bool? isHeld,
    String? holdReason,
  }) {
    return VendorSettlement(
      settlementId: settlementId,
      vendorId: vendorId,
      vendorCode: vendorCode,
      orderId: orderId,
      orderAmount: orderAmount,
      settlementAmount: settlementAmount,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      orderDeliveredAt: orderDeliveredAt ?? this.orderDeliveredAt,
      releaseDate: releaseDate ?? this.releaseDate,
      releasedAt: releasedAt ?? this.releasedAt,
      createdAt: createdAt,
      orderStatus: orderStatus ?? this.orderStatus,
      isHeld: isHeld ?? this.isHeld,
      holdReason: holdReason ?? this.holdReason,
    );
  }

  Map<String, dynamic> toMap() => {
    'settlementId': settlementId,
    'vendorId': vendorId,
    'vendorCode': vendorCode,
    'orderId': orderId,
    'orderAmount': orderAmount,
    'settlementAmount': settlementAmount,
    'settlementStatus': settlementStatus,
    'orderDeliveredAt': orderDeliveredAt?.toIso8601String(),
    'releaseDate': releaseDate?.toIso8601String(),
    'releasedAt': releasedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'orderStatus': orderStatus,
    'isHeld': isHeld,
    'holdReason': holdReason,
  };
}

class SoundTrack {
  final String id;
  final String name;
  final String category;
  final String artist;
  final String audioUrl;
  final String fileType; // "predefined", "user_song", "user_instrumental"
  final DateTime createdAt;
  final String duration;

  SoundTrack({
    required this.id,
    required this.name,
    required this.category,
    required this.artist,
    required this.audioUrl,
    required this.fileType,
    required this.createdAt,
    required this.duration,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'artist': artist,
    'audioUrl': audioUrl,
    'fileType': fileType,
    'createdAt': createdAt.toIso8601String(),
    'duration': duration,
  };
}

class UploadedMediaItem {
  final String id;
  final String name;
  final String type; // "Photo", "DSLR Photo", "Portrait Photo", "Video", "Music", "Song", "Voiceover", "Instrumental Sound"
  final String size;
  final String url; // placeholder URL or background asset
  final int order;

  UploadedMediaItem({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
    required this.order,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'size': size,
    'url': url,
    'order': order,
  };
}

class AdvancedUploadProject {
  final String id;
  final String title;
  final List<UploadedMediaItem> files;
  final bool disclaimerConfirmed;
  final DateTime createdAt;

  AdvancedUploadProject({
    required this.id,
    required this.title,
    required this.files,
    required this.disclaimerConfirmed,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'files': files.map((f) => f.toMap()).toList(),
    'disclaimerConfirmed': disclaimerConfirmed,
    'createdAt': createdAt.toIso8601String(),
  };
}


