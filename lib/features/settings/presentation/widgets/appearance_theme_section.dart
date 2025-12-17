import 'package:flutter/material.dart';
import 'section_header.dart';

class AppearanceThemeSection extends StatelessWidget {
  const AppearanceThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionHeader(
          title: 'Appearance & Theme',
          subtitle: 'Personalize the look and feel of your POS',
        ),
        SizedBox(height: 8),
        _AppearanceCard(),
      ],
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _SelectableTile(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Light',
                    subtitle: 'Clean and bright',
                    selected: true,
                    onTap: _noop,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SelectableTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark',
                    subtitle: 'Easy on the eyes',
                    selected: false,
                    onTap: _noop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _ColorChip(label: 'Ocean Blue', color: Color(0xFF3B82F6), selected: true),
                _ColorChip(label: 'Fresh Green', color: Color(0xFF22C55E)),
                _ColorChip(label: 'Royal Purple', color: Color(0xFFA855F7)),
                _ColorChip(label: 'Warm Orange', color: Color(0xFFF59E0B)),
                _ColorChip(label: 'Bold Red', color: Color(0xFFEF4444)),
                _ColorChip(label: 'Cool Teal', color: Color(0xFF14B8A6)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}

class _SelectableTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _SelectableTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.black12,
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  const _ColorChip({required this.label, required this.color, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? color : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 8, backgroundColor: color),
          const SizedBox(width: 8),
          Text(label),
          if (selected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check, size: 16),
          ],
        ],
      ),
    );
  }
}


