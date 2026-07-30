import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/sos_navigation.dart';
import '../widgets/trip_form_sheet.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final quickActions = const QuickActions();

  @override
  void initState() {
    super.initState();
    quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'new_trip',
        localizedTitle: 'New Trip',
        icon: 'new_trip',
      ),
      const ShortcutItem(
        type: 'translator',
        localizedTitle: 'Translator',
        icon: 'translator',
      ),
      const ShortcutItem(
        type: 'currency_converter',
        localizedTitle: 'Currency Converter',
        icon: 'currency_converter',
      ),
    ]);
    quickActions.initialize((type) {
      switch (type) {
        case 'new_trip':
          _openNewTrip();
        case 'currency_converter':
          context.push('/currency-converter');
        case 'translator':
          context.go('/translate');
      }
    });
  }

  void _openNewTrip() {
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;
    showTripFormSheet(context, userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.navigationShell.currentIndex;
    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: (index == 2 || index == 3)
          ? null
          : _buildSpeedDial(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: AppTheme.borderMuted(context))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children:
                  [
                    _NavItem(
                      icon: LucideIcons.layoutList,
                      label: 'Home',
                      index: 0,
                      current: index,
                    ),
                    _NavItem(
                      icon: LucideIcons.briefcase,
                      label: 'Trips',
                      index: 1,
                      current: index,
                    ),
                    _NavItem(
                      icon: LucideIcons.globe,
                      label: 'Translate',
                      index: 2,
                      current: index,
                    ),
                    _NavItem(
                      icon: LucideIcons.mapPin,
                      label: 'Nearby',
                      index: 3,
                      current: index,
                    ),
                    _NavItem(
                      icon: LucideIcons.user,
                      label: 'Profile',
                      index: 4,
                      current: index,
                    ),
                  ].map((item) {
                    return Expanded(
                      child: InkWell(
                        onTap: () => widget.navigationShell.goBranch(
                          item.index,
                          initialLocation:
                              item.index == widget.navigationShell.currentIndex,
                        ),
                        child: item,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedDial() {
    final labelStyle = AppTextStyles.label(
      color: AppTheme.textPrimary(context),
      weight: FontWeight.w700,
    );
    return SpeedDial(
      icon: LucideIcons.plus,
      activeIcon: LucideIcons.x,
      backgroundColor: AppTheme.accentStrong(context),
      foregroundColor: AppTheme.onAccentStrong(context),
      children: [
        SpeedDialChild(
          child: const Icon(
            LucideIcons.briefcase,
            size: 18,
            color: AppTheme.teal,
          ),
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          label: 'New Trip',
          labelStyle: labelStyle,
          onTap: _openNewTrip,
        ),
        SpeedDialChild(
          child: const Icon(LucideIcons.wallet, size: 18, color: AppTheme.teal),
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          label: 'Currency Converter',
          labelStyle: labelStyle,
          onTap: () => context.push('/currency-converter'),
        ),
        SpeedDialChild(
          child: const Icon(LucideIcons.bot, size: 18, color: AppTheme.teal),
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          label: 'AI Chat',
          labelStyle: labelStyle,
          onTap: () => context.push('/ai-chat'),
        ),
        SpeedDialChild(
          child: const Icon(
            LucideIcons.triangleAlert,
            size: 18,
            color: Colors.white,
          ),
          shape: const CircleBorder(),
          backgroundColor: AppTheme.coral,
          label: 'SOS',
          labelStyle: labelStyle,
          onTap: () => navigateToSos(context),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
  });

  final IconData icon;
  final String label;
  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final color = isActive
        ? AppTheme.accentStrong(context)
        : AppTheme.textMuted(context, opacity: 0.35);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 23, color: color),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppTextStyles.micro(
            color: color,
            weight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
