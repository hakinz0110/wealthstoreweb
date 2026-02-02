import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/services/auth_service.dart';
import 'package:wealth_app/core/theme/app_theme_provider.dart';
import 'package:wealth_app/features/profile/data/user_profile_repository.dart';

import 'package:wealth_app/features/wishlist/data/favorites_repository.dart';
import 'package:wealth_app/features/profile/data/user_addresses_repository.dart';
import 'package:wealth_app/features/orders/domain/order_notifier.dart';
import 'package:wealth_app/router/navigation_helper.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:wealth_app/features/settings/presentation/screens/terms_of_service_screen.dart';

class EnhancedProfileScreen extends ConsumerWidget {
  const EnhancedProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile header with user info
          SliverToBoxAdapter(
            child: FutureBuilder<UserProfile?>(
              future: ref.read(userProfileRepositoryProvider).getCurrentUserProfile(),
              builder: (context, snapshot) {
                return _buildProfileHeader(context, snapshot.data);
              },
            ),
          ),
          
          // User stats section
          SliverToBoxAdapter(
            child: _buildUserStats(context, ref),
          ),
          
          // Menu sections
          SliverToBoxAdapter(
            child: _buildMenuSections(context, ref),
          ),
          

          
          // Logout button
          SliverToBoxAdapter(
            child: _buildLogoutSection(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile? profile) {
    final user = AuthService.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.xxl),
          bottomRight: Radius.circular(AppSpacing.xxl),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Large avatar with edit overlay
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onPrimary.withValues(alpha: 0.3),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
                    backgroundImage: profile?.avatarUrl != null
                        ? CachedNetworkImageProvider(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.onPrimary.withValues(alpha: 0.8),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => context.goToEnhancedEditProfile(),
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // User name and info
            Text(
              profile?.fullName ?? user?.email?.split('@')[0] ?? 'User',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (profile?.phone != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                profile!.phone!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (user?.email != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                user!.email!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, WidgetRef ref) {
    // Watch the order state to get real-time updates
    final orderState = ref.watch(orderNotifierProvider);
    
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Orders count - now synced with order state
          _buildStatItem(
            context,
            'Orders',
            orderState.orders.length.toString(),
            Icons.shopping_bag_outlined,
          ),
          // Wishlist count
          FutureBuilder<int>(
            future: ref.read(favoritesRepositoryProvider).getFavoritesCount(),
            builder: (context, snapshot) {
              return _buildStatItem(
                context,
                'Wishlist',
                snapshot.data?.toString() ?? '...',
                Icons.favorite_outline,
              );
            },
          ),
          // Addresses count
          FutureBuilder<int>(
            future: ref.read(userAddressesRepositoryProvider).getAddressesCount(),
            builder: (context, snapshot) {
              return _buildStatItem(
                context,
                'Addresses',
                snapshot.data?.toString() ?? '...',
                Icons.location_on_outlined,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSections(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account section
          _buildSectionHeader(context, 'Account'),
          _buildMenuGroup(context, [
            _MenuItemData(
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              icon: Icons.person_outline,
              onTap: () => context.goToEditProfileFromTab(),
            ),
            _MenuItemData(
              title: 'Shipping Addresses',
              subtitle: 'Manage your delivery addresses',
              icon: Icons.location_on_outlined,
              onTap: () => context.goToAddresses(),
            ),

          ]),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Shopping section
          _buildSectionHeader(context, 'Shopping'),
          _buildMenuGroup(context, [
            _MenuItemData(
              title: 'My Orders',
              subtitle: 'Track and manage your orders',
              icon: Icons.shopping_bag_outlined,
              onTap: () => context.push('/profile/orders'),
            ),
            _MenuItemData(
              title: 'Wishlist',
              subtitle: 'Your saved favorite items',
              icon: Icons.favorite_outline,
              onTap: () => context.push('/wishlist'),
            ),

          ]),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Support section
          _buildSectionHeader(context, 'Support'),
          _buildMenuGroup(context, [
            _MenuItemData(
              title: 'Customer Support',
              subtitle: 'Create and track support tickets',
              icon: Icons.support_agent_outlined,
              onTap: () => context.push('/profile/support'),
            ),
          ]),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Legal section
          _buildSectionHeader(context, 'Legal & Policies'),
          _buildMenuGroup(context, [
            _MenuItemData(
              title: 'Privacy Policy',
              subtitle: 'Learn how we protect your data',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _MenuItemData(
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              icon: Icons.description_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          
          return _buildMenuItem(
            context,
            item: item,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required _MenuItemData item,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: item.subtitle != null
              ? Text(
                  item.subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: item.onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.lg + 40 + AppSpacing.sm,
            endIndent: AppSpacing.lg,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
      ],
    );
  }



  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          CustomButton(
            text: 'Log Out',
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });
}