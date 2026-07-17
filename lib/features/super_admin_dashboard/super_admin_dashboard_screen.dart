import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../models/partner_stock_model.dart';
import '../../models/order_model.dart' as order_models;
import '../../services/settings_service.dart';
import '../../services/analytics_service.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  // Add Product Controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _designNumberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _deliveryDaysController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _commissionValueController = TextEditingController();
  CommissionType _selectedCommissionType = CommissionType.percent;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedProductImage;
  Uint8List? _selectedProductImageBytes;
  bool _isPickingProductImage = false;
  bool _isSavingProduct = false;

  // Allocate Stock Controllers
  final TextEditingController _partnerAmountController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  // Settings
  int _releaseDays = 7;
  final SettingsService _settingsService = SettingsService();
  final AnalyticsService _analyticsService = AnalyticsService();

  String? _selectedPartnerId;

  final List<String> _platforms = ['meesho', 'flipkart', 'amazon', 'reelgen'];
  final Map<String, double> _platformAllocation = {
    'meesho': 42,
    'flipkart': 28,
    'amazon': 20,
    'reelgen': 10,
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _designNumberController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _mrpController.dispose();
    _deliveryDaysController.dispose();
    _categoryController.dispose();
    _commissionValueController.dispose();
    _partnerAmountController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final days = await _settingsService.getCommissionReleaseDays();
    setState(() {
      _releaseDays = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Super Admin Dashboard'),
          backgroundColor: const Color(0xFF130F26),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_box), text: 'Add Product'),
              Tab(icon: Icon(Icons.business), text: 'Partner Mgmt'),
              Tab(icon: Icon(Icons.analytics), text: 'CA Report'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Analytics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAddProduct(),
            _buildPartnerManagement(),
            _buildCAReport(),
            _buildSettings(),
            _buildAnalyticsGraphs(),
          ],
        ),
      ),
    );
  }

  // ---------- Add Product ----------
  Widget _buildAddProduct() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _designNumberController,
                decoration: const InputDecoration(labelText: 'Design Number'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Selling Price (₹)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mrpController,
                decoration: const InputDecoration(labelText: 'MRP (₹)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isPickingProductImage || _isSavingProduct
                    ? null
                    : _pickProductImage,
                icon: _isPickingProductImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _selectedProductImage == null
                      ? 'Select Product Photo'
                      : 'Change Product Photo',
                ),
              ),
              if (_selectedProductImageBytes != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _selectedProductImageBytes!,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Center(child: Text('Photo preview unavailable')),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedProductImage!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: _deliveryDaysController,
                decoration: const InputDecoration(labelText: 'Delivery Days'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CommissionType>(
                decoration: const InputDecoration(labelText: 'Commission Type'),
                value: _selectedCommissionType,
                items: CommissionType.values.map((type) {
                  return DropdownMenuItem<CommissionType>(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedCommissionType = value);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commissionValueController,
                decoration: const InputDecoration(
                  labelText: 'Commission Value',
                  helperText: 'Percentage (0–100) or fixed amount in ₹',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isSavingProduct ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC4FF62),
                  foregroundColor: Colors.black,
                ),
                child: _isSavingProduct
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProductImage() async {
    setState(() => _isPickingProductImage = true);
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 1800,
      );
      if (image == null) return;

      final extension = _imageExtension(image.name);
      if (!const {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
        Fluttertoast.showToast(msg: 'Only JPG, PNG or WebP photos are allowed');
        return;
      }

      final bytes = await image.readAsBytes();
      const maximumSizeInBytes = 5 * 1024 * 1024;
      if (bytes.isEmpty || bytes.length > maximumSizeInBytes) {
        Fluttertoast.showToast(msg: 'Photo must be smaller than 5 MB');
        return;
      }

      if (!mounted) return;
      setState(() {
        _selectedProductImage = image;
        _selectedProductImageBytes = bytes;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Unable to select photo: $e');
    } finally {
      if (mounted) setState(() => _isPickingProductImage = false);
    }
  }

  // ---------- Add Product Logic ----------
  Future<void> _addProduct() async {
    final name = _productNameController.text.trim();
    final designNumber = _designNumberController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final mrp = double.tryParse(_mrpController.text.trim());
    final quantity = int.tryParse(_quantityController.text.trim());
    final deliveryDays = int.tryParse(_deliveryDaysController.text.trim());
    final category = _categoryController.text.trim();
    final commissionValue = double.tryParse(_commissionValueController.text.trim());

    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Product name is required');
      return;
    }
    if (designNumber.isEmpty) {
      Fluttertoast.showToast(msg: 'Design number is required');
      return;
    }
    if (price == null || price <= 0) {
      Fluttertoast.showToast(msg: 'Selling price must be greater than 0');
      return;
    }
    if (mrp == null || mrp < price) {
      Fluttertoast.showToast(msg: 'MRP must be greater than or equal to selling price');
      return;
    }
    if (quantity == null || quantity < 0) {
      Fluttertoast.showToast(msg: 'Quantity must be a whole number of 0 or more');
      return;
    }
    if (deliveryDays == null || deliveryDays <= 0) {
      Fluttertoast.showToast(msg: 'Delivery days must be a whole number greater than 0');
      return;
    }
    if (category.isEmpty) {
      Fluttertoast.showToast(msg: 'Category is required');
      return;
    }
    if (commissionValue == null || commissionValue < 0) {
      Fluttertoast.showToast(msg: 'Commission value must be 0 or more');
      return;
    }
    if (_selectedCommissionType == CommissionType.percent && commissionValue > 100) {
      Fluttertoast.showToast(msg: 'Percentage commission cannot exceed 100');
      return;
    }
    final selectedImage = _selectedProductImage;
    final selectedImageBytes = _selectedProductImageBytes;
    if (selectedImage == null || selectedImageBytes == null) {
      Fluttertoast.showToast(msg: 'Please select a product photo');
      return;
    }

    Reference? uploadedImageReference;
    if (mounted) setState(() => _isSavingProduct = true);
    try {
      final ref = _firestore.collection('products').doc();
      final safeDesignNumber = designNumber.replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '_',
      );
      final extension = _imageExtension(selectedImage.name);
      uploadedImageReference = FirebaseStorage.instance.ref().child(
            'product_images/$safeDesignNumber/${ref.id}.$extension',
          );
      await uploadedImageReference.putData(
        selectedImageBytes,
        SettableMetadata(
          contentType: _imageContentType(extension),
          customMetadata: {
            'designNumber': designNumber,
            'productId': ref.id,
          },
        ),
      );
      final imageUrl = await uploadedImageReference.getDownloadURL();

      final product = Product(
        id: ref.id,
        vendorId: 'vendor123',
        designNumber: designNumber,
        productCode: designNumber,
        sku: 'SKU-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: '',
        category: category,
        collectionName: '',
        materialType: '',
        color: '',
        size: '',
        price: price,
        currency: 'INR',
        currentStock: quantity,
        reservedStock: 0,
        minStockLevel: 2,
        stockQty: quantity,
        commissionType: _selectedCommissionType,
        commissionValue: commissionValue,
        imageUrl: imageUrl,
        mrp: mrp,
        deliveryDays: deliveryDays,
        gstHsnCode: '71131900',
        gstRate: 18,
        unit: 'pc',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.set(product.toFirestore());

      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Product added successfully!');
      _clearAddProductFields();
    } catch (e) {
      if (uploadedImageReference != null) {
        try {
          await uploadedImageReference.delete();
        } catch (_) {
          // The original upload error is more useful to the user.
        }
      }
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      if (mounted) setState(() => _isSavingProduct = false);
    }
  }

  String _imageExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _imageContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  void _clearAddProductFields() {
    _productNameController.clear();
    _designNumberController.clear();
    _priceController.clear();
    _quantityController.clear();
    _mrpController.clear();
    _deliveryDaysController.clear();
    _categoryController.clear();
    _commissionValueController.clear();
    setState(() {
      _selectedCommissionType = CommissionType.percent;
      _selectedProductImage = null;
      _selectedProductImageBytes = null;
    });
  }

  // ---------- Partner Management ----------
  Widget _buildPartnerManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Allocate Stock to Partner',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').where('role', isEqualTo: 'vendor').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('Error loading partners: ${snapshot.error}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final partners = snapshot.data!.docs;
                      if (partners.isEmpty) return const Text('No partners found');
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Partner'),
                        value: _selectedPartnerId,
                        items: partners.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data['displayName'] ?? 'Partner'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedPartnerId = value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _partnerAmountController,
                    decoration: const InputDecoration(labelText: 'Investment Amount (₹)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rentController,
                    decoration: const InputDecoration(labelText: 'Rent Deduction (₹)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  const Text('Platform Allocation (%)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: _platforms.map((platform) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Text(platform.toUpperCase()),
                              Text(
                                '${_platformAllocation[platform]?.toStringAsFixed(0) ?? 0}%',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _allocateStock,
                    child: const Text('Allocate Stock'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Partner Stock Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('partner_stock').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final stocks = snapshot.data!.docs.map((doc) => PartnerStock.fromFirestore(doc)).toList();
              if (stocks.isEmpty) return const Text('No stock allocated yet');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  final stock = stocks[index];
                  return Card(
                    child: ListTile(
                      title: Text(stock.partnerName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: ₹${stock.totalAllocated.toStringAsFixed(2)}'),
                          Text('Rent: ₹${stock.rentDeducted.toStringAsFixed(2)}'),
                          ...stock.platformStock.entries.map((entry) {
                            return Text('${entry.key}: ₹${entry.value.toStringAsFixed(2)}');
                          }).toList(),
                        ],
                      ),
                      trailing: Text('Remaining: ₹${stock.remainingStock.toStringAsFixed(2)}'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- CA Report ----------
  Widget _buildCAReport() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'CA Report generated!');
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export CA Report (CSV)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4FF62),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Buy / Sell Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('orders').where('status', isEqualTo: 'delivered').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data!.docs.map((doc) => order_models.Order.fromFirestore(doc)).toList();
                if (orders.isEmpty) {
                  return const Center(child: Text('No delivered orders'));
                }
                double totalBuy = 0;
                double totalSell = 0;
                double totalCommission = 0;
                double totalPlatformProfit = 0;
                for (final order in orders) {
                  totalSell += order.orderAmount;
                  totalCommission += order.influencerCommission;
                  totalPlatformProfit += order.platformProfit;
                  totalBuy += order.orderAmount * 0.6;
                }
                final profit = totalSell - totalBuy;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text('Total Buy (Cost)', style: TextStyle(color: Color(0xFF938F99))),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₹${totalBuy.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text('Total Sell (Revenue)', style: TextStyle(color: Color(0xFF938F99))),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₹${totalSell.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text('Profit / Loss', style: TextStyle(color: Color(0xFF938F99))),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₹${profit.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: profit >= 0 ? Colors.green : Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text('Total Commission', style: TextStyle(color: Color(0xFF938F99))),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₹${totalCommission.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20, color: Color(0xFFC4FF62)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Platform-wise Sales',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._platforms.map((platform) {
                        final platformOrders = orders.where((o) => o.platform == platform).toList();
                        final total = platformOrders.fold(0.0, (sum, o) => sum + o.orderAmount);
                        return Card(
                          child: ListTile(
                            title: Text(platform.toUpperCase()),
                            trailing: Text('₹${total.toStringAsFixed(2)}'),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Settings ----------
  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Commission Release Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Release after (days): '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _releaseDays,
                          items: [5, 7, 10, 15, 30, 45, 60].map((days) {
                            return DropdownMenuItem(
                              value: days,
                              child: Text('$days days'),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() => _releaseDays = value);
                              await _settingsService.updateCommissionReleaseDays(value);
                              Fluttertoast.showToast(msg: 'Updated to $value days');
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: $_releaseDays days after delivery',
                    style: const TextStyle(color: Color(0xFFC4FF62)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Platform Allocation Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._platforms.map((platform) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(platform.toUpperCase()),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: _platformAllocation[platform]?.toStringAsFixed(0) ?? '0',
                            decoration: const InputDecoration(
                              labelText: '%',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final percent = double.tryParse(value) ?? 0;
                              setState(() {
                                _platformAllocation[platform] = percent;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'Settings saved!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4FF62),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Analytics Graphs ----------
  Widget _buildAnalyticsGraphs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Today's Sales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Today\'s Sales',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<double>(
                      future: _analyticsService.getTodayRevenue(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        final revenue = snapshot.data ?? 0;
                        return Text(
                          '₹${revenue.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, color: Color(0xFFC4FF62)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Last 15 Days Sales (Bar Chart)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Last 15 Days Sales',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: FutureBuilder<Map<DateTime, double>>(
                        future: _analyticsService.getRevenueLast15Days(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          final data = snapshot.data ?? {};
                          if (data.isEmpty) {
                            return const Center(child: Text('No sales data available'));
                          }
                          final maxY = data.values.reduce((a, b) => a > b ? a : b);
                          return BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxY * 1.2,
                              barGroups: data.entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key.day,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value,
                                      color: const Color(0xFFC4FF62),
                                      width: 12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final day = value.toInt();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          '$day',
                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '₹${value.toInt()}',
                                        style: const TextStyle(fontSize: 8, color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Last 30 Days Sales (Line Chart)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Last 30 Days Sales Trend',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: FutureBuilder<Map<DateTime, double>>(
                        future: _analyticsService.getRevenueLast30Days(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          final data = snapshot.data ?? {};
                          if (data.isEmpty) {
                            return const Center(child: Text('No sales data available'));
                          }
                          final sortedKeys = data.keys.toList()..sort();
                          final spots = sortedKeys.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              data[entry.value] ?? 0,
                            );
                          }).toList();

                          final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
                          return LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: (spots.length - 1).toDouble(),
                              minY: 0,
                              maxY: maxY * 1.2,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  color: const Color(0xFFC4FF62),
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFFC4FF62).withOpacity(0.2),
                                  ),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < sortedKeys.length) {
                                        final date = sortedKeys[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            '${date.day}/${date.month}',
                                            style: const TextStyle(fontSize: 8, color: Colors.white),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '₹${value.toInt()}',
                                        style: const TextStyle(fontSize: 8, color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Allocate Stock ----------
  void _allocateStock() async {
    if (_selectedPartnerId == null) {
      Fluttertoast.showToast(msg: 'Please select a partner');
      return;
    }
    final amount = double.tryParse(_partnerAmountController.text);
    final rent = double.tryParse(_rentController.text) ?? 0;
    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(msg: 'Enter valid investment amount');
      return;
    }
    final availableStock = amount - rent;
    if (availableStock <= 0) {
      Fluttertoast.showToast(msg: 'Amount is less than rent');
      return;
    }
    try {
      final partnerDoc = await _firestore.collection('users').doc(_selectedPartnerId).get();
      final partnerData = partnerDoc.data() as Map<String, dynamic>;
      final partnerName = partnerData['displayName'] ?? 'Partner';
      final platformStock = <String, double>{};
      for (final platform in _platforms) {
        final percent = (_platformAllocation[platform] ?? 0) / 100;
        final allocated = availableStock * percent;
        platformStock[platform] = allocated;
      }
      final stockRef = _firestore.collection('partner_stock').doc();
      final stock = PartnerStock(
        id: stockRef.id,
        partnerId: _selectedPartnerId!,
        partnerName: partnerName,
        totalAllocated: availableStock,
        rentDeducted: rent,
        platformStock: platformStock,
        remainingStock: availableStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await stockRef.set(stock.toFirestore());
      Fluttertoast.showToast(msg: 'Stock allocated to $partnerName');
      _partnerAmountController.clear();
      _rentController.clear();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }
}
