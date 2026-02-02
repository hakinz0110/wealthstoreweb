import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/core/responsive/adaptive_navigation.dart';


class MainNavigationShell extends ConsumerStatefulWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;
  
  const MainNavigationShell({
    super.key,
    required this.child,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigation(
      navigationShell: widget.navigationShell,
      child: widget.child,
    );
  }
} 