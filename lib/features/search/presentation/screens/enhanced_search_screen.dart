import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_filters_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/search_suggestions_widget.dart';
import '../widgets/recent_searches_widget.dart';
import '../../domain/search_notifier.dart';

class EnhancedSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const EnhancedSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends ConsumerState<EnhancedSearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _tabController = TabController(length: 4, vsync: this);
    
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchNotifierProvider.notifier).search(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: SearchBarWidget(
          controller: _searchController,
          onSearch: (query) {
            ref.read(searchNotifierProvider.notifier).search(query);
          },
          onClear: () {
            _searchController.clear();
            ref.read(searchNotifierProvider.notifier).clearSearch();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: _showFilters ? AppColors.primary : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
        bottom: searchState.hasResults
            ? TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'All (${searchState.totalResults})'),
                  Tab(text: 'Products (${searchState.products.length})'),
                  Tab(text: 'Categories (${searchState.categories.length})'),
                  Tab(text: 'Brands (${searchState.brands.length})'),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          // Filters Section
          if (_showFilters)
            SearchFiltersWidget(
              onFiltersChanged: (filters) {
                ref.read(searchNotifierProvider.notifier).applyFilters(filters);
              },
            ),
          
          // Search Content
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.hasResults
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          SearchResultsWidget(
                            results: searchState.allResults,
                            query: searchState.query,
                          ),
                          SearchResultsWidget(
                            results: searchState.products,
                            query: searchState.query,
                            type: SearchResultType.products,
                          ),
                          SearchResultsWidget(
                            results: searchState.categories,
                            query: searchState.query,
                            type: SearchResultType.categories,
                          ),
                          SearchResultsWidget(
                            results: searchState.brands,
                            query: searchState.query,
                            type: SearchResultType.brands,
                          ),
                        ],
                      )
                    : searchState.query.isEmpty
                        ? _buildEmptySearchState()
                        : _buildNoResultsState(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          const RecentSearchesWidget(),
          
          const SizedBox(height: 24),
          
          // Search Suggestions
          SearchSuggestionsWidget(
            onSuggestionTap: (suggestion) {
              _searchController.text = suggestion;
              ref.read(searchNotifierProvider.notifier).search(suggestion);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Popular Categories
          _buildPopularCategories(),
          
          const SizedBox(height: 24),
          
          // Trending Products
          _buildTrendingProducts(),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords or check your spelling',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                ref.read(searchNotifierProvider.notifier).clearSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    final categories = [
      {'name': 'Electronics', 'icon': Icons.devices, 'count': 245},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'count': 189},
      {'name': 'Home & Garden', 'icon': Icons.home, 'count': 156},
      {'name': 'Sports', 'icon': Icons.sports, 'count': 98},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              child: InkWell(
                onTap: () {
                  _searchController.text = category['name'] as String;
                  ref.read(searchNotifierProvider.notifier).search(category['name'] as String);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${category['count']} items',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendingProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trending Now',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/products?filter=trending');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // Navigate to product details
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Product ${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}