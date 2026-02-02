import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/currency_utils.dart';
import 'package:wealth_app/features/products/domain/product_filter_state.dart';
import 'package:wealth_app/features/products/domain/product_notifier.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';

class ProductFilterBottomSheet extends ConsumerStatefulWidget {
  final double minPrice;
  final double maxPrice;
  final double currentMin;
  final double currentMax;
  final ProductSortOption sortOption;

  const ProductFilterBottomSheet({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.currentMin,
    required this.currentMax,
    required this.sortOption,
  });

  @override
  ConsumerState<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends ConsumerState<ProductFilterBottomSheet> {
  late double _currentMinPrice;
  late double _currentMaxPrice;
  late ProductSortOption _selectedSortOption;

  @override
  void initState() {
    super.initState();
    _currentMinPrice = widget.currentMin;
    _currentMaxPrice = widget.currentMax;
    _selectedSortOption = widget.sortOption;
  }

  void _applyFilters() {
    ref.read(productNotifierProvider.notifier).setPriceRange(
      _currentMinPrice,
      _currentMaxPrice,
    );
    
    ref.read(productNotifierProvider.notifier).setSortOption(_selectedSortOption);
    
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _currentMinPrice = widget.minPrice;
      _currentMaxPrice = widget.maxPrice;
      _selectedSortOption = ProductSortOption.newest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Price Range
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(CurrencyUtils.formatPrice(_currentMinPrice)),
              Text(CurrencyUtils.formatPrice(_currentMaxPrice)),
            ],
          ),
          RangeSlider(
            values: RangeValues(_currentMinPrice, _currentMaxPrice),
            min: widget.minPrice,
            max: widget.maxPrice,
            divisions: 100,
            labels: RangeLabels(
              CurrencyUtils.formatPrice(_currentMinPrice),
              CurrencyUtils.formatPrice(_currentMaxPrice),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentMinPrice = values.start;
                _currentMaxPrice = values.end;
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.medium),
          
          // Sort options
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: 8.0,
            children: ProductSortOption.values.map((option) {
              return ChoiceChip(
                label: Text(option.displayName),
                selected: _selectedSortOption == option,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedSortOption = option;
                    });
                  }
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppSpacing.large),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Apply Filters',
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }
}
