import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/wishlist_service.dart';
import '../product/product_detail_screen.dart';
import '../widgets/ui_widgets.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.toLowerCase().replaceAll(' ', '_').tr()),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: productService.products,
        builder: (context, allProducts, child) {
          final categoryProducts = allProducts
              .where((p) => p.category.toLowerCase() == category.toLowerCase())
              .toList();

          if (categoryProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'no_results_found'.tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categoryProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, categoryProducts[index])
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .scale(begin: const Offset(0.9, 0.9));
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final wishlistService = WishlistService();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                product: product,
                heroTag: 'category_${product.id}',
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'category_${product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: ProductImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ValueListenableBuilder<List<Product>>(
                      valueListenable: wishlistService.wishlist,
                      builder: (context, wishlist, child) {
                        final isInWishlist = wishlistService.isInWishlist(product);
                        return InkWell(
                          onTap: () => wishlistService.toggleWishlist(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isInWishlist ? Icons.favorite : Icons.favorite_border,
                              color: isInWishlist ? Colors.red : Colors.grey,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${product.price} ETB',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
}
