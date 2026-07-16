import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- IMPORT ADD
import '../../services/image_analysis_service.dart';
import '../../services/bill_generation_service.dart';
import '../../models/bill_model.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  String? _vendorId;
  Map<String, dynamic>? _stockData;
  File? _selectedImage;
  bool _isProcessing = false;
  String? _analysisResult;
  BillModel? _generatedBill;

  final ImagePicker _picker = ImagePicker();
  final ImageAnalysisService _analysisService = ImageAnalysisService();
  final BillGenerationService _billService = BillGenerationService();

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _vendorId = user.uid;
    });
    _fetchStockData();
  }

  void _fetchStockData() {
    if (_vendorId == null) return;
    FirebaseFirestore.instance
        .collection('partner_stock')
        .where('partnerId', isEqualTo: _vendorId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _stockData = snapshot.docs.first.data();
        });
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _analysisResult = null;
          _generatedBill = null;
        });
        await _analyzeImage();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error picking image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _analysisResult = 'Analyzing image...';
    });

    try {
      final result = await _analysisService.analyzeImage(_selectedImage!);
      setState(() {
        _analysisResult = result;
        _isProcessing = false;
      });
      await _generateBill(result);
    } catch (e) {
      setState(() {
        _analysisResult = 'Analysis failed: $e';
        _isProcessing = false;
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _generateBill(String analysisResult) async {
    try {
      final bill = await _billService.generateBillFromAnalysis(analysisResult);
      setState(() {
        _generatedBill = bill;
      });
      Fluttertoast.showToast(msg: 'Bill generated successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Bill generation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_stockData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Total Stock',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_stockData!['totalAllocated']?.toStringAsFixed(2) ?? 0}',
                        style: const TextStyle(fontSize: 24, color: Color(0xFFC4FF62)),
                      ),
                      Text(
                        'Remaining: ₹${_stockData!['remainingStock']?.toStringAsFixed(2) ?? 0}',
                        style: const TextStyle(color: Color(0xFF938F99)),
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
                  children: [
                    const Text(
                      'Upload Image for Auto Bill',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tap to upload image', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isProcessing) const CircularProgressIndicator(),
                    if (_analysisResult != null && !_isProcessing) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Analysis Result:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_analysisResult!),
                          ],
                        ),
                      ),
                    ],
                    if (_generatedBill != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '✅ Bill Generated',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const SizedBox(height: 4),
                            Text('Bill #: ${_generatedBill!.billNumber}'),
                            Text('Amount: ₹${_generatedBill!.amount.toStringAsFixed(2)}'),
                            const SizedBox(height: 4),
                            ..._generatedBill!.items.map((item) {
                              return Text('• ${item.name} x${item.quantity} = ₹${(item.price * item.quantity).toStringAsFixed(2)}');
                            }).toList(),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Fluttertoast.showToast(msg: 'PDF download coming soon!');
                              },
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Download PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC4FF62),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}