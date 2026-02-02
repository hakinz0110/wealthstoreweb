import 'package:flutter/material.dart';
import 'package:wealth_app/shared/models/category.dart';

/// Enhanced category model for home screen display with icon and routing information
class HomeCategory {
  final int id;
  final String name;
  final IconData icon;
  final String route;
  final Category? originalCategory;

  const HomeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    this.originalCategory,
  });

  /// Create HomeCategory from existing Category model
  factory HomeCategory.fromCategory(Category category) {
    return HomeCategory(
      id: category.id,
      name: category.name,
      icon: _getIconForCategory(category.name),
      route: '/products?category=${category.id}',
      originalCategory: category,
    );
  }

  /// Get appropriate icon for category name
  static IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    
    // Sports & Fitness
    if (name.contains('sport') || name.contains('fitness') || name.contains('gym')) {
      return Icons.sports_soccer;
    } 
    // Furniture & Home
    else if (name.contains('furniture') || name.contains('home') || name.contains('decor') || 
             name.contains('kitchen') || name.contains('kit')) {
      return Icons.chair;
    } 
    // Electronics & Tech
    else if (name.contains('electronic') || name.contains('tech') || name.contains('phone') || 
             name.contains('computer') || name.contains('gadget')) {
      return Icons.smartphone;
    } 
    // Clothing & Fashion
    else if (name.contains('cloth') || name.contains('fashion') || name.contains('apparel') || 
             name.contains('wear') || name.contains('shirt') || name.contains('dress') ||
             name.contains('pant') || name.contains('jean')) {
      return Icons.checkroom;
    } 
    // Animals & Pets
    else if (name.contains('animal') || name.contains('pet') || name.contains('dog') || 
             name.contains('cat')) {
      return Icons.pets;
    } 
    // Footwear
    else if (name.contains('shoe') || name.contains('footwear') || name.contains('sneaker') ||
             name.contains('boot') || name.contains('sandal')) {
      return Icons.sports_tennis;
    }
    // Books & Education
    else if (name.contains('book') || name.contains('education') || name.contains('learn') ||
             name.contains('study')) {
      return Icons.menu_book;
    }
    // Beauty & Health
    else if (name.contains('beauty') || name.contains('health') || name.contains('cosmetic') ||
             name.contains('makeup')) {
      return Icons.spa;
    }
    // Food & Beverages
    else if (name.contains('food') || name.contains('drink') || name.contains('beverage') ||
             name.contains('restaurant')) {
      return Icons.restaurant;
    }
    // Toys & Games
    else if (name.contains('toy') || name.contains('game') || name.contains('play')) {
      return Icons.toys;
    }
    // Jewelry & Accessories
    else if (name.contains('jewelry') || name.contains('jewel') || name.contains('accessory') ||
             name.contains('watch')) {
      return Icons.watch;
    }
    // Default
    else {
      return Icons.category;
    }
  }
}

/// Predefined popular categories for home screen
class PopularCategories {
  static const List<HomeCategory> defaultCategories = [
    HomeCategory(
      id: 1,
      name: 'Sports',
      icon: Icons.sports_soccer,
      route: '/products?category=sports',
    ),
    HomeCategory(
      id: 2,
      name: 'Furniture',
      icon: Icons.chair,
      route: '/products?category=furniture',
    ),
    HomeCategory(
      id: 3,
      name: 'Electronics',
      icon: Icons.smartphone,
      route: '/products?category=electronics',
    ),
    HomeCategory(
      id: 4,
      name: 'Clothes',
      icon: Icons.checkroom,
      route: '/products?category=clothes',
    ),
    HomeCategory(
      id: 5,
      name: 'Animals',
      icon: Icons.pets,
      route: '/products?category=animals',
    ),
    HomeCategory(
      id: 6,
      name: 'Shoes',
      icon: Icons.sports_tennis,
      route: '/products?category=shoes',
    ),
  ];
}