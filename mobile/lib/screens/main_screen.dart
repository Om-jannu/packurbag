import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
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
          type: 'new_trip', localizedTitle: 'New Trip', icon: 'new_trip'),
      const ShortcutItem(
          type: 'translator', localizedTitle: 'Translator', icon: 'translator'),
      const ShortcutItem(
          type: 'currency_converter',
          localizedTitle: 'Currency Converter',
          icon: 'currency_converter'),
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
      floatingActionButton: (index == 2 || index == 3) ? null : _buildSpeedDial(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => widget.navigationShell.goBranch(
          i,
          initialLocation: i == widget.navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.rectangleList, size: 18),
            label: 'Home',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.suitcaseRolling, size: 18),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.earthAmericas, size: 18),
            label: 'Translate',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.locationDot, size: 18),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.user, size: 18),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: AppTheme.tealDark,
      foregroundColor: Colors.white,
      children: [
        SpeedDialChild(
          child: const FaIcon(FontAwesomeIcons.suitcaseRolling, size: 18, color: AppTheme.teal),
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          label: 'New Trip',
          onTap: _openNewTrip,
        ),
        SpeedDialChild(
          child: const FaIcon(FontAwesomeIcons.wallet, size: 18, color: AppTheme.teal),
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          label: 'Currency Converter',
          onTap: () => context.push('/currency-converter'),
        ),
        SpeedDialChild(
          child: const FaIcon(FontAwesomeIcons.robot, size: 18, color: AppTheme.teal),
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          label: 'AI Chat',
          onTap: () => context.push('/ai-chat'),
        ),
        SpeedDialChild(
          child: const FaIcon(FontAwesomeIcons.triangleExclamation, size: 18, color: Colors.white),
          shape: const CircleBorder(),
          backgroundColor: AppTheme.coral,
          label: 'SOS',
          onTap: () => context.push('/sos'),
        ),
      ],
    );
  }
}
