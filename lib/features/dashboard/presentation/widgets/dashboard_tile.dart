import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_sizes.dart';

class DashboardTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<DashboardTile> createState() => _DashboardTileState();
}

class _TileInteractionState {
  const _TileInteractionState({this.isHovered = false, this.isPressed = false});

  final bool isHovered;
  final bool isPressed;

  _TileInteractionState copyWith({bool? isHovered, bool? isPressed}) {
    return _TileInteractionState(
      isHovered: isHovered ?? this.isHovered,
      isPressed: isPressed ?? this.isPressed,
    );
  }
}

class _DashboardTileState extends State<DashboardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ValueNotifier<_TileInteractionState> _interactionNotifier;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _interactionNotifier = ValueNotifier(const _TileInteractionState());
  }

  @override
  void dispose() {
    _interactionNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _updateInteraction(isPressed: true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _updateInteraction(isPressed: false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _updateInteraction(isPressed: false);
    _animationController.reverse();
  }

  void _updateInteraction({bool? isHovered, bool? isPressed}) {
    final current = _interactionNotifier.value;
    _interactionNotifier.value = current.copyWith(
      isHovered: isHovered,
      isPressed: isPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= AppSizes.breakpointLarge;

    return MouseRegion(
      onEnter: isDesktop ? (_) => _updateInteraction(isHovered: true) : null,
      onExit: isDesktop ? (_) => _updateInteraction(isHovered: false) : null,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: ValueListenableBuilder<_TileInteractionState>(
          valueListenable: _interactionNotifier,
          builder: (context, interaction, _) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final isHovered = interaction.isHovered;
                final isPressed = interaction.isPressed;
                return Transform.scale(
                  scale: isPressed
                      ? _scaleAnimation.value
                      : (isHovered ? 1.02 : 1.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: isHovered
                        ? (Matrix4.identity()
                          // ignore: deprecated_member_use
                          ..translate(0.0, -4.0, 0.0))
                        : Matrix4.identity(),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.tile),
                      border: Border.all(
                        color: isHovered
                            ? Colors.transparent
                            : AppColors.borderLight,
                        width: 2,
                      ),
                      boxShadow: isHovered
                          ? AppShadows.hoverShadow
                          : (isPressed
                              ? AppShadows.tileShadow
                              : AppShadows.cardShadow),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isHovered ? 1.0 : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.tile),
                              gradient: LinearGradient(
                                colors: widget.gradient.colors
                                    .map((color) => color.withOpacity(0.9))
                                    .toList(),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              transform: isHovered
                                  ? (Matrix4.identity()
                                    // ignore: deprecated_member_use
                                    ..scale(1.1, 1.1, 1.0))
                                  : Matrix4.identity(),
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: widget.gradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isHovered
                                    ? AppShadows.elevatedShadow
                                    : AppShadows.cardShadow,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Icon(
                                  widget.icon,
                                  size: 24,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Flexible(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? AppTypography.titleMedium
                                          : AppTypography.headlineSmall,
                                  fontWeight: AppTypography.bold,
                                  color: isHovered
                                      ? AppColors.textWhite
                                      : AppColors.textPrimary,
                                ),
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? AppTypography.labelSmall
                                          : AppTypography.labelMedium,
                                  fontWeight: AppTypography.regular,
                                  color: isHovered
                                      ? AppColors.textWhite.withOpacity(0.8)
                                      : AppColors.textSecondary,
                                ),
                                child: Text(
                                  widget.subtitle,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
