import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order_model.dart' as order_models;
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../../services/order_service.dart';
import '../../services/whatsapp_verification_service.dart';
import '../../services/razorpay_service.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  List<Product> _availableProducts = [];
  Set<String> _selectedProductIds = {};
  bool _isLoading = false;
  bool _isProcessing = false;

  late RazorpayService _razorpayService;

  final FirebaseService _firebaseService = FirebaseService();
  final OrderService _orderService = OrderService();
  final WhatsAppVerificationService _whatsappService = WhatsAppVerificationService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _razorpayService = RazorpayService();
    _razorpayService.onSuccess = _onPaymentSuccess;
    _razorpayService.onFailure = _onPaymentFailure;
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _customerNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();
      final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      setState(() {
        _availableProducts = products;
        if (products.isNotEmpty && _selectedProductIds.isEmpty) {
          _selectedProductIds.add(products.first.id);
        }
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load products: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleProduct(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  List<Product> get _selectedProducts =>
      _availableProducts.where((p) => _selectedProductIds.contains(p.id)).toList();

  double get _totalAmount => _selectedProducts.fold(0.0, (sum, p) => sum + p.price);

  void _onPaymentSuccess() {
    Fluttertoast.showToast(msg: 'Payment successful! Order confirmed.');
    setState(() => _isProcessing = false);
  }

  void _onPaymentFailure() {
    Fluttertoast.showToast(msg: 'Payment failed. Please try again.');
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number (10 digits) *',
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
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pincodeController,
                          decoration: const InputDecoration(
                            labelText: 'Pincode *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _landmarkController,
                          decoration: const InputDecoration(
                            labelText: 'Landmark (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _availableProducts.isEmpty
                        ? const Center(child: Text('No products available'))
                        : ListView.builder(
                            itemCount: _availableProducts.length,
                            itemBuilder: (context, index) {
                              final product = _availableProducts[index];
                              final isSelected = _selectedProductIds.contains(product.id);
                              return CheckboxListTile(
                                title: Text(product.name),
                                subtitle: Text(
                                  'Design: ${product.designNumber} | SKU: ${product.sku} | ₹${product.price}',
                                ),
                                value: isSelected,
                                onChanged: (_) => _toggleProduct(product.id),
                                secondary: Text('₹${product.price}'),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: ₹${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isProcessing || _selectedProducts.isEmpty
                              ? null
                              : _placeOrderWithWhatsApp,
                          icon: const Icon(Icons.chat),
                          label: Text(_isProcessing ? 'Processing...' : 'Verify on WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ---------- Order with WhatsApp ----------
  Future<void> _placeOrderWithWhatsApp() async {
    final name = _customerNameController.text.trim();
    final mobile = _mobileController.text.trim();
    final address = _addressController.text.trim();
    final pincode = _pincodeController.text.trim();

    if (name.isEmpty || mobile.isEmpty || address.isEmpty || pincode.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all required customer fields');
      return;
    }
    if (mobile.length < 10) {
      Fluttertoast.showToast(msg: 'Enter a valid 10-digit mobile number');
      return;
    }
    if (_selectedProducts.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select at least one product');
      return;
    }

    var user = _firebaseService.currentUser;
    if (user == null) {
      await _firebaseService.loadCurrentUser();
      user = _firebaseService.currentUser;
      if (user == null) {
        Fluttertoast.showToast(msg: 'Please login as influencer');
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final orderItems = _selectedProducts.map((product) {
        return order_models.OrderItem(
          productId: product.id,
          productName: product.name,
          designNumber: product.designNumber,
          productCode: product.productCode,
          sku: product.sku,
          quantity: 1,
          unitPrice: product.price,
          gstRate: product.gstRate,
          hsnCode: product.gstHsnCode,
          commissionEarned: 0,
        );
      }).toList();

      final totalOrderAmount = orderItems.fold(0.0, (sum, item) => sum + item.unitPrice * item.quantity);
      final vendorId = _selectedProducts.first.vendorId;

      final order = order_models.Order(
        orderId: '',
        orderNumber: '',
        invoiceNumber: null,
        customerId: '',
        customerName: name,
        mobile: mobile,
        address: address,
        city: '',
        state: '',
        pincode: pincode,
        landmark: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
        vendorId: vendorId,
        vendorName: '',
        influencerId: user.uid,
        influencerName: user.displayName ?? 'Influencer',
        referralCode: user.uid,
        items: orderItems,
        stockReduced: false,
        orderAmount: totalOrderAmount,
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
        createdBy: user.uid,
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
        Fluttertoast.showToast(msg: 'Order created. Please confirm on WhatsApp.');
      } else {
        Fluttertoast.showToast(msg: 'Unable to open WhatsApp. Please check your device.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}