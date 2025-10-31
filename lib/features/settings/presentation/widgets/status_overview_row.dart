import 'package:flutter/material.dart';

class StatusOverviewRow extends StatelessWidget {
  const StatusOverviewRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatusCard(
        icon: Icons.refresh,
        title: 'App Version',
        primaryText: 'v2.4.1',
        badgeText: 'Update',
        badgeColor: const Color(0xFFF59E0B),
        actionLabel: 'Update Now',
        gradient: const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6)]),
        onAction: () => _snack(context, 'Checking for updates...'),
      ),
      const _StatusCard(
        icon: Icons.storage_outlined,
        title: 'Network',
        primaryText: '192.168.1.45',
        subtitle: 'Server: 192.168.1.100',
        badgeText: 'Online',
        badgeColor: Color(0xFF22C55E),
      ),
      const _StatusCard(
        icon: Icons.phone_android,
        title: 'Device Info',
        primaryText: 'Android 12',
        subtitle: 'POS Terminal 1',
        badgeText: 'Multi',
        badgeColor: Color(0xFFA855F7),
      ),
      const _StatusCard(
        icon: Icons.person_outline,
        title: 'Logged In',
        primaryText: 'Sarah Manager',
        subtitle: 'ID: SM001',
        badgeText: 'Manager',
        badgeColor: Color(0xFFF59E0B),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;
        final isMedium = constraints.maxWidth > 700;
        final crossAxisCount = isWide ? 4 : (isMedium ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (_, i) => cards[i],
        );
      },
    );
  }

  static void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String primaryText;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final String? actionLabel;
  final LinearGradient? gradient;
  final VoidCallback? onAction;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.primaryText,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.actionLabel,
    this.gradient,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                if (badgeText != null && badgeColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(color: badgeColor!, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(primaryText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
            const Spacer(),
            if (actionLabel != null && gradient != null)
              Container(
                decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(8)),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Center(
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


