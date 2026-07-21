import 'package:flutter/material.dart';
import '../../models/influencer_product_assignment_model.dart';
import '../../models/product_model.dart';
import '../../services/influencer_product_service.dart';

/// Screen displaying the influencer's assigned products (My Products).
/// Provides filtering by All / Active / Inactive.
class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final InfluencerProductService _service = InfluencerProductService();
  FilterType _filter = FilterType.all;
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips using Wrap to avoid overflow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: _filter == FilterType.all,
                  onSelected: () => setState(() => _filter = FilterType.all),
                ),
                _buildFilterChip(
                  label: 'Active',
                  isSelected: _filter == FilterType.active,
                  onSelected: () => setState(() => _filter = FilterType.active),
                ),
                _buildFilterChip(
                  label: 'Inactive',
                  isSelected: _filter == FilterType.inactive,
                  onSelected: () =>
                      setState(() => _filter = FilterType.inactive),
                ),
              ],
            ),
          ),
          // Stream builder for assignments
          Expanded(
            child: StreamBuilder<List<InfluencerProductAssignment>>(
              key: ValueKey(_refreshKey),
              stream: _service.watchMyAssignments(activeOnly: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  String message = 'Something went wrong.';
                  bool isPermissionDenied = false;
                  bool isUnauthenticated = false;
                  if (error is InfluencerProductException) {
                    switch (error.code) {
                      case 'unauthenticated':
                        isUnauthenticated = true;
                        message =
                            'Please sign in as an influencer to view your products.';
                        break;
                      case 'role-not-allowed':
                        isPermissionDenied = true;
                        message =
                            'Your account does not have influencer privileges.';
                        break;
                      case 'permission-denied':
                        isPermissionDenied = true;
                        message =
                            'You do not have permission to view these assignments.';
                        break;
                      default:
                        message = error.message;
                    }
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPermissionDenied || isUnauthenticated
                                ? Icons.lock_outline
                                : Icons.error_outline,
                            size: 64,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _refreshKey++;
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allAssignments = snapshot.data!;
                final filteredAssignments = _filter.apply(allAssignments);

                if (filteredAssignments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'My Products will appear here after secure product activation is completed.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    if (isNarrow) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAssignments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ProductCard(
                                assignment: filteredAssignments[index]),
                          );
                        },
                      );
                    } else {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 280, // safe fixed height
                        ),
                        itemCount: filteredAssignments.length,
                        itemBuilder: (context, index) {
                          return _ProductCard(
                              assignment: filteredAssignments[index]);
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor:
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white60,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Colors.white24,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}

enum FilterType {
  all,
  active,
  inactive,
}

extension FilterTypeExtension on FilterType {
  List<InfluencerProductAssignment> apply(
      List<InfluencerProductAssignment> assignments) {
    switch (this) {
      case FilterType.all:
        return assignments;
      case FilterType.active:
        return assignments.where((a) => a.isActive).toList();
      case FilterType.inactive:
        return assignments.where((a) => !a.isActive).toList();
    }
  }
}

class _ProductCard extends StatelessWidget {
  final InfluencerProductAssignment assignment;

  const _ProductCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      color: const Color(0xFF2B2930),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: assignment.isActive
              ? colorScheme.secondary.withValues(alpha: 0.3)
              : Colors.white24,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  assignment.imageUrl != null && assignment.imageUrl!.isNotEmpty
                      ? Image.network(
                          assignment.imageUrl!,
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholderImage(),
                        )
                      : _placeholderImage(),
            ),
            const SizedBox(height: 8),
            Text(
              assignment.productName,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₹${assignment.sellingPrice.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.commissionType == CommissionType.fixed
                        ? '₹${assignment.commissionValue.toStringAsFixed(2)} fixed'
                        : '${assignment.commissionValue.toStringAsFixed(0)}%',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: assignment.isActive
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.isActive ? 'Active' : 'Inactive',
                    style: textTheme.bodySmall?.copyWith(
                      color: assignment.isActive ? Colors.green : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Referral Code',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      assignment.referralCode.isNotEmpty
                          ? assignment.referralCode
                          : 'N/A',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _statChip(Icons.touch_app, assignment.clicks.toString()),
                _statChip(Icons.shopping_cart, assignment.orders.toString()),
                _statChip(Icons.currency_rupee,
                    assignment.salesAmount.toStringAsFixed(0)),
                _statChip(Icons.payments,
                    '₹${assignment.commissionEarned.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 80,
      width: double.infinity,
      color: Colors.grey[800],
      child: const Icon(Icons.image, color: Colors.grey, size: 32),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white60),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
