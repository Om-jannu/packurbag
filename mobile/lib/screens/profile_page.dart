import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    const permissions = [Permission.microphone];
    final statuses = await Future.wait(permissions.map(_requestPermission));
    if (!mounted) return;
    setState(() {
      _permissionStatuses = Map.fromIterables(permissions, statuses);
    });
  }

  Future<PermissionStatus> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      await _showPermanentlyDeniedDialog(permission);
    }
    return status;
  }

  Future<void> _showPermanentlyDeniedDialog(Permission permission) async {
    final name = permission.toString().split('.').last;
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$name permission'),
        content: Text(
          'This app needs $name permission to function properly. '
          'You can grant it in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
    if (openSettings == true) await openAppSettings();
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/profile.json',
              height: 150,
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('User Details'),
          _DetailTile(
            icon: Icons.account_circle_outlined,
            label: 'Username',
            value: user?.username ?? 'Unknown',
          ),
          _DetailTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.userEmail ?? 'Unknown',
          ),
          const SizedBox(height: 24),
          _SectionLabel('Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: RadioGroup<ThemeMode>(
                groupValue: themeMode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeModeProvider.notifier).setThemeMode(value);
                  }
                },
                child: Column(
                  children: ThemeMode.values.map((mode) {
                    return RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(switch (mode) {
                        ThemeMode.system => 'Match system',
                        ThemeMode.light => 'Light',
                        ThemeMode.dark => 'Dark',
                      }),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Permissions'),
          Card(
            child: Column(
              children: [
                for (final entry in _permissionStatuses.entries)
                  _PermissionRow(
                    permission: entry.key,
                    status: entry.value,
                    onTap: () => _requestPermission(entry.key).then((status) {
                      if (mounted) {
                        setState(() => _permissionStatuses[entry.key] = status);
                      }
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: _logout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.permission,
    required this.status,
    required this.onTap,
  });

  final Permission permission;
  final PermissionStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = permission.toString().split('.').last;
    return ListTile(
      title: Text(name[0].toUpperCase() + name.substring(1)),
      trailing: TextButton(
        onPressed: status.isGranted ? null : onTap,
        child: Text(
          status.isPermanentlyDenied
              ? 'Open Settings'
              : status.isGranted
                  ? 'Granted'
                  : 'Request',
        ),
      ),
    );
  }
}
