import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';

class ProminentSearchBar extends StatefulWidget {
  final String placeholder;
  final VoidCallback? onTap;
  final Function(String)? onSubmitted;
  final bool enabled;

  const ProminentSearchBar({
    super.key,
    this.placeholder = 'Search in Store',
    this.onTap,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<ProminentSearchBar> createState() => _ProminentSearchBarState();
}

class _ProminentSearchBarState extends State<ProminentSearchBar> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: widget.enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
        onTap: widget.enabled ? () => _handleTap(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 56,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.98 : _isHovered ? 1.01 : 1.0),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1E293B)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search icon
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 12),
                child: Icon(
                  Icons.search,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              
              // Placeholder text
              Expanded(
                child: Text(
                  widget.placeholder,
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                  ).copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    HapticFeedbackUtils.lightImpact();
    
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Default behavior: navigate to search screen
      context.push('/search');
    }
  }
}
