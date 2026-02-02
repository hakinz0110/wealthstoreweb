import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';


/// Adaptive navigation that switches between bottom nav, rail, and drawer based on screen size
class AdaptiveNavigation extends StatelessWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;
  
  const AdaptiveNavigation({
    super.key,
    required this.child,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    // Always use bottom navigation for consistent UX across all screen sizes
    return _buildBottomNavLayout(context);
  }

  Widget _buildBottomNavLayout(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }


}