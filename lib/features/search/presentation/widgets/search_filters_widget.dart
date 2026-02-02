import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/search_state.dart';

class SearchFiltersWidget extends StatefulWidget {
  final Function(SearchFilters) onFiltersChanged;

  const SearchFiltersWidget({
    super.key,
    required this.onFiltersChanged,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  List<String> _selectedCategories = [];
  List<String> _selectedBrands = [];
  double _minPrice = 0;
  double _maxPrice = 1000;
  double _minRating = 0;
  String _sortBy = 'relevance';
  bool _inStock = false;
  bool _onSale = false;

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Toys',
  ];

  final List<String> _brands = [
    'Apple',
    'Samsung',
    'Nike',
    'Adidas',
    'Sony',
    'LG',
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'relevance', 'label': 'Relevance'},
    {'value': 'price_low', 'label': 'Price: Low to High'},
    {'value': 'price_high', 'label': 'Price: High to Low'},
    {'value': 'rating', 'label': 'Customer Rating'},
    {'value': 'newest', 'label': 'Newest First'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  _buildFilterSection(
                    title: 'Sort By',
                    child: Wrap(
                      spacing: 8,
                      children: _sortOptions.map((option) {
                        final isSelected = _sortBy == option['value'];
                        return FilterChip(
                          label: Text(option['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _sortBy = option['value']!;
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Categories
                  _buildFilterSection(
                    title: 'Categories',
                    child: Wrap(
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
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Brands
                  _buildFilterSection(
                    title: 'Brands',
                    child: Wrap(
                      spacing: 8,
                      children: _brands.map((brand) {
                        final isSelected = _selectedBrands.contains(brand);
                        return FilterChip(
                          label: Text(brand),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedBrands.add(brand);
                              } else {
                                _selectedBrands.remove(brand);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Price Range
                  _buildFilterSection(
                    title: 'Price Range',
                    child: Column(
                      children: [
                        RangeSlider(
                          values: RangeValues(_minPrice, _maxPrice),
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          labels: RangeLabels(
                            '\$${_minPrice.round()}',
                            '\$${_maxPrice.round()}',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _minPrice = values.start;
                              _maxPrice = values.end;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${_minPrice.round()}'),
                            Text('\$${_maxPrice.round()}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Rating
                  _buildFilterSection(
                    title: 'Minimum Rating',
                    child: Column(
                      children: [
                        Slider(
                          value: _minRating,
                          min: 0,
                          max: 5,
                          divisions: 5,
                          label: '${_minRating.round()} stars',
                          onChanged: (value) {
                            setState(() {
                              _minRating = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Any'),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < _minRating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Additional Filters
                  _buildFilterSection(
                    title: 'Additional Filters',
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text('In Stock Only'),
                          value: _inStock,
                          onChanged: (value) {
                            setState(() {
                              _inStock = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('On Sale'),
                          value: _onSale,
                          onChanged: (value) {
                            setState(() {
                              _onSale = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedBrands.clear();
      _minPrice = 0;
      _maxPrice = 1000;
      _minRating = 0;
      _sortBy = 'relevance';
      _inStock = false;
      _onSale = false;
    });
  }

  void _applyFilters() {
    final filters = SearchFilters(
      categories: _selectedCategories,
      brands: _selectedBrands,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 1000 ? _maxPrice : null,
      minRating: _minRating > 0 ? _minRating : null,
      sortBy: _sortBy,
      inStock: _inStock,
      onSale: _onSale,
    );
    
    widget.onFiltersChanged(filters);
  }
}