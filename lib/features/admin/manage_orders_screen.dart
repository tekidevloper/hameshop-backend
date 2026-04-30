import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('manage_orders'.tr())),
      body: ValueListenableBuilder<List<OrderModel>>(
        valueListenable: _orderService.orders,
        builder: (context, orders, child) {
          if (orders.isEmpty) {
            return Center(child: Text('no_orders_found'.tr()));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
                    child: Icon(Icons.shopping_bag, color: _getStatusColor(order.status)),
                  ),
                  title: Text('${'order_id'.tr()}${order.id.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'total'.tr()}: ${order.totalAmount} ETB'),
                      Text('${'customer'.tr()}: ${order.customerName} (${order.customerEmail})', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${'payment'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: order.paymentStatus == 'paid' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  order.paymentStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: order.paymentStatus == 'paid' ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${'update_order_status'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((status) {
                              return ActionChip(
                                label: Text(status.toLowerCase().tr()),
                                backgroundColor: order.status == status ? _getStatusColor(status).withOpacity(0.2) : null,
                                onPressed: () {
                                  _orderService.updateOrderStatus(order.id, status);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text('${'update_payment_status'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ['unpaid', 'paid'].map((status) {
                              return ActionChip(
                                label: Text(status.toUpperCase()),
                                backgroundColor: order.paymentStatus == status ? (status == 'paid' ? Colors.green : Colors.red).withOpacity(0.2) : null,
                                onPressed: () {
                                  _orderService.updatePaymentStatus(order.id, status);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text('${'customer_contact'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${'phone'.tr()}: ${order.phoneNumber ?? 'no_address_provided'.tr()}'),
                          const SizedBox(height: 8),
                          Text('${'shipping_address'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (order.shippingAddress != null)
                            Text(
                              '${order.shippingAddress!['street']}, ${order.shippingAddress!['city']}\n'
                              '${order.shippingAddress!['region']}, ${order.shippingAddress!['postalCode']}\n'
                              'Receiver: ${order.shippingAddress!['fullName']}',
                            )
                          else
                            const Text('No address provided'),
                          const SizedBox(height: 16),
                          const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...order.items.map((item) => Text('• ${item.name} x${item.quantity}')),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
