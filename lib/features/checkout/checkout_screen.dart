import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../models/address_model.dart';
import '../../models/order_model.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  AddressModel? _selectedAddress;
  String _paymentMethod = 'Chapa';

  final List<AddressModel> _addresses = [
    AddressModel(
      id: '1',
      fullName: 'yared',
      phoneNumber: '+251911234567',
      street: '123 Main St',
      city: 'Addis Ababa',
      region: 'Addis Ababa',
      postalCode: '1000',
      isDefault: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddress = _addresses.firstWhere((a) => a.isDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('checkout'.tr()),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: _cartService.cartItems,
        builder: (context, items, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipping Address
                _buildSectionTitle('shipping_address'.tr()),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(_selectedAddress!.fullName),
                    subtitle: Text(
                      '${_selectedAddress!.street}, ${_selectedAddress!.city}\n${_selectedAddress!.phoneNumber}',
                    ),
                    trailing: TextButton(
                      onPressed: () {},
                      child: Text('change'.tr()),
                    ),
                  ),
                ).animate().fadeIn().slideX(begin: -0.2),

                const SizedBox(height: 24),

                // Payment Method
                _buildSectionTitle('payment_method'.tr()),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          'Chapa',
                          'chapa_payment'.tr(),
                          'pay_with_chapa'.tr(),
                          Icons.payment,
                          const Color(0xFF4CAF50),
                        ),
                        const Divider(height: 1, indent: 70),
                        _buildPaymentOption(
                          'Telegram',
                          'telegram_order'.tr(),
                          'order_via_telegram'.tr(),
                          Icons.send,
                          const Color(0xFF2196F3),
                        ),
                        const Divider(height: 1, indent: 70),
                        _buildPaymentOption(
                          'COD',
                          'cash_on_delivery'.tr(),
                          'pay_when_receive'.tr(),
                          Icons.money,
                          const Color(0xFF757575),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                if (_paymentMethod == 'Chapa') ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle('Select Bank'),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final banks = [
                          {'name': 'Chapa', 'index': 0},
                          {'name': 'Telebirr', 'index': 1},
                          {'name': 'CBE', 'index': 2},
                          {'name': 'Awash', 'index': 3},
                          {'name': 'Dashen', 'index': 4},
                        ];
                        return _buildBankIcon(banks[index]['name'] as String, banks[index]['index'] as int);
                      },
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],

                const SizedBox(height: 24),

                // Order Summary
                _buildSectionTitle('order_summary'.tr()),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryRow('subtotal'.tr(), '${_cartService.totalPrice.toStringAsFixed(2)} ETB'),
                        const SizedBox(height: 8),
                        _buildSummaryRow('delivery_fee'.tr(), '50.00 ETB'),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'total'.tr(),
                          '${(_cartService.totalPrice + 50).toStringAsFixed(2)} ETB',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                const SizedBox(height: 32),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final userService = UserService();
                      final user = userService.currentUser.value;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('login_to_place_order'.tr())),
                        );
                        return;
                      }

                      final order = OrderModel(
                        id: '', // Server will generate
                        items: _cartService.cartItems.value
                            .map((item) => OrderItem(
                                  productName: item.product.name,
                                  productImage: item.product.imageUrl,
                                  quantity: item.quantity,
                                  price: item.product.price,
                                ))
                            .toList(),
                        total: _cartService.totalPrice + 50,
                        date: DateTime.now(),
                        status: 'Pending',
                        paymentStatus: 'Unpaid',
                        customerName: user.name,
                        customerEmail: user.email,
                        phoneNumber: _selectedAddress?.phoneNumber,
                        shippingAddress: _selectedAddress?.toJson(),
                      );

                      final success = await OrderService().createOrder(order);
                      if (success) {
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderConfirmationScreen(
                                orderNumber: 'Success',
                                total: _cartService.totalPrice + 50,
                              ),
                            ),
                          );
                          _cartService.clearCart();
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('request_failed'.tr())),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('place_order'.tr(), style: const TextStyle(fontSize: 18)),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon, Color color) {
    return RadioListTile(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (val) => setState(() => _paymentMethod = val!),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBankIcon(String name, int index) {
    // The generated image contains 5 logos in a row
    // Chapa, Telebirr, CBE, Awash, Dashen
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                'assets/bank_logos.png',
                fit: BoxFit.fitHeight,
                alignment: Alignment(
                  -1.0 + (index * 0.5), 
                  0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }
}

