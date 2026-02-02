import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/search_notifier.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'Search products, categories...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      widget.onClear();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {});
            _getSuggestions(value);
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              widget.onSearch(value.trim());
              setState(() {
                _showSuggestions = false;
              });
            }
          },
          onTap: () {
            if (widget.controller.text.isNotEmpty) {
              _getSuggestions(widget.controller.text);
            }
          },
        ),
        
        // Suggestions Dropdown
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.grey,
                  ),
                  title: Text(
                    suggestion,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    widget.controller.text = suggestion;
                    widget.onSearch(suggestion);
                    setState(() {
                      _showSuggestions = false;
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }

    final suggestions = await ref
        .read(searchNotifierProvider.notifier)
        .getSearchSuggestions(query);

    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    }
  }
}