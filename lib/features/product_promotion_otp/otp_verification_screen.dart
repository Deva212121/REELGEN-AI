import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _firebaseService = FirebaseService();
  final _otpController = TextEditingController();
  String? _selectedPromoId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    _otpController.dispose();
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleVerify() {
    if (_selectedPromoId == null) return;
    final verified = _firebaseService.verifyPromotionOtp(_selectedPromoId!, _otpController.text.trim());

    if (verified) {
      setState(() {
        _errorMessage = null;
        _otpController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sponsorship OTP verified! Referral code and tracking link are unlocked!')),
      );
    } else {
      setState(() {
        _errorMessage = 'Mismatched OTP or campaign is not approved yet. Look up active OTP codes in the Brand Vendor Workspace.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingSponsors = _firebaseService.productPromotions.where((p) => !p.otpVerified).toList();
    final activeAffiliates = _firebaseService.affiliateLinks;

    // Default select if empty
    if (_selectedPromoId == null && pendingSponsors.isNotEmpty) {
      _selectedPromoId = pendingSponsors.first.id;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Secure OTP Contract Activation',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter the 6-digit code generated from the brand vendor workspace to authorize promotional links.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
          const SizedBox(height: 20),
          if (pendingSponsors.isEmpty)
            _buildEmptyAlert()
          else
            _buildValidationCard(pendingSponsors),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildErrorBox(_errorMessage!),
          ],
          const SizedBox(height: 24),
          _buildUnlockedAffiliates(activeAffiliates),
          const SizedBox(height: 20),
          _buildFirestoreLinksConsole(activeAffiliates),
        ],
      ),
    );
  }

  Widget _buildEmptyAlert() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        children: const [
          Icon(Icons.check_circle, color: Color(0xFFC4FF62), size: 40),
          SizedBox(height: 12),
          Text(
            'No pending secure OTP verifications!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Browse sponsorship products and submit new campaign requests first.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCard(List pendingList) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Select Active Approved Campaign',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0x13FFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF49454F)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF2B2930),
                value: _selectedPromoId,
                onChanged: (val) {
                  setState(() {
                    _selectedPromoId = val;
                  });
                },
                items: pendingList.map<DropdownMenuItem<String>>((promo) {
                  return DropdownMenuItem<String>(
                    value: promo.id,
                    child: Text(
                      '${promo.productName} (ID: ${promo.id} - ${promo.status})',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD0BCFF)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '6-Digit OTP Security Code',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 4),
            maxLength: 6,
            decoration: InputDecoration(
              counterText: '',
              prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFFD0BCFF), size: 18),
              hintText: 'e.g., 582910',
              hintStyle: const TextStyle(color: Colors.white30, letterSpacing: 1),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
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
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC4FF62),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _handleVerify,
            child: const Text('VERIFY SECURITY CONTRACT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox(String err) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.12),
        border: Border.all(color: const Color(0xFFEF4444)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        err,
        style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUnlockedAffiliates(List activeLinks) {
    if (activeLinks.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Color(0xFFC4FF62), size: 18),
            SizedBox(width: 8),
            Text('Unlocked Direct Referral channels', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeLinks.length,
          itemBuilder: (context, index) {
            final link = activeLinks[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2930),
                border: Border.all(color: const Color(0xFFC4FF62).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(link.productName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CODE: ${link.referralCode}', style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        const SizedBox(height: 2),
                        Text('TRACK: ${link.trackingLink}', style: const TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricVal('Clicks', link.clicks.toString()),
                      _buildMetricVal('Orders', link.orders.toString()),
                      _buildMetricVal('Conv %', '${link.conversions}%'),
                      _buildMetricVal('Revenue', '\$${link.businessAmount}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF49454F)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            _firebaseService.simulateEngagement(link.id, isOrder: false);
                            setState(() {});
                          },
                          child: const Text('+10 Clicks', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            _firebaseService.simulateEngagement(link.id, isOrder: true);
                            setState(() {});
                          },
                          child: const Text('Simulate Order', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricVal(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFirestoreLinksConsole(List activeLinks) {
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
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue)),
                  const SizedBox(width: 8),
                  const Text('cloud_firestore console', style: TextStyle(color: Color(0xFF938F99), fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
              const Text('/affiliate_links', style: TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0x33FFFFFF), height: 16),
          if (activeLinks.isEmpty)
            const Text(
              'No generated affiliate_links documents yet. OTP verify will synthesize document rows dynamically.',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 10, fontFamily: 'monospace'),
            )
          else
            ...activeLinks.map((link) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF080D16), borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LINK ID: ${link.id}', style: const TextStyle(color: Color(0xffa5f3fc), fontSize: 10, fontFamily: 'monospace')),
                      const SizedBox(height: 4),
                      Text('  "code": "${link.referralCode}",', style: const TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "url": "${link.trackingLink}",', style: const TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'monospace')),
                      Text('  "clicks": ${link.clicks}, "orders": ${link.orders},', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontFamily: 'monospace')),
                      Text('  "revenue": \$${link.businessAmount}', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 9, fontFamily: 'monospace')),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
roundedCornerShape(double rate) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(rate));
