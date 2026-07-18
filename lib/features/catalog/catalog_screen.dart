import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/product_model.dart';

typedef ProductActivationHandler = Future<void> Function(Product product);

enum CatalogViewMode { superAdmin, influencer }

class CatalogScreen extends StatefulWidget {
  final CatalogViewMode viewMode;
  final ProductActivationHandler? onSellProduct;

  const CatalogScreen.superAdmin({
    super.key,
  })  : viewMode = CatalogViewMode.superAdmin,
        onSellProduct = null;

  const CatalogScreen.influencer({
    super.key,
    required this.onSellProduct,
  }) : viewMode = CatalogViewMode.influencer;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _activatingProductIds = <String>{};

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _productsStream;

  String? _selectedCategory;
  bool _inStockOnly = false;

  bool get _isInfluencerView =>
      widget.viewMode == CatalogViewMode.influencer;

  @override
  void initState() {
    super.initState();
    final products = FirebaseFirestore.instance.collection('products');
    _productsStream = _isInfluencerView
        ? products.where('isActive', isEqualTo: true).snapshots()
        : products.snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isInfluencerView ? 'Product Catalog' : 'Catalog Management',
        ),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _CatalogMessage(
              icon: Icons.cloud_off,
              title: 'Catalog could not be loaded',
              message: _catalogErrorMessage(snapshot.error),
            );
          }

          final products = snapshot.data?.docs
                  .map((document) => Product.fromFirestore(document))
                  .where((product) =>
                      !_isInfluencerView || product.isActive)
                  .toList() ??
              <Product>[];

          products.sort(
              (first, second) => second.updatedAt.compareTo(first.updatedAt));

          if (products.isEmpty) {
            return _CatalogMessage(
              icon: Icons.inventory_2_outlined,
              title: 'No products available',
              message: _isInfluencerView
                  ? 'Active products added by Super Admin will appear here.'
                  : 'Products added by Super Admin will appear here.',
            );
          }

          return _buildCatalog(products);
        },
      ),
    );
  }

  Widget _buildCatalog(List<Product> products) {
    final categories = products
        .map((product) => product.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final selectedCategory =
        categories.contains(_selectedCategory) ? _selectedCategory : null;
    final query = _searchController.text.trim().toLowerCase();

    final filteredProducts = products.where((product) {
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.designNumber.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == null || product.category == selectedCategory;
      final matchesStock = !_inStockOnly || product.isInStock;
      return matchesSearch && matchesCategory && matchesStock;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 360,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Search products',
                    hintText: 'Name, category, design number or SKU',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 230,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      hint: const Text('All categories'),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child:
                              Text(category, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (category) =>
                          setState(() => _selectedCategory = category),
                    ),
                  ),
                ),
              ),
              FilterChip(
                selected: _inStockOnly,
                label: const Text('In stock only'),
                avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                onSelected: (selected) =>
                    setState(() => _inStockOnly = selected),
              ),
              if (selectedCategory != null)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedCategory = null),
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Clear category'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${filteredProducts.length} product${filteredProducts.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredProducts.isEmpty
                ? const _CatalogMessage(
                    icon: Icons.search_off,
                    title: 'No matching products',
                    message: 'Change the search text or filters and try again.',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = _columnCount(constraints.maxWidth);
                      return GridView.builder(
                        itemCount: filteredProducts.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 460,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _CatalogProductCard(
                            product: product,
                            showActivationAction: _isInfluencerView,
                            isActivating:
                                _activatingProductIds.contains(product.id),
                            onViewDetails: () => _openProductDetails(product),
                            onSellProduct: _isInfluencerView
                                ? () => _requestActivation(product)
                                : null,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  int _columnCount(double width) {
    if (width >= 1250) return 4;
    if (width >= 900) return 3;
    if (width >= 580) return 2;
    return 1;
  }

  Future<void> _openProductDetails(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CatalogProductDetailsScreen(
          product: product,
          viewMode: widget.viewMode,
          onSellProduct: widget.onSellProduct,
        ),
      ),
    );
  }

  Future<void> _requestActivation(Product product) async {
    final activationHandler = widget.onSellProduct;
    if (activationHandler == null ||
        !product.isInStock ||
        _activatingProductIds.contains(product.id)) {
      return;
    }

    final confirmed = await showProductActivationConfirmation(context, product);
    if (!confirmed || !mounted) return;

    setState(() => _activatingProductIds.add(product.id));
    try {
      await activationHandler(product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product activated successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Product could not be activated. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _activatingProductIds.remove(product.id));
      }
    }
  }

  String _catalogErrorMessage(Object? error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'You do not have permission to read the product catalog.';
    }
    return 'Check your connection and try again.';
  }
}

class CatalogProductDetailsScreen extends StatefulWidget {
  final Product product;
  final CatalogViewMode viewMode;
  final ProductActivationHandler? onSellProduct;

  const CatalogProductDetailsScreen({
    super.key,
    required this.product,
    required this.viewMode,
    this.onSellProduct,
  });

  @override
  State<CatalogProductDetailsScreen> createState() =>
      _CatalogProductDetailsScreenState();
}

class _CatalogProductDetailsScreenState
    extends State<CatalogProductDetailsScreen> {
  bool _isActivating = false;

  Product get product => widget.product;
  bool get _isInfluencerView =>
      widget.viewMode == CatalogViewMode.influencer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 360,
                    child: _ProductImage(product: product),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(product.category)),
                    _StockChip(product: product),
                    if (product.discountPercentage > 0)
                      Chip(
                          label: Text(
                              '${product.discountPercentage.round()}% OFF')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(product.name,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                _PriceLine(product: product, large: true),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                            label: 'Design number',
                            value: product.designNumber),
                        _DetailRow(label: 'SKU', value: product.sku),
                        _DetailRow(
                            label: 'Available stock',
                            value: '${product.availableStock} ${product.unit}'),
                        _DetailRow(
                            label: 'Influencer commission',
                            value: _commissionLabel(product)),
                        _DetailRow(
                            label: 'Delivery time',
                            value: _deliveryLabel(product)),
                        if (!_isInfluencerView)
                          _DetailRow(
                            label: 'Catalog status',
                            value: product.isActive ? 'Active' : 'Inactive',
                          ),
                      ],
                    ),
                  ),
                ),
                if ((product.description?.trim() ?? '').isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Description',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(product.description?.trim() ?? ''),
                ],
                if (_isInfluencerView) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: !product.isInStock || _isActivating
                        ? null
                        : _activateProduct,
                    icon: _isActivating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.campaign),
                    label: Text(
                      !product.isInStock
                          ? 'Out of Stock'
                          : _isActivating
                              ? 'Activating...'
                              : 'Sell This Product',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _activateProduct() async {
    final activationHandler = widget.onSellProduct;
    if (activationHandler == null) return;

    final confirmed = await showProductActivationConfirmation(context, product);
    if (!confirmed || !mounted) return;

    setState(() => _isActivating = true);
    try {
      await activationHandler(product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product activated successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Product could not be activated. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActivating = false);
    }
  }
}

class _CatalogProductCard extends StatelessWidget {
  final Product product;
  final bool showActivationAction;
  final bool isActivating;
  final VoidCallback onViewDetails;
  final Future<void> Function()? onSellProduct;

  const _CatalogProductCard({
    required this.product,
    required this.showActivationAction,
    required this.isActivating,
    required this.onViewDetails,
    required this.onSellProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ProductImage(product: product),
                Positioned(
                  left: 10,
                  top: 10,
                  child: _StockChip(product: product),
                ),
                if (product.discountPercentage > 0)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Chip(
                      label: Text('${product.discountPercentage.round()}% OFF'),
                      backgroundColor: const Color(0xFFC4FF62),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  _PriceLine(product: product),
                  const SizedBox(height: 8),
                  Text('Commission: ${_commissionLabel(product)}'),
                  Text('Stock: ${product.availableStock} ${product.unit}'),
                  Text('Delivery: ${_deliveryLabel(product)}'),
                  if (!showActivationAction)
                    Text('Status: ${product.isActive ? 'Active' : 'Inactive'}'),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onViewDetails,
                          child: const Text('View Details'),
                        ),
                      ),
                      if (showActivationAction) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: !product.isInStock || isActivating
                                ? null
                                : onSellProduct,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                !product.isInStock
                                    ? 'Out of Stock'
                                    : isActivating
                                        ? 'Activating...'
                                        : 'Sell This Product',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final Product product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl?.trim() ?? '';
    if (imageUrl.isEmpty) return const _ImageFallback();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, _) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, _, __) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, size: 54),
    );
  }
}

class _StockChip extends StatelessWidget {
  final Product product;

  const _StockChip({required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = product.isInStock;
    final color = inStock ? Colors.green : Colors.red;
    return Chip(
      label: Text(inStock ? 'In Stock' : 'Out of Stock'),
      avatar: Icon(inStock ? Icons.check_circle : Icons.cancel,
          color: color, size: 18),
      backgroundColor: color.withAlpha(35),
      side: BorderSide(color: color),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final Product product;
  final bool large;

  const _PriceLine({required this.product, this.large = false});

  @override
  Widget build(BuildContext context) {
    final priceStyle = (large
            ? Theme.of(context).textTheme.headlineSmall
            : Theme.of(context).textTheme.titleLarge)
        ?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFC4FF62));

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('₹${product.price.toStringAsFixed(2)}', style: priceStyle),
        if (product.effectiveMrp > product.price)
          Text(
            '₹${product.effectiveMrp.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _CatalogMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

Future<bool> showProductActivationConfirmation(
    BuildContext context, Product product) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Activate this product?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 140,
                width: double.maxFinite,
                child: _ProductImage(product: product),
              ),
            ),
            const SizedBox(height: 12),
            Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Selling price: ₹${product.price.toStringAsFixed(2)}'),
            Text('Commission: ${_commissionLabel(product)}'),
            Text('Available stock: ${product.availableStock} ${product.unit}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Activate Product'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

String _commissionLabel(Product product) {
  if (product.commissionType == CommissionType.fixed) {
    return '₹${product.commissionValue.toStringAsFixed(2)}';
  }
  return '${product.commissionValue.toStringAsFixed(2)}%';
}

String _deliveryLabel(Product product) {
  final deliveryDays = product.deliveryDays;
  if (deliveryDays == null || deliveryDays <= 0) return 'Not specified';
  return '$deliveryDays day${deliveryDays == 1 ? '' : 's'}';
}
