import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html; // For web URL detection
import '../../models/order_model.dart' as order_models;
import '../../models/product_model.dart';
import '../../services/order_service.dart';
import '../../services/whatsapp_verification_service.dart';
import '../../services/referral_service.dart';
import '../../services/firebase_service.dart';

class CustomerOrderScreen extends StatefulWidget {
  final String productId;
  const CustomerOrderScreen({super.key, required this.productId});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  Product? _product;
  bool _isLoading = true;
  bool _isProcessing = false;
  String _influencerId = '';
  String _referralLink = '';

  final OrderService _orderService = OrderService();
  final WhatsAppVerificationService _whatsappService = WhatsAppVerificationService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _detectReferral();
  }

  void _detectReferral() {
    try {
      final url = html.window.location.href;
      _influencerId = ReferralService.extractInfluencerId(url);
      _referralLink = url;
      if (_influencerId.isNotEmpty) {
        debugPrint('Referral detected: $_influencerId');
      }
    } catch (e) {
      debugPrint('Referral detection failed: $e');
    }
  }

  Future<void> _loadProduct() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (doc.exists) {
        setState(() {
          _product = Product.fromFirestore(doc);
          _isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: 'Product not found');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error loading product: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final pincode = _pincodeController.text.trim();

    if (name.isEmpty || mobile.isEmpty || address.isEmpty || pincode.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all required fields');
      return;
    }
    if (mobile.length < 10) {
      Fluttertoast.showToast(msg: 'Enter valid mobile number');
      return;
    }
    if (_product == null) return;

    setState(() => _isProcessing = true);

    try {
      // Save referral click if influencer ID exists
      if (_influencerId.isNotEmpty) {
        await _firebaseService.saveReferralClick(
          influencerId: _influencerId,
          productId: _product!.id,
          customerId: mobile, // Using mobile as temporary customer ID
        );
      }

      final orderItem = order_models.OrderItem(
        productId: _product!.id,
        productName: _product!.name,
        designNumber: _product!.designNumber,
        productCode: _product!.productCode,
        sku: _product!.sku,
        quantity: 1,
        unitPrice: _product!.price,
        gstRate: _product!.gstRate,
        hsnCode: _product!.gstHsnCode,
        commissionEarned: 0,
      );

      final order = order_models.Order(
        orderId: '',
        orderNumber: '',
        invoiceNumber: null,
        customerId: '',
        customerName: name,
        mobile: mobile,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        landmark: null,
        vendorId: _product!.vendorId,
        vendorName: '',
        influencerId: _influencerId, // Referral influencer ID
        influencerName: '',
        referralCode: _influencerId,
        items: [orderItem],
        stockReduced: false,
        orderAmount: _product!.price,
        vendorPayable: 0,
        influencerCommission: 0,
        platformProfit: 0,
        paymentGateway: 'whatsapp',
        paymentStatus: order_models.PaymentStatus.pending,
        paymentId: null,
        transactionId: null,
        courierName: null,
        trackingNumber: null,
        status: order_models.OrderStatus.awaitingVerification,
        createdAt: DateTime.now(),
        updatedAt: null,
        verifiedAt: null,
        packedAt: null,
        shippedAt: null,
        deliveredAt: null,
        returnedAt: null,
        cancelledAt: null,
        refundedAt: null,
        platform: 'reelgen',
        verificationStatus: order_models.VerificationStatus.pending,
        confirmationCode: null,
        whatsappMessageSentAt: null,
        verifiedAtOtp: null,
        commissionStatus: order_models.CommissionStatus.pending,
        payoutStatus: order_models.CommissionStatus.pending,
        createdBy: 'customer',
        totalCommission: 0,
        totalGst: 0,
        platformFee: 0,
        vendorPayableSnapshot: 0,
        paymentReleaseDate: null,
        paymentReleaseStatus: 'pending',
        returnReason: null,
        returnStatus: null,
        returnRequestedAt: null,
        returnApprovedAt: null,
        refundAmount: null,
        isDeleted: false,
        deletedAt: null,
        deletedBy: null,
      );

      final (orderId, confirmationCode) = await _orderService.createOrder(order);
      final (deepLink, _) = await _orderService.getVerificationLink(orderId);
      await _orderService.markVerificationSent(orderId);

      if (await canLaunchUrl(Uri.parse(deepLink))) {
        await launchUrl(Uri.parse(deepLink), mode: LaunchMode.externalApplication);
        Fluttertoast.showToast(msg: 'Order created! Please confirm on WhatsApp.');
      } else {
        Fluttertoast.showToast(msg: 'Unable to open WhatsApp. Please check your device.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_product == null) {
      return const Scaffold(
        body: Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_influencerId.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✅ Referral tracked! You are ordering through an influencer.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory_2, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _product!.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Design: ${_product!.designNumber}'),
                          const SizedBox(height: 4),
                          Text(
                            '₹${_product!.price}',
                            style: const TextStyle(color: Color(0xFFC4FF62), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                labelText: 'Pincode *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _placeOrder,
              icon: const Icon(Icons.chat),
              label: Text(
                _isProcessing ? 'Processing...' : 'Confirm Order via WhatsApp',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}