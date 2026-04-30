import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/wishlist_service.dart';
import '../../services/cart_service.dart';
import '../../models/product.dart';
import '../product/product_detail_screen.dart';
import '../widgets/ui_widgets.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistService = WishlistService();
    final cartService = CartService();

    return Scaffold(
      appBar: AppBar(
        title: Text('wishlist'.tr()),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: wishlistService.wishlist,
        builder: (context, products, child) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('no_favorites_yet'.tr(), style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('add_products_to_wishlist'.tr(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: ProductImage(
                              imageUrl: product.imageUrl,
                              height: 150,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () => wishlistService.removeFromWishlist(product),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 18, color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.price} ETB',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    cartService.addToCart(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${product.name} added to cart')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.shopping_cart, size: 16),
                                  label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (100 * index).ms).scale(begin: const Offset(0.9, 0.9));
            },
          );
        },
      ),
    );
  }
}
