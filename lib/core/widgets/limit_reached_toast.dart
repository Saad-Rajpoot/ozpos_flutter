import 'dart:async';

import 'package:flutter/material.dart';

/// Toast shown at top-right of the screen (e.g. limit reached or required options).
/// Orange by default; pass [backgroundColor] for red "required options" style.
class LimitReachedToast {
  static const Color _toastOrange = Color(0xFFFF8C00);
  static const Duration _displayDuration = Duration(seconds: 3);

  /// Shows the toast at top-right of the device (root overlay).
  /// [backgroundColor] when null uses orange (limit reached); use red for required-options.
  /// When [bulletItems] is non-null and non-empty, [message] is shown as intro and items as a bullet list.
  static void show(
    BuildContext context, {
    String title = 'Limit Reached',
    required String message,
    List<String>? bulletItems,
    Duration duration = _displayDuration,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? _toastOrange;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    OverlayEntry? entry;
    Timer? timer;

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 12,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '!',
                      style: TextStyle(
                        color: bgColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (bulletItems != null && bulletItems.isNotEmpty) ...[
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...bulletItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      height: 1.35,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.35,
                                      ),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                            maxLines: 6,
                            overflow: TextOverflow.visible,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    timer = Timer(duration, () {
      timer?.cancel();
      entry?.remove();
    });
  }
}
