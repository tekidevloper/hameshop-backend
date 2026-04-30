import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/product.dart';
import '../../services/payment_service.dart';
import '../../services/cart_service.dart';
import '../../services/recently_viewed_service.dart';
import '../widgets/ui_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/mock_data_service.dart';
import '../../services/review_service.dart';
import '../../models/review_model.dart';
import '../../services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String? heroTag;

  const ProductDetailScreen({super.key, required this.product, this.heroTag});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final CartService _cartService = CartService();
  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    RecentlyViewedService().addProduct(widget.product);
    _reviewsFuture = _reviewService.getProductReviews(widget.product.id);
  }

  void _showAddReviewDialog() {
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setDialogState(() => selectedRating = index + 1.0),
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                    ),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write your experience...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isEmpty) return;
                
                final user = _userService.currentUser.value;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to review')));
                  return;
                }

                final success = await _reviewService.addReview(Review(
                  id: '', // Backend generates UUID
                  userName: user.name,
                  rating: selectedRating,
                  comment: commentController.text,
                  date: DateTime.now(),
                  productId: widget.product.id,
                ));

                if (success) {
                  setState(() {
                    _reviewsFuture = _reviewService.getProductReviews(widget.product.id);
                  });
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review added!')));
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                Share.share('Check out ${widget.product.name} on HameShop! ${widget.product.imageUrl}');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.heroTag ?? widget.product.id,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {},
                ),
                items: widget.product.images.map((url) {
                  return InteractiveViewer(
                    panEnabled: false,
                    clipBehavior: Clip.none,
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: ProductImage(
                      imageUrl: url,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                }).toList(),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Chip(
                          label: Text('In Stock', style: TextStyle(color: Colors.white, fontSize: 10)),
                          backgroundColor: Colors.green,
                          visualDensity: VisualDensity.compact,
                        ),
                        Flexible(
                          child: Text(
                            'SKU: HS-${widget.product.id}00${widget.product.id}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StarRating(rating: widget.product.rating, showRating: true),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${widget.product.reviewCount} reviews)',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${widget.product.price} ETB',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                    const SizedBox(height: 10),
                    Chip(
                      label: Text(widget.product.category),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 20),
                    Text(
                      'description'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 24),

                    // Color Selection
                    if (widget.product.category == 'Fashion' || widget.product.category == 'Electronics') ...[
                      const Text('Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildColorOption(Colors.black, isSelected: true),
                          _buildColorOption(Colors.blue),
                          _buildColorOption(Colors.red),
                          _buildColorOption(Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Size Selection
                    if (widget.product.category == 'Fashion') ...[
                      const Text('Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: ['S', 'M', 'L', 'XL'].map((size) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: size == 'M' ? Theme.of(context).primaryColor : Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: size == 'M' ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: size == 'M' ? Theme.of(context).primaryColor : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Quantity Selector
                    Row(
                      children: [
                        Text('quantity'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 32,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 32,
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _cartService.addToCart(widget.product, quantity: _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added $_quantity ${widget.product.name} to cart'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            icon: const Icon(Icons.shopping_cart),
                            label: Text('add_to_cart'.tr(), style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final totalAmount = widget.product.price * _quantity;
                              PaymentService.initiatePayment(
                                context,
                                totalAmount,
                                productName: '${widget.product.name} (x$_quantity)',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Use a distinct color for Buy Now
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            icon: const Icon(Icons.flash_on),
                            label: const Text('Buy Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms).scale(),

                    const SizedBox(height: 32),
                    
                    // Reviews Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customer Reviews',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _showAddReviewDialog,
                          child: const Text('Write a Review'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Review>>(
                      future: _reviewsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final reviews = snapshot.data ?? [];
                        
                        if (reviews.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('No reviews yet. Be the first to review!')),
                          );
                        }

                        return Column(
                          children: reviews.map((review) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        child: Text(review.userName[0], style: const TextStyle(fontSize: 12)),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      Text(
                                        '${review.date.day}/${review.date.month}/${review.date.year}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  StarRating(rating: review.rating, size: 12),
                                  const SizedBox(height: 4),
                                  Text(
                                    review.comment,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
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

  Widget _buildColorOption(Color color, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
