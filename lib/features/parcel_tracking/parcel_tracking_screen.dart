import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ParcelTrackingScreen extends StatefulWidget {
  const ParcelTrackingScreen({super.key});

  @override
  State<ParcelTrackingScreen> createState() => _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends State<ParcelTrackingScreen> {
  final _firebaseService = FirebaseService();
  final _proofController = TextEditingController(text: 'unboxing_receipt_photo.png');

  @override
  void initState() {
    super.initState();
    _firebaseService.addListener(_onFirebaseChange);
  }

  @override
  void dispose() {
    _firebaseService.removeListener(_onFirebaseChange);
    _proofController.dispose();
    super.dispose();
  }

  void _onFirebaseChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _confirmReceipt(String parcelId, bool received) {
    _firebaseService.customerConfirmParcel(parcelId, received, _proofController.text.trim());
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(received ? 'Parcel receipt confirmed! Product is assigned & promotional link tracking can begin.' : 'Reported parcel as not received to Vendor.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _firebaseService.parcelTrackings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Secure Goods Delivery Status',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Keep track of sponsorships parcels in transit. Confirm reception is required before promotional link links commence.',
            style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
          ),
          const SizedBox(height: 20),
          _buildProofConfigInput(),
          const SizedBox(height: 20),
          ...list.map((parcel) => _buildParcelCard(parcel)),
        ],
      ),
    );
  }

  Widget _buildProofConfigInput() {
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
          const Text('Verification Proof Photo Reference', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _proofController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.photo_library, color: Color(0xFFD0BCFF), size: 18),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF49454F))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelCard(dynamic parcel) {
    final statusSteps = ['PLACED', 'PACKED', 'SHIPPED', 'TRANSIT', 'DELIVERED'];
    final currentIdx = statusSteps.indexOf(parcel.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text('Parcel ID: ${parcel.id}', style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF1C1B1F), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  parcel.status,
                  style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(parcel.productName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          // Interactive progress timeline representer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(statusSteps.length, (index) {
              final isPassed = index <= currentIdx;
              return Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPassed ? const Color(0xFFC4FF62) : const Color(0x33FFFFFF),
                    ),
                    child: isPassed ? const Icon(Icons.check, size: 8, color: Colors.black) : null,
                  ),
                  const SizedBox(height: 4),
                  Text(statusSteps[index].substring(0, 3), style: TextStyle(color: isPassed ? Colors.white : const Color(0xFF938F99), fontSize: 8)),
                ],
              );
            }),
          ),
          const Divider(color: Color(0x1AFFFFFF), height: 24),
          // Actions for confirm
          if (parcel.customerConfirmed == null) ...[
            const Text(
              'Please confirm if you have securely received this sponsorship asset package:',
              style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirmReceipt(parcel.id, false),
                    child: const Text('Not Received', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirmReceipt(parcel.id, true),
                    child: const Text('Received Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(parcel.customerConfirmed ? Icons.check_circle : Icons.error, color: parcel.customerConfirmed ? const Color(0xFFC4FF62) : Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  parcel.customerConfirmed ? 'Confirmed Received: ${parcel.proofImage}' : 'Reported Not Received',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}
