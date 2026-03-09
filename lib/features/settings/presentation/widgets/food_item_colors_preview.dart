import 'package:flutter/material.dart';
import 'section_header.dart';

class FoodItemColorsPreview extends StatelessWidget {
  const FoodItemColorsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <_FoodTileData>[
      _FoodTileData('Classic Burger', 'Regular menu items', Colors.white,
          Colors.black54, 'Default'),
      _FoodTileData('Wagyu Steak', 'Premium dishes', const Color(0xFFF1E9FF),
          const Color(0xFF6D28D9), 'Premium'),
      _FoodTileData("Chef's Special", 'Featured items', const Color(0xFFFFF7E6),
          const Color(0xFFCA8A04), 'Special'),
      _FoodTileData('Green Salad', 'Healthy options', const Color(0xFFEFFDF3),
          const Color(0xFF15803D), 'Healthy'),
      _FoodTileData('Spicy Wings', 'Spicy dishes', const Color(0xFFFFEEF0),
          const Color(0xFFB91C1C), 'Spicy'),
      _FoodTileData('Ice Cream', 'Cold items', const Color(0xFFE8FBFB),
          const Color(0xFF0F766E), 'Cold'),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;
    final crossAxisCount = isNarrow ? 1 : 2;
    final aspectRatio = isNarrow ? 8.0 : 6.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
            title: 'Food Item Colors',
            subtitle: 'Color-code menu items by category'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Short, pill-like tiles similar to reference.
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (_, i) => _FoodTile(data: tiles[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FoodTileData {
  final String title;
  final String subtitle;
  final Color bg;
  final Color badgeColor;
  final String badge;
  _FoodTileData(
      this.title, this.subtitle, this.bg, this.badgeColor, this.badge);
}

class _FoodTile extends StatelessWidget {
  final _FoodTileData data;
  const _FoodTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: data.badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                data.badge,
                style: TextStyle(
                  color: data.badgeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
