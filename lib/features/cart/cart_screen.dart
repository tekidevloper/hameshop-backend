import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/cart_service.dart';
import '../../models/cart_model.dart';
import '../checkout/checkout_screen.dart';
import '../widgets/ui_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Scaffold(
      appBar: AppBar(
        title: Text('shopping_cart'.tr()),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartService.cartItems,
        builder: (context, items, child) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('your_cart_is_empty'.tr(), style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('add_products_to_get_started'.tr(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ProductImage(
                                imageUrl: item.product.imageUrl,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.product.price.toStringAsFixed(2)} ETB',
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cartService.updateQuantity(item.product, item.quantity - 1);
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                        iconSize: 28,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          cartService.updateQuantity(item.product, item.quantity + 1);
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                        iconSize: 28,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => cartService.removeFromCart(item.product),
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${item.totalPrice.toStringAsFixed(2)} ETB',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('total_items'.tr(), style: const TextStyle(fontSize: 16)),
                        Text('${cartService.itemCount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('total_price'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${cartService.totalPrice.toStringAsFixed(2)} ETB',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _sendOrderToTelegram(context, items, cartService.totalPrice),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.send),
                            label: Text('telegram'.tr(), style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendOrderToTelegram(BuildContext context, List<CartItem> items, double total) async {
    // Build order message
    String message = '🛒 *New Order*\n\n';
    
    for (var item in items) {
      message += '• ${item.product.name}\n';
      message += '  Qty: ${item.quantity} × ${item.product.price.toStringAsFixed(2)} ETB\n';
      message += '  Subtotal: ${item.totalPrice.toStringAsFixed(2)} ETB\n\n';
    }
    
    message += '━━━━━━━━━━━━━━━━\n';
    message += '*Total: ${total.toStringAsFixed(2)} ETB*\n\n';
    message += 'Please confirm this order!';

    // Encode message for URL
    final encodedMessage = Uri.encodeComponent(message);
    final telegramUrl = 'https://t.me/Hameee40?text=$encodedMessage';

    try {
      final uri = Uri.parse(telegramUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening Telegram...')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening Telegram: $e')),
        );
      }
    }
  }
}
