import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/settings_entities.dart';

class ExpandableCategoryList extends StatelessWidget {
  final List<SettingsCategoryEntity> categories;
  final ValueChanged<String> onAction;
  const ExpandableCategoryList(
      {super.key, required this.categories, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpandableCategoryCubit(),
      child: BlocBuilder<ExpandableCategoryCubit, Set<String>>(
        builder: (context, expanded) {
          final cubit = context.read<ExpandableCategoryCubit>();
          return Column(
            children: [
              for (final cat in categories)
                _CategoryCard(
                  category: cat,
                  isExpanded: expanded.contains(cat.id),
                  onAction: onAction,
                  onToggle: () => cubit.toggleCategory(cat.id),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final SettingsCategoryEntity category;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onAction;
  const _CategoryCard({
    required this.category,
    required this.isExpanded,
    required this.onToggle,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(category.id);
    final color = _colorFor(category.id);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
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
                        Text(
                          category.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
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
                    child: Text(
                      '${category.items.length} items',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
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
                    onTap: () => onAction(item.action),
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
  const _CategoryItemTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
                    Text(
                      subtitle,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class ExpandableCategoryCubit extends Cubit<Set<String>> {
  ExpandableCategoryCubit() : super(<String>{});

  void toggleCategory(String categoryId) {
    final updated = Set<String>.from(state);
    if (updated.contains(categoryId)) {
      updated.remove(categoryId);
    } else {
      updated.add(categoryId);
    }
    emit(updated);
  }
}
