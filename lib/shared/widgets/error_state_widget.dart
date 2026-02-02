import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/utils/error_handler.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? customMessage;
  final bool showRetryButton;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkError = ErrorHandler.isNetworkError(error);
    final errorMessage = customMessage ?? ErrorHandler.getUserFriendlyMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isNetworkError 
                    ? Colors.orange.shade50 
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError 
                    ? Icons.wifi_off_rounded 
                    : Icons.error_outline_rounded,
                size: 64,
                color: isNetworkError 
                    ? Colors.orange.shade400 
                    : Colors.red.shade400,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Error Title
            Text(
              isNetworkError ? 'No Internet Connection' : 'Oops! Something Went Wrong',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Error Message
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              
              // Retry Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Try Again',
                  onPressed: onRetry!,
                  icon: Icons.refresh,
                ),
              ),
            ],
            
            if (isNetworkError) ...[
              const SizedBox(height: AppSpacing.md),
              
              // Network Tips
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Quick Tips:',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTip('Check your WiFi or mobile data'),
                    _buildTip('Try turning airplane mode on and off'),
                    _buildTip('Move to an area with better signal'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.orange.shade700,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact error widget for smaller spaces
class CompactErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const CompactErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorHandler.getUserFriendlyMessage(error);
    final isNetworkError = ErrorHandler.isNetworkError(error);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isNetworkError 
            ? Colors.orange.shade50 
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isNetworkError 
              ? Colors.orange.shade200 
              : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.error_outline,
            color: isNetworkError 
                ? Colors.orange.shade700 
                : Colors.red.shade700,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isNetworkError ? 'No Connection' : 'Error',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isNetworkError 
                        ? Colors.orange.shade700 
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  errorMessage,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isNetworkError 
                        ? Colors.orange.shade700 
                        : Colors.red.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: isNetworkError 
                  ? Colors.orange.shade700 
                  : Colors.red.shade700,
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }
}
