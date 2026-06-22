import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final _firebaseService = FirebaseService();
  final _handleController = TextEditingController(text: '@active_creator');
  int _selectedProductIndex = 0;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    _handleController.dispose();
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSubmitRequest() {
    final product = _firebaseService.marketplaceProducts[_selectedProductIndex];
    _firebaseService.submitPromotionRequest(
      influencerHandle: _handleController.text,
      product: product,
    );
    setState(() {
      _successMessage = 'Promotion request submitted for ${product.name}! Waiting for Brand approval & OTP key generation in the Vendor Workspace.';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sponsorship promo request successfully created in Firestore!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _firebaseService.marketplaceProducts;
    final promotionsList = _firebaseService.productPromotions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Secure Brand Sponsorships',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Apply directly to campaigns in Cloud Firestore and monitor OTP security key states.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
          const SizedBox(height: 20),
          _buildInfluencerInput(),
          const SizedBox(height: 16),
          const Text(
            'Available Sponsorship Products',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildProductsList(products),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: products.isEmpty ? null : _handleSubmitRequest,
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: const Text('SUBMIT CAMPAIGN PROPOSAL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (_successMessage != null) ...[
            const SizedBox(height: 16),
            _buildNotificationBox(_successMessage!),
          ],
          const SizedBox(height: 24),
          _buildFirestoreConsole(promotionsList),
        ],
      ),
    );
  }

  Widget _buildInfluencerInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Influencer Account Handle / ID', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _handleController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFFD0BCFF), size: 18),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF49454F)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD0BCFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<PromoProduct> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF2B2930), borderRadius: BorderRadius.circular(12)),
        child: const Text('No products currently listed. Upload some own brand items first!', style: TextStyle(color: Color(0xFF938F99), fontSize: 11)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _selectedProductIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedProductIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0x2B381E72) : const Color(0xFF2B2930),
              border: Border.all(
                color: isSelected ? const Color(0xFFD0BCFF) : const Color(0xFF49454F),
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0x22FFFFFF), borderRadius: BorderRadius.circular(6)),
                            child: Text(item.category, style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
                          ),
                          const SizedBox(width: 8),
                          Text('Vendor: ${item.vendorCode}', style: const TextStyle(color: Color(0xFF938F99), fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.payoutModel, style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Radio<int>(
                  value: index,
                  groupValue: _selectedProductIndex,
                  activeColor: const Color(0xFFD0BCFF),
                  onChanged: (val) => setState(() => _selectedProductIndex = val!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withOpacity(0.12),
        border: Border.all(color: const Color(0xFF059669)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Color(0xFFC4FF62), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirestoreConsole(List<ProductPromotion> promos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange)),
                  const SizedBox(width: 8),
                  const Text('cloud_firestore console', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('/product_promotions', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (promos.isEmpty)
            const Text(
              'No requested sponsor documents actively recorded.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ...promos.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080D16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: p.status == 'APPROVED' ? Colors.cyan.withOpacity(0.4) : (p.status == 'VERIFIED' ? const Color(0xFFC4FF62).withOpacity(0.4) : Colors.transparent),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Text('ID: ${p.id}', style: const TextStyle(color: Color(0xffa5f3fc), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                          Text(
                            p.status,
                            style: TextStyle(
                              color: p.status == 'VERIFIED' ? const Color(0xFFC4FF62) : (p.status == 'APPROVED' ? Colors.cyan : Colors.amber),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('  "influencerId": "${p.influencerId}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "productName": "${p.productName}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "vendorCode": "${p.vendorCode}",', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "approvalOtp": "${p.approvalOtp.isEmpty ? 'Waiting...' : p.approvalOtp}",', style: const TextStyle(color: Colors.orangeAccent, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "otpVerified": ${p.otpVerified},', style: const TextStyle(color: Colors.cyan, fontSize: 9, fontFamily: 'monospace')),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
