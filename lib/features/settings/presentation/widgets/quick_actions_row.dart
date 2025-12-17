import 'package:flutter/material.dart';
import 'section_header.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(Icons.print, 'Test Print', () => _showSnack(context, 'Test print')),
      _QuickAction(Icons.sync, 'Force Sync', () => _showSnack(context, 'Force sync')),
      _QuickAction(Icons.delete_sweep, 'Clear Cache', () => _showSnack(context, 'Cache cleared')),
      _QuickAction(Icons.download, 'Backup Data', () => _showSnack(context, 'Backup started')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions', subtitle: 'Frequently used tools'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  children: actions
                      .map(
                        (a) => SizedBox(
                          width: isWide
                              ? (constraints.maxWidth - 36) / 4
                              : (constraints.maxWidth - 12) / 2,
                          child: _QuickActionTile(action: a),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _QuickAction(this.icon, this.label, this.onTap);
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: action.onTap,
      icon: Icon(action.icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(action.label),
      ),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        side: const BorderSide(color: Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}


