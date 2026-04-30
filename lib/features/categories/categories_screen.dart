import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Electronics', 'icon': Icons.devices, 'count': 45},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'count': 32},
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'count': 19},
      {'name': 'Books', 'icon': Icons.book, 'count': 67},
      {'name': 'Toys', 'icon': Icons.toys, 'count': 24},
      {'name': 'Beauty', 'icon': Icons.face, 'count': 38},
      {'name': 'Food', 'icon': Icons.restaurant, 'count': 15},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('categories'.tr()),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsScreen(
                      category: category['name'] as String,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category['count']} products',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (100 * index).ms).scale(begin: const Offset(0.9, 0.9));
        },
      ),
    );
  }
}
