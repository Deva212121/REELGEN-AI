import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of action performed.
enum ActionType {
  // Auth
  login,
  logout,

  // Product
  productCreated,
  productUpdated,
  productDeleted,

  // Stock
  stockAdded,
  stockReduced,

  // Order
  orderCreated,
  orderUpdated,
  orderCancelled,

  // Payment
  paymentSuccess,
  paymentFailed,
  refund,

  // Commission & Settlement
  commissionPaid,
  vendorSettlement,

  // Invoice
  invoiceGenerated,

  // Sync
  manualSync,
  autoSync,

  // Admin
  adminSettingsChanged,
}

/// Module where the action occurred.
enum Module {
  auth,
  product,
  stock,
  order,
  payment,
  commission,
  settlement,
  invoice,
  sync,
  admin,
}

/// Priority level for the audit log entry.
enum PriorityLevel {
  high,
  medium,
  low,
}

/// Model representing a single audit log entry.
/// Stored in Firestore under `audit_logs` collection.
class AuditLog {
  final String id;                      // Document ID (auto-generated)

  // ---------- User ----------
  final String userId;
  final String userName;
  final String userRole;                // e.g., 'influencer', 'vendor', 'admin'

  // ---------- Action ----------
  final ActionType actionType;
  final Module module;
  final Map<String, dynamic>? beforeValue; // Snapshot of data before change
  final Map<String, dynamic>? afterValue;  // Snapshot of data after change

  // ---------- Timestamp ----------
  final DateTime timestamp;

  // ---------- Device & App ----------
  final String? deviceType;             // e.g., 'web', 'mobile', 'api'
  final String? ipAddress;              // Optional for future use
  final String? appVersion;             // App version string

  // ---------- Security ----------
  final String? sessionId;              // User session identifier
  final String? requestId;              // Unique request ID for tracing

  // ---------- Business References ----------
  final String? orderId;
  final String? productId;
  final String? influencerId;
  final String? vendorId;
  final String? adminId;
  final String? invoiceId;              // Reference to invoice
  final String? paymentId;              // Reference to payment transaction
  final String? trackingId;             // Shipping/tracking reference

  // ---------- System Status ----------
  final bool success;                   // Whether the action succeeded
  final String? errorCode;              // Error code if failure
  final String? errorMessage;           // Error description if failure

  // ---------- Geo (future) ----------
  final String? country;
  final String? state;
  final String? city;

  // ---------- Priority ----------
  final PriorityLevel priority;

  // ---------- Retention ----------
  final String? archiveStatus;          // e.g., 'active', 'archived', 'deleted'

  // ---------- Remarks ----------
  final String? remarks;                // Additional context

  AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.actionType,
    required this.module,
    this.beforeValue,
    this.afterValue,
    required this.timestamp,
    this.deviceType,
    this.ipAddress,
    this.appVersion,
    this.sessionId,
    this.requestId,
    this.orderId,
    this.productId,
    this.influencerId,
    this.vendorId,
    this.adminId,
    this.invoiceId,
    this.paymentId,
    this.trackingId,
    this.success = true,
    this.errorCode,
    this.errorMessage,
    this.country,
    this.state,
    this.city,
    this.priority = PriorityLevel.medium,
    this.archiveStatus,
    this.remarks,
  });

  /// Creates an AuditLog from a Firestore document snapshot.
  factory AuditLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userRole: data['userRole'] ?? '',
      actionType: _parseActionType(data['actionType'] ?? 'login'),
      module: _parseModule(data['module'] ?? 'auth'),
      beforeValue: data['beforeValue'] as Map<String, dynamic>?,
      afterValue: data['afterValue'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deviceType: data['deviceType'],
      ipAddress: data['ipAddress'],
      appVersion: data['appVersion'],
      sessionId: data['sessionId'],
      requestId: data['requestId'],
      orderId: data['orderId'],
      productId: data['productId'],
      influencerId: data['influencerId'],
      vendorId: data['vendorId'],
      adminId: data['adminId'],
      invoiceId: data['invoiceId'],
      paymentId: data['paymentId'],
      trackingId: data['trackingId'],
      success: data['success'] ?? true,
      errorCode: data['errorCode'],
      errorMessage: data['errorMessage'],
      country: data['country'],
      state: data['state'],
      city: data['city'],
      priority: _parsePriority(data['priority'] ?? 'medium'),
      archiveStatus: data['archiveStatus'],
      remarks: data['remarks'],
    );
  }

  /// Converts this AuditLog to a Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'actionType': actionType.name,
      'module': module.name,
      'beforeValue': beforeValue,
      'afterValue': afterValue,
      'timestamp': Timestamp.fromDate(timestamp),
      'deviceType': deviceType,
      'ipAddress': ipAddress,
      'appVersion': appVersion,
      'sessionId': sessionId,
      'requestId': requestId,
      'orderId': orderId,
      'productId': productId,
      'influencerId': influencerId,
      'vendorId': vendorId,
      'adminId': adminId,
      'invoiceId': invoiceId,
      'paymentId': paymentId,
      'trackingId': trackingId,
      'success': success,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'country': country,
      'state': state,
      'city': city,
      'priority': priority.name,
      'archiveStatus': archiveStatus,
      'remarks': remarks,
    };
  }

  /// Creates a copy with optional overrides.
  AuditLog copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    ActionType? actionType,
    Module? module,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
    DateTime? timestamp,
    String? deviceType,
    String? ipAddress,
    String? appVersion,
    String? sessionId,
    String? requestId,
    String? orderId,
    String? productId,
    String? influencerId,
    String? vendorId,
    String? adminId,
    String? invoiceId,
    String? paymentId,
    String? trackingId,
    bool? success,
    String? errorCode,
    String? errorMessage,
    String? country,
    String? state,
    String? city,
    PriorityLevel? priority,
    String? archiveStatus,
    String? remarks,
  }) {
    return AuditLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      actionType: actionType ?? this.actionType,
      module: module ?? this.module,
      beforeValue: beforeValue ?? this.beforeValue,
      afterValue: afterValue ?? this.afterValue,
      timestamp: timestamp ?? this.timestamp,
      deviceType: deviceType ?? this.deviceType,
      ipAddress: ipAddress ?? this.ipAddress,
      appVersion: appVersion ?? this.appVersion,
      sessionId: sessionId ?? this.sessionId,
      requestId: requestId ?? this.requestId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      influencerId: influencerId ?? this.influencerId,
      vendorId: vendorId ?? this.vendorId,
      adminId: adminId ?? this.adminId,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentId: paymentId ?? this.paymentId,
      trackingId: trackingId ?? this.trackingId,
      success: success ?? this.success,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      priority: priority ?? this.priority,
      archiveStatus: archiveStatus ?? this.archiveStatus,
      remarks: remarks ?? this.remarks,
    );
  }

  // ---------- Helper parsers ----------
  static ActionType _parseActionType(String value) {
    return ActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionType.login,
    );
  }

  static Module _parseModule(String value) {
    return Module.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Module.auth,
    );
  }

  static PriorityLevel _parsePriority(String value) {
    return PriorityLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PriorityLevel.medium,
    );
  }
}