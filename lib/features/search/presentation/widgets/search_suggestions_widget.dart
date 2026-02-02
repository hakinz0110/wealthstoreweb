import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const SearchSuggestionsWidget({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      {'text': 'iPhone 15', 'trending': true},
      {'text': 'Samsung Galaxy', 'trending': false},
      {'text': 'Nike Air Max', 'trending': true},
      {'text': 'MacBook Pro', 'trending': false},
      {'text': 'PlayStation 5', 'trending': true},
      {'text': 'AirPods Pro', 'trending': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                suggestion['trending'] as bool
                    ? Icons.trending_up
                    : Icons.search,
                color: suggestion['trending'] as bool
                    ? Colors.orange
                    : Colors.grey[600],
              ),
              title: Text(
                suggestion['text'] as String,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: suggestion['trending'] as bool
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    )
                  : null,
              onTap: () => onSuggestionTap(suggestion['text'] as String),
            );
          },
        ),
      ],
    );
  }
}