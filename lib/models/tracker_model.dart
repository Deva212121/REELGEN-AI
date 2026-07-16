import 'package:cloud_firestore/cloud_firestore.dart';

/// Overall status of the automatic tracker.
enum TrackerStatus {
  idle,
  running,
  success,
  error,
}

/// Sync status for order-related data.
enum OrderSyncStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// Sync status for stock-related data.
enum StockSyncStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// Type of sync trigger.
enum SyncType {
  automatic,
  manual,
}

/// Model holding the state of the live stock + order tracker.
/// Stored in Firestore (e.g., `system/trackerState`).
class OrderStockTracker {
  // Timing
  final DateTime? lastCheckedAt;
  final DateTime? nextCheckAt;
  final int trackingIntervalMinutes; // default 25

  // Status
  final TrackerStatus trackingStatus;
  final OrderSyncStatus orderSyncStatus;
  final StockSyncStatus stockSyncStatus;
  final String? errorMessage;

  // Manual Sync
  final SyncType syncType;
  final DateTime? manualSyncTriggeredAt;
  final DateTime? manualSyncCompletedAt;
  final int syncAttemptCount;

  // Live Metrics
  final int currentActiveOrders;
  final int currentReservedStock;
  final int currentAvailableStock;
  final int currentSoldStock;

  // Performance
  final double? averageSyncTime;
  final DateTime? lastSuccessfulSync;
  final DateTime? lastFailedSync;

  // Alerts
  final bool lowStockAlert;
  final bool outOfStockAlert;
  final bool syncFailureAlert;

  // Admin
  final String? triggeredByUserId;
  final String? triggeredByRole;
  final String? deviceType;

  // Future AI
  final String? aiPredictionStatus;
  final String? demandForecastStatus;

  // Aggregated Metrics from last cycle
  final int newOrdersCount;
  final int pendingPaymentsCount;
  final int cancelledReturnedOrdersCount;
  final int influencerSalesCount;
  final Map<String, int> commissionStatusSummary;
  final double totalVendorPayable;
  final double totalPlatformProfit;
  final List<String> lowStockProductIds;

  // Admin Panel Sync
  final bool adminPanelUpdated;

  // Audit
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderStockTracker({
    this.lastCheckedAt,
    this.nextCheckAt,
    this.trackingIntervalMinutes = 25,
    this.trackingStatus = TrackerStatus.idle,
    this.orderSyncStatus = OrderSyncStatus.pending,
    this.stockSyncStatus = StockSyncStatus.pending,
    this.errorMessage,
    this.syncType = SyncType.automatic,
    this.manualSyncTriggeredAt,
    this.manualSyncCompletedAt,
    this.syncAttemptCount = 0,
    this.currentActiveOrders = 0,
    this.currentReservedStock = 0,
    this.currentAvailableStock = 0,
    this.currentSoldStock = 0,
    this.averageSyncTime,
    this.lastSuccessfulSync,
    this.lastFailedSync,
    this.lowStockAlert = false,
    this.outOfStockAlert = false,
    this.syncFailureAlert = false,
    this.triggeredByUserId,
    this.triggeredByRole,
    this.deviceType,
    this.aiPredictionStatus,
    this.demandForecastStatus,
    this.newOrdersCount = 0,
    this.pendingPaymentsCount = 0,
    this.cancelledReturnedOrdersCount = 0,
    this.influencerSalesCount = 0,
    this.commissionStatusSummary = const {},
    this.totalVendorPayable = 0.0,
    this.totalPlatformProfit = 0.0,
    this.lowStockProductIds = const [],
    this.adminPanelUpdated = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderStockTracker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderStockTracker(
      lastCheckedAt: (data['lastCheckedAt'] as Timestamp?)?.toDate(),
      nextCheckAt: (data['nextCheckAt'] as Timestamp?)?.toDate(),
      trackingIntervalMinutes: data['trackingIntervalMinutes'] ?? 25,
      trackingStatus: _parseTrackerStatus(data['trackingStatus'] ?? 'idle'),
      orderSyncStatus: _parseOrderSyncStatus(data['orderSyncStatus'] ?? 'pending'),
      stockSyncStatus: _parseStockSyncStatus(data['stockSyncStatus'] ?? 'pending'),
      errorMessage: data['errorMessage'],
      syncType: _parseSyncType(data['syncType'] ?? 'automatic'),
      manualSyncTriggeredAt: (data['manualSyncTriggeredAt'] as Timestamp?)?.toDate(),
      manualSyncCompletedAt: (data['manualSyncCompletedAt'] as Timestamp?)?.toDate(),
      syncAttemptCount: data['syncAttemptCount'] ?? 0,
      currentActiveOrders: data['currentActiveOrders'] ?? 0,
      currentReservedStock: data['currentReservedStock'] ?? 0,
      currentAvailableStock: data['currentAvailableStock'] ?? 0,
      currentSoldStock: data['currentSoldStock'] ?? 0,
      averageSyncTime: (data['averageSyncTime'] as num?)?.toDouble(),
      lastSuccessfulSync: (data['lastSuccessfulSync'] as Timestamp?)?.toDate(),
      lastFailedSync: (data['lastFailedSync'] as Timestamp?)?.toDate(),
      lowStockAlert: data['lowStockAlert'] ?? false,
      outOfStockAlert: data['outOfStockAlert'] ?? false,
      syncFailureAlert: data['syncFailureAlert'] ?? false,
      triggeredByUserId: data['triggeredByUserId'],
      triggeredByRole: data['triggeredByRole'],
      deviceType: data['deviceType'],
      aiPredictionStatus: data['aiPredictionStatus'],
      demandForecastStatus: data['demandForecastStatus'],
      newOrdersCount: data['newOrdersCount'] ?? 0,
      pendingPaymentsCount: data['pendingPaymentsCount'] ?? 0,
      cancelledReturnedOrdersCount: data['cancelledReturnedOrdersCount'] ?? 0,
      influencerSalesCount: data['influencerSalesCount'] ?? 0,
      commissionStatusSummary: Map<String, int>.from(data['commissionStatusSummary'] ?? {}),
      totalVendorPayable: (data['totalVendorPayable'] ?? 0).toDouble(),
      totalPlatformProfit: (data['totalPlatformProfit'] ?? 0).toDouble(),
      lowStockProductIds: List<String>.from(data['lowStockProductIds'] ?? []),
      adminPanelUpdated: data['adminPanelUpdated'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lastCheckedAt': lastCheckedAt != null ? Timestamp.fromDate(lastCheckedAt!) : null,
      'nextCheckAt': nextCheckAt != null ? Timestamp.fromDate(nextCheckAt!) : null,
      'trackingIntervalMinutes': trackingIntervalMinutes,
      'trackingStatus': trackingStatus.name,
      'orderSyncStatus': orderSyncStatus.name,
      'stockSyncStatus': stockSyncStatus.name,
      'errorMessage': errorMessage,
      'syncType': syncType.name,
      'manualSyncTriggeredAt': manualSyncTriggeredAt != null ? Timestamp.fromDate(manualSyncTriggeredAt!) : null,
      'manualSyncCompletedAt': manualSyncCompletedAt != null ? Timestamp.fromDate(manualSyncCompletedAt!) : null,
      'syncAttemptCount': syncAttemptCount,
      'currentActiveOrders': currentActiveOrders,
      'currentReservedStock': currentReservedStock,
      'currentAvailableStock': currentAvailableStock,
      'currentSoldStock': currentSoldStock,
      'averageSyncTime': averageSyncTime,
      'lastSuccessfulSync': lastSuccessfulSync != null ? Timestamp.fromDate(lastSuccessfulSync!) : null,
      'lastFailedSync': lastFailedSync != null ? Timestamp.fromDate(lastFailedSync!) : null,
      'lowStockAlert': lowStockAlert,
      'outOfStockAlert': outOfStockAlert,
      'syncFailureAlert': syncFailureAlert,
      'triggeredByUserId': triggeredByUserId,
      'triggeredByRole': triggeredByRole,
      'deviceType': deviceType,
      'aiPredictionStatus': aiPredictionStatus,
      'demandForecastStatus': demandForecastStatus,
      'newOrdersCount': newOrdersCount,
      'pendingPaymentsCount': pendingPaymentsCount,
      'cancelledReturnedOrdersCount': cancelledReturnedOrdersCount,
      'influencerSalesCount': influencerSalesCount,
      'commissionStatusSummary': commissionStatusSummary,
      'totalVendorPayable': totalVendorPayable,
      'totalPlatformProfit': totalPlatformProfit,
      'lowStockProductIds': lowStockProductIds,
      'adminPanelUpdated': adminPanelUpdated,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderStockTracker copyWith({
    DateTime? lastCheckedAt,
    DateTime? nextCheckAt,
    int? trackingIntervalMinutes,
    TrackerStatus? trackingStatus,
    OrderSyncStatus? orderSyncStatus,
    StockSyncStatus? stockSyncStatus,
    String? errorMessage,
    SyncType? syncType,
    DateTime? manualSyncTriggeredAt,
    DateTime? manualSyncCompletedAt,
    int? syncAttemptCount,
    int? currentActiveOrders,
    int? currentReservedStock,
    int? currentAvailableStock,
    int? currentSoldStock,
    double? averageSyncTime,
    DateTime? lastSuccessfulSync,
    DateTime? lastFailedSync,
    bool? lowStockAlert,
    bool? outOfStockAlert,
    bool? syncFailureAlert,
    String? triggeredByUserId,
    String? triggeredByRole,
    String? deviceType,
    String? aiPredictionStatus,
    String? demandForecastStatus,
    int? newOrdersCount,
    int? pendingPaymentsCount,
    int? cancelledReturnedOrdersCount,
    int? influencerSalesCount,
    Map<String, int>? commissionStatusSummary,
    double? totalVendorPayable,
    double? totalPlatformProfit,
    List<String>? lowStockProductIds,
    bool? adminPanelUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderStockTracker(
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      nextCheckAt: nextCheckAt ?? this.nextCheckAt,
      trackingIntervalMinutes: trackingIntervalMinutes ?? this.trackingIntervalMinutes,
      trackingStatus: trackingStatus ?? this.trackingStatus,
      orderSyncStatus: orderSyncStatus ?? this.orderSyncStatus,
      stockSyncStatus: stockSyncStatus ?? this.stockSyncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      syncType: syncType ?? this.syncType,
      manualSyncTriggeredAt: manualSyncTriggeredAt ?? this.manualSyncTriggeredAt,
      manualSyncCompletedAt: manualSyncCompletedAt ?? this.manualSyncCompletedAt,
      syncAttemptCount: syncAttemptCount ?? this.syncAttemptCount,
      currentActiveOrders: currentActiveOrders ?? this.currentActiveOrders,
      currentReservedStock: currentReservedStock ?? this.currentReservedStock,
      currentAvailableStock: currentAvailableStock ?? this.currentAvailableStock,
      currentSoldStock: currentSoldStock ?? this.currentSoldStock,
      averageSyncTime: averageSyncTime ?? this.averageSyncTime,
      lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
      lastFailedSync: lastFailedSync ?? this.lastFailedSync,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      outOfStockAlert: outOfStockAlert ?? this.outOfStockAlert,
      syncFailureAlert: syncFailureAlert ?? this.syncFailureAlert,
      triggeredByUserId: triggeredByUserId ?? this.triggeredByUserId,
      triggeredByRole: triggeredByRole ?? this.triggeredByRole,
      deviceType: deviceType ?? this.deviceType,
      aiPredictionStatus: aiPredictionStatus ?? this.aiPredictionStatus,
      demandForecastStatus: demandForecastStatus ?? this.demandForecastStatus,
      newOrdersCount: newOrdersCount ?? this.newOrdersCount,
      pendingPaymentsCount: pendingPaymentsCount ?? this.pendingPaymentsCount,
      cancelledReturnedOrdersCount: cancelledReturnedOrdersCount ?? this.cancelledReturnedOrdersCount,
      influencerSalesCount: influencerSalesCount ?? this.influencerSalesCount,
      commissionStatusSummary: commissionStatusSummary ?? this.commissionStatusSummary,
      totalVendorPayable: totalVendorPayable ?? this.totalVendorPayable,
      totalPlatformProfit: totalPlatformProfit ?? this.totalPlatformProfit,
      lowStockProductIds: lowStockProductIds ?? this.lowStockProductIds,
      adminPanelUpdated: adminPanelUpdated ?? this.adminPanelUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper parsers
  static TrackerStatus _parseTrackerStatus(String value) {
    return TrackerStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TrackerStatus.idle,
    );
  }

  static OrderSyncStatus _parseOrderSyncStatus(String value) {
    return OrderSyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderSyncStatus.pending,
    );
  }

  static StockSyncStatus _parseStockSyncStatus(String value) {
    return StockSyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StockSyncStatus.pending,
    );
  }

  static SyncType _parseSyncType(String value) {
    return SyncType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncType.automatic,
    );
  }
}