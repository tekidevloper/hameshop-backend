import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/address_model.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final List<AddressModel> _addresses = [
    AddressModel(
      id: '1',
      fullName: 'John Doe',
      phoneNumber: '+251911223344',
      street: 'Bole Road, House 123',
      city: 'Addis Ababa',
      region: 'Addis Ababa',
      postalCode: '1000',
      isDefault: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Addresses'),
        centerTitle: true,
      ),
      body: _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No address saved', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddAddressDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Address'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                    ),
                    title: Row(
                      children: [
                        Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Default', style: TextStyle(fontSize: 10, color: Colors.green)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(address.street),
                        Text('${address.city}, ${address.region}'),
                        Text(address.phoneNumber, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          setState(() => _addresses.removeAt(index));
                        }
                      },
                    ),
                    isThreeLine: true,
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Address'),
        content: const SingleChildScrollView(
          child: Text('Address form coming soon...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address feature coming soon')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
