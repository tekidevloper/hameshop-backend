import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _sortBy = 'popular';
  final Set<String> _selectedCategories = {};

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Toys',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter & Sort'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _priceRange = const RangeValues(0, 10000);
                _selectedCategories.clear();
                _sortBy = 'popular';
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  _buildSectionTitle('Categories'),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle('Price Range'),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    labels: RangeLabels(
                      '${_priceRange.start.round()} ETB',
                      '${_priceRange.end.round()} ETB',
                    ),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_priceRange.start.round()} ETB'),
                      Text('${_priceRange.end.round()} ETB'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sort By
                  _buildSectionTitle('Sort By'),
                  RadioListTile(
                    title: const Text('Most Popular'),
                    value: 'popular',
                    groupValue: _sortBy,
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                  RadioListTile(
                    title: const Text('Price: Low to High'),
                    value: 'price_asc',
                    groupValue: _sortBy,
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                  RadioListTile(
                    title: const Text('Price: High to Low'),
                    value: 'price_desc',
                    groupValue: _sortBy,
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                  RadioListTile(
                    title: const Text('Highest Rated'),
                    value: 'rating',
                    groupValue: _sortBy,
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                  RadioListTile(
                    title: const Text('Newest'),
                    value: 'newest',
                    groupValue: _sortBy,
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'priceRange': _priceRange,
                    'categories': _selectedCategories.toList(),
                    'sortBy': _sortBy,
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
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
}
