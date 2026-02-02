import 'package:flutter/material.dart';
import 'package:wealth_app/core/responsive/responsive_helper.dart';
import 'package:wealth_app/core/responsive/responsive_widgets.dart';

/// Widget for testing responsive behavior across different screen sizes
class ResponsiveTestWidget extends StatefulWidget {
  const ResponsiveTestWidget({super.key});

  @override
  State<ResponsiveTestWidget> createState() => _ResponsiveTestWidgetState();
}

class _ResponsiveTestWidgetState extends State<ResponsiveTestWidget> {
  final List<Size> testSizes = [
    const Size(402, 874),   // Mobile
    const Size(1024, 1366), // Tablet
    const Size(1440, 1024), // Desktop
    const Size(1920, 1080), // Large Desktop
  ];

  int currentSizeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText('Responsive Test'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                currentSizeIndex = (currentSizeIndex + 1) % testSizes.length;
              });
            },
            icon: const Icon(Icons.phone_android),
            tooltip: 'Switch Screen Size',
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: testSizes[currentSizeIndex].width,
          height: testSizes[currentSizeIndex].height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: testSizes[currentSizeIndex],
            ),
            child: Builder(
              builder: (context) => _buildTestContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestContent(BuildContext context) {
    return ResponsiveSafeArea(
      child: ResponsiveScrollView(
        children: [
          // Screen size info
          ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Screen Info',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                ResponsiveText('Size: ${MediaQuery.of(context).size}'),
                ResponsiveText('Type: ${_getScreenType(context)}'),
                ResponsiveText('Orientation: ${MediaQuery.of(context).orientation}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Responsive grid test
          ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Responsive Grid',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ResponsiveGridView(
                    shrinkWrap: true,
                    children: List.generate(
                      12,
                      (index) => Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: ResponsiveText('${index + 1}'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Responsive buttons test
          ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Responsive Buttons',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                ResponsiveWrap(
                  children: [
                    ResponsiveButton(
                      text: 'Primary',
                      onPressed: () {},
                    ),
                    ResponsiveButton(
                      text: 'Secondary',
                      onPressed: () {},
                    ),
                    ResponsiveIconButton(
                      icon: Icons.favorite,
                      onPressed: () {},
                      tooltip: 'Favorite',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Text scaling test
          ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Text Scaling Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  'This is a very long text that should adapt to different screen sizes and never overflow. It should scale appropriately and remain readable across all devices.',
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  'Short text',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Layout builder test
          ResponsiveLayoutBuilder(
            mobile: (context, constraints) => _buildMobileLayout(),
            tablet: (context, constraints) => _buildTabletLayout(),
            desktop: (context, constraints) => _buildDesktopLayout(),
            fallback: (context, constraints) => _buildMobileLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ResponsiveCard(
      child: Column(
        children: [
          const ResponsiveText('Mobile Layout'),
          const SizedBox(height: 8),
          ResponsiveButton(
            text: 'Mobile Button',
            onPressed: () {},
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return ResponsiveCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const ResponsiveText('Tablet Layout'),
                const SizedBox(height: 8),
                ResponsiveButton(
                  text: 'Tablet Button',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: ResponsiveText('Tablet Content'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return ResponsiveCard(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const ResponsiveText('Desktop Layout'),
                const SizedBox(height: 8),
                ResponsiveButton(
                  text: 'Desktop Button',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: ResponsiveText('Desktop Content Area'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenType(BuildContext context) {
    if (context.isMobile) return 'Mobile';
    if (context.isTablet) return 'Tablet';
    if (context.isLargeDesktop) return 'Large Desktop';
    if (context.isDesktop) return 'Desktop';
    return 'Unknown';
  }
}