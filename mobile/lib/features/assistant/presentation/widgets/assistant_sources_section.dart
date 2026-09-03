import 'package:flutter/material.dart';

import 'assistant_source_chip.dart';

class AssistantSourceItem {
  const AssistantSourceItem({
    required this.label,
    this.icon = Icons.link_rounded,
    this.tooltip,
    this.isExternal = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String? tooltip;
  final bool isExternal;
  final VoidCallback? onTap;
}

class AssistantSourcesSection extends StatelessWidget {
  const AssistantSourcesSection({
    required this.sources,
    super.key,
    this.title = 'Sources',
    this.icon = Icons.source_outlined,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<AssistantSourceItem> sources;
  final String title;
  final IconData icon;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: '$title, ${sources.length} items',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: sources
                .map(
                  (source) => AssistantSourceChip(
                    label: source.label,
                    icon: source.icon,
                    tooltip: source.tooltip,
                    isExternal: source.isExternal,
                    onTap: source.onTap,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
