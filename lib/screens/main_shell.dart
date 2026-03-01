import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import '../services/app_settings_provider.dart';
import '../services/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'task_list_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

/// Main shell with a floating liquid-glass bottom navigation bar + coral FAB.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final _pages = const <Widget>[
    HomeScreen(),
    TaskListScreen(),
    ProfileScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppSettingsProvider>().locale;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    final labels = [
      AppLocalizations.tr('', lang),
      AppLocalizations.tr('tasks', lang),
      AppLocalizations.tr('profile', lang),
      AppLocalizations.tr('noti', lang),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad > 0 ? bottomPad : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Liquid-glass navigation pill ──
            Expanded(
              child: _LiquidGlassBar(
                isDark: isDark,
                items: List.generate(4, (i) {
                  return _GlassNavItem(
                    icon: _kNavIcons[i],
                    label: labels[i],
                    isSelected: _currentIndex == i,
                    isDark: isDark,
                    badgeCount: i == 3 ? unreadCount : 0,
                    onTap: () => setState(() => _currentIndex = i),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            // ── Coral 3-D FAB ──
            _CoralFAB(
              onTap: () => Navigator.pushNamed(context, '/add'),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icon list matching the screenshot style ──
const _kNavIcons = <IconData>[
  Icons.home_rounded,
  Icons.fact_check_outlined,
  Icons.description_outlined,
  Icons.chat_bubble_outline_rounded,
];

// ─────────────────────────────────────────────────────────────────────────────
// Liquid-glass navigation bar
// ─────────────────────────────────────────────────────────────────────────────
class _LiquidGlassBar extends StatelessWidget {
  final bool isDark;
  final List<Widget> items;

  const _LiquidGlassBar({required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: BoxDecoration(
              // top-to-bottom gradient = subtle 3-D glass look
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.13),
                        Colors.white.withValues(alpha: 0.06),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.92),
                        Colors.white.withValues(alpha: 0.78),
                      ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.5,
              ),
            ),
            child: Row(children: items),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single nav-bar item – selected shows white pill + icon + label
// ─────────────────────────────────────────────────────────────────────────────
class _GlassNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final int badgeCount;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 10 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected && !isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 21,
                      color: isSelected
                          ? (isDark ? Colors.white : AppConstants.textPrimary)
                          : (isDark ? Colors.white30 : const Color(0xFFBDBDBD)),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          decoration: BoxDecoration(
                            color: AppConstants.errorColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: AppFonts.of(context, 
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                // Label visible only when selected
                Flexible(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: isSelected
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              label,
                              style: AppFonts.of(context, 
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppConstants.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coral 3-D floating FAB with radial gradient + dashed outer ring
// ─────────────────────────────────────────────────────────────────────────────
class _CoralFAB extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CoralFAB({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Dashed ring ──
            CustomPaint(
              size: const Size(72, 72),
              painter: _DashedCirclePainter(
                color: isDark
                    ? const Color(0xFFFF6B6B).withValues(alpha: 0.25)
                    : const Color(0xFFFF6B6B).withValues(alpha: 0.18),
                strokeWidth: 1.5,
                dashCount: 28,
              ),
            ),
            // ── 3-D coral ball ──
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.45),
                  radius: 0.9,
                  colors: [
                    Color(0xFFFFAAAA), // highlight
                    Color(0xFFFF6B6B), // mid
                    Color(0xFFE05050), // shadow
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.10),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed-circle painter (outer ring around the FAB)
// ─────────────────────────────────────────────────────────────────────────────
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  static const double _twoPi = 3.14159265358979 * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final dashAngle = _twoPi / dashCount;
    const gapFraction = 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dashCount != dashCount;
}
