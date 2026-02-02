import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/search_state.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<SearchResult> results;
  final String query;
  final SearchResultType type;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.query,
    this.type = SearchResultType.all,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return _buildEmptyResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildResultCard(context, result),
        );
      },
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_getTypeLabel()} found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, SearchResult result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToResult(context, result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: result.imageUrl != null
                      ? Image.network(
                          result.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderIcon(result.type);
                          },
                        )
                      : _buildPlaceholderIcon(result.type),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with highlighted search term
                    RichText(
                      text: _highlightSearchTerm(result.title, query),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (result.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Type badge and additional info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(result.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(result.type),
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Price for products
                        if (result.price != null)
                          Text(
                            '₦${result.price!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    
                    // Rating for products
                    if (result.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < result.rating!.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${result.rating!.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (result.reviewCount != null) ...[
                            Text(
                              ' (${result.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(String type) {
    IconData icon;
    switch (type) {
      case 'product':
        icon = Icons.shopping_bag;
        break;
      case 'category':
        icon = Icons.category;
        break;
      case 'brand':
        icon = Icons.business;
        break;
      default:
        icon = Icons.search;
    }

    return Icon(
      icon,
      size: 40,
      color: Colors.grey,
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'product':
        return Colors.blue;
      case 'category':
        return Colors.green;
      case 'brand':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel() {
    switch (type) {
      case SearchResultType.products:
        return 'products';
      case SearchResultType.categories:
        return 'categories';
      case SearchResultType.brands:
        return 'brands';
      default:
        return 'results';
    }
  }

  TextSpan _highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) {
      return TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerSearchTerm = searchTerm.toLowerCase();
    final index = lowerText.indexOf(lowerSearchTerm);

    if (index == -1) {
      return TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      );
    }

    return TextSpan(
      children: [
        TextSpan(
          text: text.substring(0, index),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: text.substring(index, index + searchTerm.length),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            backgroundColor: Colors.yellow,
          ),
        ),
        TextSpan(
          text: text.substring(index + searchTerm.length),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  void _navigateToResult(BuildContext context, SearchResult result) {
    switch (result.type) {
      case 'product':
        context.push('/product/${result.id}');
        break;
      case 'category':
        context.push('/category/${result.id}');
        break;
      case 'brand':
        context.push('/brand/${result.id}');
        break;
    }
  }
}