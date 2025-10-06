import 'package:flutter/material.dart';
import '../theme/tokens.dart';

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

class _DashboardTileState extends State<DashboardTile> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }
  
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
  
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.large;
    
    return MouseRegion(
      onEnter: isDesktop ? (_) => setState(() => _isHovered = true) : null,
      onExit: isDesktop ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed 
                  ? _scaleAnimation.value 
                  : (_isHovered ? 1.02 : 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: _isHovered 
                    ? (Matrix4.identity()..translate(0.0, -4.0))
                    : Matrix4.identity(),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.tile),
                  border: Border.all(
                    color: _isHovered 
                        ? Colors.transparent 
                        : AppColors.borderLight,
                    width: 2,
                  ),
                  boxShadow: _isHovered
                      ? AppShadows.hoverShadow
                      : (_isPressed 
                          ? AppShadows.tileShadow 
                          : AppShadows.cardShadow),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay on hover
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.tile),
                          gradient: LinearGradient(
                            colors: widget.gradient.colors.map((color) => color.withOpacity(0.9)).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon container with gradient
                          Flexible(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              transform: _isHovered
                                  ? (Matrix4.identity()..scale(1.1, 1.1))
                                  : Matrix4.identity(),
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width < 600 
                                    ? AppSpacing.sm 
                                    : AppSpacing.md
                              ),
                              decoration: BoxDecoration(
                                gradient: widget.gradient,
                                borderRadius: BorderRadius.circular(AppRadius.iconContainer),
                                boxShadow: _isHovered
                                    ? AppShadows.elevatedShadow
                                    : AppShadows.cardShadow,
                              ),
                              child: Icon(
                                widget.icon,
                                size: MediaQuery.of(context).size.width < 600 
                                    ? AppSizes.iconLg 
                                    : AppSizes.iconTile,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.sm),
                          
                          // Label
                          Flexible(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 600 
                                    ? AppTypography.titleMedium
                                    : AppTypography.headlineSmall,
                                fontWeight: AppTypography.bold,
                                color: _isHovered 
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
                          
                          // Description
                          Flexible(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 600 
                                    ? AppTypography.labelSmall
                                    : AppTypography.labelMedium,
                                fontWeight: AppTypography.regular,
                                color: _isHovered
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
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}