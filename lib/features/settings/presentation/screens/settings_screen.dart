import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../domain/entities/settings_entities.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsError) {
            return Center(child: Text(state.message));
          }
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _AppearanceThemeSection(),
                const SizedBox(height: 16),
                const _FoodItemColorsPreview(),
                const SizedBox(height: 24),
                const _StatusOverviewRow(),
                const SizedBox(height: 24),
                _ExpandableCategoryList(categories: state.categories),
                const SizedBox(height: 24),
                const _QuickActionsRow(),
                const SizedBox(height: 24),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleItemTap(BuildContext context, String action) {
    if (action.startsWith('nav:')) {
      final route = action.substring(4);
      switch (route) {
        case 'docket-management':
          Navigator.pushNamed(context, AppRouter.docketManagement);
          break;
        case 'menu-management':
          Navigator.pushNamed(context, AppRouter.menuEditor);
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unhandled nav: $route')),
          );
      }
    } else if (action.startsWith('toast:')) {
      final msg = action.substring(6);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _AppearanceThemeSection extends StatelessWidget {
  const _AppearanceThemeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Appearance & Theme',
          subtitle: 'Personalize the look and feel of your POS',
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Mode',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SelectableTile(
                        icon: Icons.wb_sunny_outlined,
                        title: 'Light',
                        subtitle: 'Clean and bright',
                        selected: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SelectableTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark',
                        subtitle: 'Easy on the eyes',
                        selected: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Accent Color',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _ColorChip(
                        label: 'Ocean Blue',
                        color: Color(0xFF3B82F6),
                        selected: true),
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
        ),
      ],
    );
  }
}

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
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.black12,
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
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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
  const _ColorChip(
      {required this.label, required this.color, this.selected = false});

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

class _FoodItemColorsPreview extends StatelessWidget {
  const _FoodItemColorsPreview();

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Food Item Colors',
          subtitle: 'Color-code menu items by category',
        ),
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
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(data.subtitle,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12)),
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
                style: TextStyle(
                    color: data.badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ));
  }
}

class _ExpandableCategoryList extends StatefulWidget {
  final List<SettingsCategoryEntity> categories;
  const _ExpandableCategoryList({required this.categories});

  @override
  State<_ExpandableCategoryList> createState() =>
      _ExpandableCategoryListState();
}

class _ExpandableCategoryListState extends State<_ExpandableCategoryList> {
  final Set<String> _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final cat in widget.categories)
          _CategoryCard(
            category: cat,
            isExpanded: _expanded.contains(cat.id),
            onToggle: () {
              setState(() {
                if (_expanded.contains(cat.id)) {
                  _expanded.remove(cat.id);
                } else {
                  _expanded.add(cat.id);
                }
              });
            },
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final SettingsCategoryEntity category;
  final bool isExpanded;
  final VoidCallback onToggle;
  const _CategoryCard(
      {required this.category,
      required this.isExpanded,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(category.id);
    final color = _colorFor(category.id);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black12),
      ),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(category.description,
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${category.items.length} items',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: category.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 8,
                ),
                itemBuilder: (_, i) {
                  final item = category.items[i];
                  return _CategoryItemTile(
                    icon: _itemIconFor(item.action),
                    color: color,
                    title: item.name,
                    subtitle: item.description,
                    onTap: () => (context
                            .findAncestorWidgetOfExactType<SettingsScreen>())
                        ?._handleItemTap(context, item.action),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconFor(String id) {
    switch (id) {
      case 'user-access':
        return Icons.groups_outlined;
      case 'system':
        return Icons.settings_suggest_outlined;
      case 'operations':
        return Icons.dashboard_customize_outlined;
      case 'customization':
        return Icons.palette_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  static Color _colorFor(String id) {
    switch (id) {
      case 'user-access':
        return const Color(0xFF22C55E);
      case 'system':
        return const Color(0xFF3B82F6);
      case 'operations':
        return const Color(0xFFA855F7);
      case 'customization':
        return const Color(0xFFF59E0B);
      default:
        return Colors.blueGrey;
    }
  }

  static IconData _itemIconFor(String action) {
    if (action.contains('printer')) return Icons.print_outlined;
    if (action.contains('docket')) return Icons.receipt_long_outlined;
    if (action.contains('menu')) return Icons.restaurant_menu_outlined;
    if (action.contains('switch')) return Icons.switch_account_outlined;
    if (action.contains('permissions')) return Icons.vpn_key_outlined;
    if (action.contains('client')) return Icons.person_outline;
    return Icons.tune;
  }
}

class _CategoryItemTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CategoryItemTile(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
          Icons.print, 'Test Print', () => _showSnack(context, 'Test print')),
      _QuickAction(
          Icons.sync, 'Force Sync', () => _showSnack(context, 'Force sync')),
      _QuickAction(Icons.delete_sweep, 'Clear Cache',
          () => _showSnack(context, 'Cache cleared')),
      _QuickAction(Icons.download, 'Backup Data',
          () => _showSnack(context, 'Backup started')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
            title: 'Quick Actions', subtitle: 'Frequently used tools'),
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
                      .map((a) => SizedBox(
                            width: isWide
                                ? (constraints.maxWidth - 36) / 4
                                : (constraints.maxWidth - 12) / 2,
                            child: _QuickActionTile(action: a),
                          ))
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

class _StatusOverviewRow extends StatelessWidget {
  const _StatusOverviewRow();

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
        gradient: const LinearGradient(
            colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6)]),
        onAction: () => _snack(context, 'Checking for updates...'),
      ),
      _StatusCard(
        icon: Icons.storage_outlined,
        title: 'Network',
        primaryText: '192.168.1.45',
        subtitle: 'Server: 192.168.1.100',
        badgeText: 'Online',
        badgeColor: const Color(0xFF22C55E),
      ),
      _StatusCard(
        icon: Icons.phone_android,
        title: 'Device Info',
        primaryText: 'Android 12',
        subtitle: 'POS Terminal 1',
        badgeText: 'Multi',
        badgeColor: const Color(0xFFA855F7),
      ),
      _StatusCard(
        icon: Icons.person_outline,
        title: 'Logged In',
        primaryText: 'Sarah Manager',
        subtitle: 'ID: SM001',
        badgeText: 'Manager',
        badgeColor: const Color(0xFFF59E0B),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(badgeText!,
                        style: TextStyle(
                            color: badgeColor!,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(primaryText,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!,
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
            const Spacer(),
            if (actionLabel != null && gradient != null)
              Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Center(
                        child: Text(actionLabel!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
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
