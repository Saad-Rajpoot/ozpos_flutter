import 'package:flutter/material.dart';
import 'section_header.dart';

class FoodItemColorsPreview extends StatelessWidget {
  const FoodItemColorsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <_FoodTileData>[
      _FoodTileData('Classic Burger', 'Regular menu items', Colors.white, Colors.black54, 'Default'),
      _FoodTileData('Wagyu Steak', 'Premium dishes', const Color(0xFFF1E9FF), const Color(0xFF6D28D9), 'Premium'),
      _FoodTileData("Chef's Special", 'Featured items', const Color(0xFFFFF7E6), const Color(0xFFCA8A04), 'Special'),
      _FoodTileData('Green Salad', 'Healthy options', const Color(0xFFEFFDF3), const Color(0xFF15803D), 'Healthy'),
      _FoodTileData('Spicy Wings', 'Spicy dishes', const Color(0xFFFFEEF0), const Color(0xFFB91C1C), 'Spicy'),
      _FoodTileData('Ice Cream', 'Cold items', const Color(0xFFE8FBFB), const Color(0xFF0F766E), 'Cold'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Food Item Colors', subtitle: 'Color-code menu items by category'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 10,
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
  _FoodTileData(this.title, this.subtitle, this.bg, this.badgeColor, this.badge);
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
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(data.subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: data.badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              data.badge,
              style: TextStyle(color: data.badgeColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}


