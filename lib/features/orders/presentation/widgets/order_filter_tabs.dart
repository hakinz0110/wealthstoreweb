import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderFilterTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final Function(String) onTabChanged;

  const OrderFilterTabs({
    super.key,
    required this.controller,
    required this.onTabChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        isScrollable: true,
        onTap: (index) {
          final statuses = ['all', 'pending', 'processing', 'shipped', 'delivered'];
          onTabChanged(statuses[index]);
        },
        tabs: const [
          Tab(text: 'All Orders'),
          Tab(text: 'Pending'),
          Tab(text: 'Processing'),
          Tab(text: 'Shipped'),
          Tab(text: 'Delivered'),
        ],
      ),
    );
  }
}