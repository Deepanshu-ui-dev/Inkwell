import 'package:flutter/material.dart';
import 'package:blog_app/utils/constants.dart';

/// A wrapper that constrains the max width of its child and centers it.
/// It also provides an adaptive padding based on the screen width.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool addPadding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1000,
    this.addPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: addPadding
            ? Padding(padding: _adaptivePadding(context), child: child)
            : child,
      ),
    );
  }

  EdgeInsets _adaptivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppBreakpoints.desktop) return EdgeInsets.symmetric(horizontal: 48);
    if (width >= AppBreakpoints.tablet) return EdgeInsets.symmetric(horizontal: 32);
    return EdgeInsets.symmetric(horizontal: 16);
  }
}

/// A responsive grid that changes column count based on screen width.
/// Mobile: 1 col, Tablet: 2 cols, Desktop: 3 cols.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= AppBreakpoints.tablet) {
          crossAxisCount = 2;
        }

        if (crossAxisCount == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) SizedBox(height: runSpacing),
              ],
            ],
          );
        }

        final double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
        );
      },
    );
  }
}
