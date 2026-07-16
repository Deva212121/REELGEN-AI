import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart' as order_models;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'Products'; // Products, Orders, Users
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedPartner;
  String? _selectedInfluencer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF130F26),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[800],
                filled: true,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.grey[900],
            child: Row(
              children: [
                _buildTab('Products'),
                _buildTab('Orders'),
                _buildTab('Users'),
              ],
            ),
          ),
          // Filter Row
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterDropdown(),
                  _buildDateFilter(),
                  _buildPartnerFilter(),
                  _buildInfluencerFilter(),
                ],
              ),
            ),
          ),
          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFC4FF62) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFC4FF62) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButton<String>(
        value: _selectedStatus,
        hint: const Text('Status'),
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        items: ['Pending', 'Confirmed', 'Packed', 'Shipped', 'Delivered', 'Cancelled'].map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStatus = value;
          });
        },
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _startDate = date;
                });
              }
            },
          ),
          if (_startDate != null)
            Text(
              '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
              style: const TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildPartnerFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'vendor')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final partners = snapshot.data!.docs;
          return DropdownButton<String>(
            value: _selectedPartner,
            hint: const Text('Partner'),
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            items: partners.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return DropdownMenuItem(
                value: doc.id,
                child: Text(data['displayName'] ?? 'Partner'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPartner = value;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildInfluencerFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'influencer')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final influencers = snapshot.data!.docs;
          return DropdownButton<String>(
            value: _selectedInfluencer,
            hint: const Text('Influencer'),
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            items: influencers.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return DropdownMenuItem(
                value: doc.id,
                child: Text(data['displayName'] ?? 'Influencer'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedInfluencer = value;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildResults() {
    final query = _searchController.text.trim().toLowerCase();

    if (_selectedTab == 'Products') {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!.docs
              .map((doc) => Product.fromFirestore(doc))
              .where((p) => p.name.toLowerCase().contains(query) || p.designNumber.toLowerCase().contains(query))
              .toList();
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('Design: ${product.designNumber} | ₹${product.price}'),
                  trailing: Text('Stock: ${product.currentStock}'),
                ),
              );
            },
          );
        },
      );
    } else if (_selectedTab == 'Orders') {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var orders = snapshot.data!.docs
              .map((doc) => order_models.Order.fromFirestore(doc))
              .where((o) =>
                  o.orderNumber.contains(query) ||
                  o.customerName.toLowerCase().contains(query))
              .toList();

          // Apply filters
          if (_selectedStatus != null) {
            orders = orders.where((o) => o.status.name == _selectedStatus!.toLowerCase()).toList();
          }
          if (_selectedPartner != null) {
            orders = orders.where((o) => o.vendorId == _selectedPartner).toList();
          }
          if (_selectedInfluencer != null) {
            orders = orders.where((o) => o.influencerId == _selectedInfluencer).toList();
          }
          if (_startDate != null) {
            orders = orders.where((o) => o.createdAt.isAfter(_startDate!)).toList();
          }

          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text('Order #${order.orderNumber}'),
                  subtitle: Text('${order.customerName} | ${order.status.name}'),
                  trailing: Text('₹${order.orderAmount.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      );
    } else {
      // Users
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .where((u) =>
                  (u['displayName'] ?? '').toString().toLowerCase().contains(query) ||
                  (u['email'] ?? '').toString().toLowerCase().contains(query))
              .toList();
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(user['displayName'] ?? 'User'),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Text(user['role'] ?? ''),
                ),
              );
            },
          );
        },
      );
    }
  }
}