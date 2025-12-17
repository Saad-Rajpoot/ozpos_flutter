import 'package:flutter/material.dart';

import '../../domain/entities/customer_display_promo_slide_entity.dart';

class CustomerDisplayIdleView extends StatelessWidget {
  const CustomerDisplayIdleView({
    super.key,
    required this.slide,
    required this.totalSlides,
    required this.activeIndex,
  });

  final CustomerDisplayPromoSlideEntity? slide;
  final int totalSlides;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    if (slide == null) {
      return const ColoredBox(color: Colors.black);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [slide!.gradientStart, slide!.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Billy's Burgers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Column(
                              key: ValueKey(slide!.id),
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  slide!.emoji,
                                  style: const TextStyle(
                                    fontSize: 120,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  slide!.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 72,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  slide!.subtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 6),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    slide!.priceText,
                                    style: TextStyle(
                                      color: slide!.gradientStart,
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: Colors.white54),
                                  ),
                                  child: Text(
                                    slide!.savingsText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _PromoDots(total: totalSlides, activeIndex: activeIndex),
              const SizedBox(height: 24),
              const Text(
                'Ask our staff about these deals!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoDots extends StatelessWidget {
  const _PromoDots({required this.total, required this.activeIndex});

  final int total;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    // Guard against division-by-zero when no slides are loaded
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == activeIndex % total;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 32 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isActive ? 0.95 : 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
