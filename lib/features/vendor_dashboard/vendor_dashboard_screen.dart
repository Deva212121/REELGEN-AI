import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/firestore_models.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Electronics');
  final _payoutController = TextEditingController(text: '20% Commission');
  final _simOrderAmountController = TextEditingController(text: '150.00');
  final String _vendorCode = 'VEN56879';

  void _handleUploadProduct() {
    if (_nameController.text.trim().isEmpty) return;
    final service = FirebaseService();
    service.submitOwnProduct(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      vendorCode: _vendorCode,
      payout: '${_payoutController.text.trim()} (Est: \$12.50/order)',
    );
    _nameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product uploaded to platform pool marketplace successfully!')),
    );
    setState(() {});
  }

  void _handleSimulateNewOrder() {
    final amtString = _simOrderAmountController.text.trim();
    final amt = double.tryParse(amtString) ?? 100.00;
    FirebaseService().addSimulatedOrder(_vendorCode, amt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF381E72),
        content: Text('Simulated Live Order Placed! Firestore doc created for \$$amtString with Standard 15-Day Settlement Cycle.'),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    final pendingApprove = service.productPromotions.where((p) => p.status == 'PENDING').toList();
    final approvedList = service.productPromotions.where((p) => p.status == 'APPROVED').toList();
    final parcels = service.parcelTrackings;

    // Filter settlements for this merchant
    final settlements = service.vendorSettlements.where((s) => s.vendorCode == _vendorCode).toList();

    // Aggregations
    double totalSales = settlements.fold(0.0, (sum, s) => sum + s.orderAmount);
    double pendingSettlement = settlements.where((s) => s.settlementStatus == 'pending').fold(0.0, (sum, s) => sum + s.settlementAmount);
    double processingSettlement = settlements.where((s) => s.settlementStatus == 'processing').fold(0.0, (sum, s) => sum + s.settlementAmount);
    double releasedSettlement = settlements.where((s) => s.settlementStatus == 'released').fold(0.0, (sum, s) => sum + s.settlementAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),

          // VENDOR SETTLEMENT CYCLE TRACKER CORES
          _buildSectionHeader('Vendor Settlement Ledger', Icons.account_balance_wallet_outlined),
          const SizedBox(height: 10),
          _buildSettlementKPIs(totalSales, pendingSettlement, processingSettlement, releasedSettlement),
          const SizedBox(height: 16),
          _buildFlowProcessExplanation(),
          const SizedBox(height: 16),
          _buildOrderSimulationCard(),
          const SizedBox(height: 16),
          _buildSettlementHistorySection(settlements),
          const SizedBox(height: 24),

          _buildSectionHeader('Merchant Sponsorship Actions', Icons.campaign_outlined),
          const SizedBox(height: 12),
          _buildApprovalsSection(pendingApprove),
          const SizedBox(height: 20),
          _buildOTPStatusSection(approvedList),
          const SizedBox(height: 20),
          _buildOwnProductPublishCard(),
          const SizedBox(height: 20),
          _buildParcelTrackingCard(parcels),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC4FF62), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC4FF62).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4FF62).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC4FF62)),
            child: const Icon(Icons.storefront, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AUTHORIZED BRAND PORTAL', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Primary Vendor Code: $_vendorCode', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementKPIs(double total, double pending, double processing, double released) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Total Sales',
                amount: total,
                icon: Icons.monetization_on_outlined,
                color: const Color(0xFFC4FF62),
                subtitle: 'Cumulative volume',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKPICard(
                title: 'Released Payments',
                amount: released,
                icon: Icons.check_circle_outline,
                color: const Color(0xFFC4FF62),
                subtitle: 'Disbursed to bank',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Pending Settlement',
                amount: pending,
                icon: Icons.hourglass_empty_outlined,
                color: Colors.amberAccent,
                subtitle: 'In return windows',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKPICard(
                title: 'Processing Settlement',
                amount: processing,
                icon: Icons.autorenew_outlined,
                color: Colors.cyanAccent,
                subtitle: 'Ready for release',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF938F99), fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.black, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildFlowProcessExplanation() {
    final steps = [
      {'title': 'Placed', 'desc': 'Order created'},
      {'title': 'Delivered', 'desc': 'In Transit/Arrival'},
      {'title': 'Return Window', 'desc': '15 days cycle'},
      {'title': 'Processing', 'desc': 'Audit cleared'},
      {'title': 'Released', 'desc': 'Funds credited'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF130F26),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF381E72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFFD0BCFF), size: 14),
              SizedBox(width: 6),
              Text('Settlement Journey Milestones', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(steps.length, (index) {
                final s = steps[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2930),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF49454F)),
                      ),
                      child: Column(
                        children: [
                          Text('${index + 1}. ${s['title']}', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(s['desc']!, style: const TextStyle(color: Colors.white38, fontSize: 8)),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 10),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSimulationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0BCFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.add_shopping_cart, color: Color(0xFFD0BCFF), size: 16),
              SizedBox(width: 8),
              Text('Simulate Customer Order (Live Mock)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _simOrderAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: 'Order Amount (\$)',
                    labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
                    prefixIcon: const Icon(Icons.attach_money, size: 14),
                    filled: true,
                    fillColor: const Color(0x13FFFFFF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC4FF62),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _handleSimulateNewOrder,
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('PLACE ORDER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '*Adds a new simulated order into the firestore vendor_settlements list instantly so you can test transitions.',
            style: TextStyle(color: Colors.white38, fontSize: 9, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementHistorySection(List<VendorSettlement> settlements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            const Text('Settlement History Ledger', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            Text('${settlements.length} Orders', style: const TextStyle(color: Color(0xFF938F99), fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        if (settlements.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2930),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF49454F)),
            ),
            child: const Center(
              child: Text(
                'No active settlement documents found in Firestore.',
                style: TextStyle(color: Color(0xFF938F99), fontSize: 11),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final s = settlements[index];
              final isReleased = s.settlementStatus == 'released';
              final isProcessing = s.settlementStatus == 'processing';

              Color statusBadgeColor = Colors.amber;
              if (isReleased) statusBadgeColor = const Color(0xFFC4FF62);
              if (isProcessing) statusBadgeColor = Colors.cyanAccent;

              // Remaining timeline display
              String countdownText = '';
              if (isReleased) {
                countdownText = 'Settled & Released';
              } else if (s.orderStatus == 'Return Window Active' || s.orderStatus == 'Settlement Processing') {
                if (s.releaseDate != null) {
                  final diff = s.releaseDate!.difference(DateTime.now()).inDays;
                  countdownText = diff <= 0 ? 'Cycle complete (Today)' : '$diff Days remaining in cycle';
                } else {
                  countdownText = '15-Day Cycle active';
                }
              } else {
                countdownText = 'Awaiting delivery milestone to begin 15-day cycle';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2930),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: s.isHeld ? Colors.redAccent.withOpacity(0.6) : const Color(0xFF49454F),
                    width: s.isHeld ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Order ID and status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text(
                          s.orderId,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.black, fontFamily: 'monospace'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBadgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusBadgeColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            s.settlementStatus.toUpperCase(),
                            style: TextStyle(color: statusBadgeColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0x1FEEEEEE), height: 16),

                    // Monetary values row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ORDER AMOUNT', style: TextStyle(color: Colors.white30, fontSize: 8)),
                            const SizedBox(height: 2),
                            Text('\$${s.orderAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NET TO RELEASE (85%)', style: TextStyle(color: Colors.white30, fontSize: 8)),
                            const SizedBox(height: 2),
                            Text('\$${s.settlementAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Order flow visual tracker
                    const Text('ORDER LIFE MOVEMENT:', style: TextStyle(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildInteractiveTimeline(s.orderStatus),
                    const SizedBox(height: 8),

                    // Countdown section
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white30, size: 10),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            countdownText,
                            style: const TextStyle(color: Colors.white60, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),

                    // Hold Section (If held)
                    if (s.isHeld) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'HELD BY AUDITOR: ${s.holdReason ?? "Hold in review"}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Advance simulator button
                    if (!isReleased) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: s.isHeld ? Colors.white10 : const Color(0xFFD0BCFF).withOpacity(0.6)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: s.isHeld
                              ? null
                              : () {
                                  FirebaseService().advanceSettlementFlow(s.settlementId);
                                  setState(() {});
                                },
                          icon: Icon(Icons.fast_forward_outlined, size: 12, color: s.isHeld ? Colors.white24 : const Color(0xFFD0BCFF)),
                          label: Text(
                            s.isHeld ? 'HELD (Cannot Advance)' : 'ADVANCE EVENT',
                            style: TextStyle(fontSize: 9, color: s.isHeld ? Colors.white24 : Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInteractiveTimeline(String currentStatus) {
    final Map<String, int> orderStages = {
      'Placed': 1,
      'Packed': 2,
      'Shipped': 3,
      'Delivered': 4,
      'Return Window Active': 5,
      'Settlement Processing': 6,
      'Settlement Released': 7,
    };

    final currentRank = orderStages[currentStatus] ?? 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: orderStages.keys.map((statusKey) {
          final isPastOrCurrent = (orderStages[statusKey] ?? 1) <= currentRank;
          final isCurrent = statusKey == currentStatus;

          Color indicatorColor = Colors.white10;
          if (isCurrent) {
            indicatorColor = const Color(0xFFC4FF62);
          } else if (isPastOrCurrent) {
            indicatorColor = const Color(0xFF381E72).withOpacity(0.5);
          }

          return Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCurrent ? const Color(0xFFC4FF62) : (isPastOrCurrent ? const Color(0xFFD0BCFF).withOpacity(0.4) : Colors.transparent),
                width: 1,
              ),
            ),
            child: Text(
              statusKey,
              style: TextStyle(
                color: isCurrent ? Colors.black : (isPastOrCurrent ? Colors.white70 : Colors.white38),
                fontSize: 8,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApprovalsSection(List pendingApprove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            const Text('Sponsorship Proposals Requested', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${pendingApprove.length} PENDING', style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (pendingApprove.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF2B2930), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF49454F))),
            child: const Text('No pending influencer promotion request documents in Firestore.', style: TextStyle(color: Color(0xFF938F99), fontSize: 11)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingApprove.length,
            itemBuilder: (context, index) {
              final item = pendingApprove[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2930),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF49454F)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Requested by: ${item.influencerId}', style: const TextStyle(color: Color(0xFF938F99), fontSize: 10)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC4FF62),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        FirebaseService().approvePromotionRequest(item.id);
                        setState(() {});
                      },
                      child: const Text('APPROVE & GEN OTP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOTPStatusSection(List approvedList) {
    if (approvedList.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active OTP Clearance Keys', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...approvedList.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x13FFFFFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF49454F)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.productName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      Text('Assigned influencer: ${p.influencerId}', style: const TextStyle(color: Color(0xFF938F99), fontSize: 9)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF381E72), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'OTP: ${p.approvalOtp}',
                      style: const TextStyle(color: Color(0xFFD0BCFF), fontSize: 12, fontWeight: FontWeight.black, fontFamily: 'monospace', letterSpacing: 1.2),
                    ),
                  )
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildOwnProductPublishCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2930),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF49454F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.add_circle_outline, color: Color(0xFFD0BCFF), size: 18),
              SizedBox(width: 8),
              Text('Own Product Listing Publisher', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Product Name',
              labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _categoryController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Category Area',
              labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _payoutController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Creator Payout Model Offer',
              labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 11),
              filled: true,
              fillColor: const Color(0x13FFFFFF),
              contentPadding: const EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF49454F))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0BCFF))),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF381E72),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _handleUploadProduct,
            child: const Text('UPLOAD OWN PRODUCT TO POOL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelTrackingCard(List<ParcelTracking> list) {
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
          Row(
            children: const [
              Icon(Icons.local_shipping_outlined, color: Color(0xFFC4FF62), size: 18),
              SizedBox(width: 8),
              Text('Brand Shipping & Transit Console', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final parcel = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parcel ID: ${parcel.id} | Product: ${parcel.productName}', style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Assignee: ${parcel.influencerId}', style: const TextStyle(color: Colors.white60, fontSize: 9)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Status: ${parcel.status}', style: const TextStyle(color: Color(0xFFC4FF62), fontSize: 10, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        _buildStatusBtn(parcel.id, 'SHIPPED'),
                        const SizedBox(width: 4),
                        _buildStatusBtn(parcel.id, 'TRANSIT'),
                        const SizedBox(width: 4),
                        _buildStatusBtn(parcel.id, 'DELIVERED'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBtn(String parcelId, String status) {
    return InkWell(
      onTap: () {
        FirebaseService().updateParcelTransit(parcelId, status);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFF2B2930), borderRadius: BorderRadius.circular(4)),
        child: Text(status.substring(0, 3), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
