import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'responsive_helper.dart';

/// Responsive text widget that adapts to screen size and prevents overflow
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final double? minFontSize;
  final double? maxFontSize;
  final bool autoSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.minFontSize,
    this.maxFontSize,
    this.autoSize = true,
  });

  @override
  Widget build(BuildContext context) {
    if (autoSize) {
      return AutoSizeText(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow ?? TextOverflow.ellipsis,
        minFontSize: minFontSize ?? 10,
        maxFontSize: maxFontSize ?? (style?.fontSize ?? 14) * 1.5,
      );
    }

    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}

/// Responsive container that adapts its properties based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final bool constrainWidth;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.constrainWidth = true,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? context.responsivePadding,
      margin: margin ?? context.responsiveMargin,
      decoration: decoration,
      child: child,
    );

    if (constrainWidth) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.responsiveMaxWidth,
        ),
        child: content,
      );
    }

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Responsive grid view that adapts column count based on screen size
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final int? forceColumns;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.forceColumns,
  });

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? context.responsiveGridColumns;
    final aspectRatio = childAspectRatio ?? context.responsiveAspectRatio;

    return GridView.builder(
      padding: padding ?? context.responsivePadding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive wrap widget that adapts spacing based on screen size
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  final double? spacing;
  final double? runSpacing;
  final WrapCrossAlignment crossAxisAlignment;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing,
    this.runSpacing,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing ?? context.responsive(mobile: 8.0, tablet: 12.0, desktop: 16.0),
      runSpacing: runSpacing ?? context.responsive(mobile: 8.0, tablet: 12.0, desktop: 16.0),
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// Responsive card widget with adaptive properties
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: elevation ?? context.responsiveElevation,
      margin: margin ?? context.responsiveMargin,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(context.responsiveBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(context.responsiveBorderRadius),
        child: Padding(
          padding: padding ?? context.responsivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive button with adaptive sizing
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isExpanded;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ?? ElevatedButton.styleFrom(
      minimumSize: Size(
        context.responsiveTouchTarget,
        context.responsiveTouchTarget,
      ),
      padding: context.responsivePadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
      ),
    );

    Widget button;
    if (icon != null) {
      button = ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: ResponsiveText(text),
        style: buttonStyle,
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: ResponsiveText(text),
      );
    }

    if (isExpanded) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Responsive icon button with adaptive sizing
class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;

  const ResponsiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: size ?? context.responsiveIconSize(24.0),
        color: color,
      ),
      tooltip: tooltip,
      constraints: BoxConstraints(
        minWidth: context.responsiveTouchTarget,
        minHeight: context.responsiveTouchTarget,
      ),
    );
  }
}

/// Responsive layout builder that provides different layouts for different screen sizes
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)? mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;
  final Widget Function(BuildContext context, BoxConstraints constraints)? largeDesktop;
  final Widget Function(BuildContext context, BoxConstraints constraints) fallback;

  const ResponsiveLayoutBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.isLargeDesktop && largeDesktop != null) {
          return largeDesktop!(context, constraints);
        } else if (context.isDesktop && desktop != null) {
          return desktop!(context, constraints);
        } else if (context.isTablet && tablet != null) {
          return tablet!(context, constraints);
        } else if (context.isMobile && mobile != null) {
          return mobile!(context, constraints);
        }
        return fallback(context, constraints);
      },
    );
  }
}

/// Responsive safe area that adapts to different screen sizes
class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}

/// Responsive scrollable widget that prevents overflow
class ResponsiveScrollView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final bool reverse;

  const ResponsiveScrollView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding ?? context.responsivePadding,
      physics: physics,
      reverse: reverse,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      ),
    );
  }
}

/// Responsive flexible widget that adapts flex values based on screen size
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}