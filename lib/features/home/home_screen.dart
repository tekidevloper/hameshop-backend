import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product.dart';
import '../../models/cart_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/wishlist_service.dart';
import '../../services/cart_service.dart';
import '../product/product_detail_screen.dart';
import '../widgets/app_drawer.dart';
import '../search/search_screen.dart';
import '../cart/cart_screen.dart';
import '../notifications/notifications_screen.dart';
import '../categories/categories_screen.dart';
import '../categories/category_products_screen.dart';
import '../widgets/ui_widgets.dart';
import '../../services/recently_viewed_service.dart';
import '../../services/product_service.dart';
import '../../services/banner_service.dart';
import '../../models/banner_model.dart';
import '../support/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();
    final cartService = CartService();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'HameShop',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
            },
          ),
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: cartService.cartItems,
            builder: (context, items, child) {
              final itemCount = items.fold(0, (sum, item) => sum + item.quantity);
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().scale(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AIChatScreen()));
        },
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: Text(
          'ai_chat'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ).animate().scale(delay: 1.seconds, duration: 500.ms, curve: Curves.easeOutBack).shimmer(delay: 2.seconds, duration: 2.seconds),

      body: RefreshIndicator(
        onRefresh: () async {
          await productService.fetchProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banners Carousel
              ValueListenableBuilder<List<BannerModel>>(
                valueListenable: BannerService().banners,
                builder: (context, banners, child) {
                  if (banners.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      BannerService().fetchBanners();
                    });
                  }

                  final displayBanners = banners.isNotEmpty
                      ? banners
                      : MockDataService.getBanners().map((url) => BannerModel(id: '', imageUrl: url)).toList();

                  if (displayBanners.isEmpty) return const SizedBox.shrink();

                  return CarouselSlider.builder(
                    itemCount: displayBanners.length,
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      aspectRatio: 2.0,
                      initialPage: 0,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return _buildBannerItem(displayBanners[index]);
                    },
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.05, end: 0);
                },
              ),

              const SizedBox(height: 16),

              // Categories Browse
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'categories'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
                      },
                      child: Text('see_all'.tr()),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final categories = ['Electronics', 'Fashion', 'Sports', 'Books', 'Toys'];
                    final icons = [Icons.devices, Icons.checkroom, Icons.sports_soccer, Icons.book, Icons.toys];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsScreen(category: categories[index]),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icons[index], color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categories[index].toLowerCase().tr(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (100 * index).ms).scale(curve: Curves.easeOutBack);

                  },
                ),
              ),

              // Flash Deals
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[700]!, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'flash_sale'.tr(),
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Up to 50% OFF',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '02:14:55',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().shimmer(duration: 3.seconds, delay: 1.seconds),

              // AI Suggestion Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ai_suggestion'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              // Recently Viewed Section
              ValueListenableBuilder<List<Product>>(
                valueListenable: RecentlyViewedService().recentlyViewed,
                builder: (context, viewedProducts, child) {
                  if (viewedProducts.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'recently_viewed'.tr(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: viewedProducts.length,
                          itemBuilder: (context, index) {
                            final product = viewedProducts[index];
                            return _buildProductCard(context, product, isHorizontal: true, heroTagPrefix: 'recently_')
                                .animate()
                                .fadeIn(delay: (200 * index).ms)
                                .slideX(begin: 0.2, end: 0);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              // All Products Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'products'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ValueListenableBuilder<List<Product>>(
                valueListenable: productService.products,
                builder: (context, products, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: productService.isLoading,
                    builder: (context, isLoading, child) {
                      if (isLoading && products.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ).animate().fadeIn();
                      }

                      if (products.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'no_results_found'.tr(),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'add_products_to_get_started'.tr(),
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn();
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(context, products[index], heroTagPrefix: 'grid_')
                              .animate()
                              .fadeIn(delay: (100 * index).ms)
                              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack);
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ProductImage(
          imageUrl: banner.imageUrl,
          width: double.infinity,
          height: double.infinity,
          placeholder: Image.asset('assets/admin.jpg', fit: BoxFit.cover, width: double.infinity),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, {bool isHorizontal = false, String? heroTagPrefix}) {
    final wishlistService = WishlistService();

    return Container(
      width: isHorizontal ? 150 : null,
      margin: isHorizontal ? const EdgeInsets.symmetric(horizontal: 6) : null,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                heroTag: heroTagPrefix != null ? '$heroTagPrefix${product.id}' : product.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: heroTagPrefix != null ? '$heroTagPrefix${product.id}' : product.id,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: ProductImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ValueListenableBuilder<List<Product>>(
                      valueListenable: wishlistService.wishlist,
                      builder: (context, wishlist, child) {
                        final isInWishlist = wishlistService.isInWishlist(product);
                        return InkWell(
                          onTap: () => wishlistService.toggleWishlist(product),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isInWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isInWishlist ? Colors.red : Colors.grey[400],
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Row(
                      children: [
                        StarRating(rating: product.rating, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    Text(
                      '${product.price} ETB',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
