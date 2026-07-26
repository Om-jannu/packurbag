import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

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
    // Every runtime permission a feature elsewhere in the app actually
    // requests: microphone (voice input for Translate), location (Nearby
    // Travelers discovery, SOS location sharing), photos (attaching a
    // document photo). Kept in one place so Profile is a genuine single
    // source of truth for what the app can access.
    const permissions = [Permission.microphone, Permission.location, Permission.photos];
    final statuses = await Future.wait(permissions.map(_requestPermission));
    if (!mounted) return;
    setState(() {
      _permissionStatuses = Map.fromIterables(permissions, statuses);
    });
  }

  Future<PermissionStatus> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      if (status.isPermanentlyDenied) {
        await _showPermanentlyDeniedDialog(permission);
      }
      return status;
    } catch (_) {
      // Some permissions (e.g. photo library) have no web implementation
      // and throw UnimplementedError there — this must never take down the
      // rest of the list, just report that one as unavailable.
      return PermissionStatus.denied;
    }
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: Text(
                'Profile',
                style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.accent(context).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.userCircle,
                        size: 36,
                        color: AppTheme.accent(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('User Details'),
                  const SizedBox(height: 6),
                  _DetailTile(
                    icon: LucideIcons.user,
                    label: 'Username',
                    value: user?.username ?? 'Unknown',
                  ),
                  const SizedBox(height: 8),
                  _DetailTile(
                    icon: LucideIcons.mail,
                    label: 'Email',
                    value: user?.userEmail ?? 'Unknown',
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Appearance'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: AppTheme.flatCard(context),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: ThemeMode.values.map((mode) {
                        return _ThemeOptionRow(
                          label: switch (mode) {
                            ThemeMode.system => 'Match system',
                            ThemeMode.light => 'Light',
                            ThemeMode.dark => 'Dark',
                          },
                          selected: themeMode == mode,
                          onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Permissions'),
                  const SizedBox(height: 6),
                  Column(
                    children: [
                      for (final entry in _permissionStatuses.entries) ...[
                        if (entry.key != _permissionStatuses.entries.first.key)
                          const SizedBox(height: 8),
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
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.coral.withValues(alpha: 0.15),
                        foregroundColor: AppTheme.coral,
                        elevation: 0,
                      ),
                      onPressed: _logout,
                      icon: const Icon(LucideIcons.logOut, size: 18),
                      label: Text('Logout', style: AppTextStyles.bodyBold(color: AppTheme.coral)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.tag(color: AppTheme.textMuted(context, opacity: 0.4))
          .copyWith(letterSpacing: 0.5),
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
    return Container(
      decoration: AppTheme.flatCard(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted(context, opacity: 0.5)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption(color: AppTheme.textMuted(context, opacity: 0.4)),
              ),
              Text(
                value,
                style: AppTextStyles.bodyBold(color: AppTheme.textPrimary(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppTheme.accent(context) : AppTheme.textMuted(context, opacity: 0.25),
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: AppTheme.accent(context), shape: BoxShape.circle),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body(color: AppTheme.textPrimary(context))),
          ],
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

  static final _icons = {
    Permission.microphone: LucideIcons.mic,
    Permission.location: LucideIcons.mapPin,
    Permission.photos: LucideIcons.image,
  };

  @override
  Widget build(BuildContext context) {
    final name = permission.toString().split('.').last;
    final label = name[0].toUpperCase() + name.substring(1);
    final isGranted = status.isGranted;
    final buttonLabel = status.isPermanentlyDenied
        ? 'Open Settings'
        : isGranted
            ? 'Enabled'
            : 'Enable';

    return Container(
      decoration: AppTheme.flatCard(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_icons[permission] ?? LucideIcons.shieldCheck,
                  size: 18, color: AppTheme.textMuted(context, opacity: 0.5)),
              const SizedBox(width: 10),
              Text(label, style: AppTextStyles.body(color: AppTheme.textPrimary(context))),
            ],
          ),
          TextButton(
            onPressed: isGranted ? null : onTap,
            style: TextButton.styleFrom(
              backgroundColor:
                  isGranted ? Colors.transparent : AppTheme.accent(context).withValues(alpha: 0.1),
              foregroundColor: AppTheme.accent(context),
              disabledForegroundColor: AppTheme.accent(context),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(buttonLabel, style: AppTextStyles.tag(color: AppTheme.accent(context))),
          ),
        ],
      ),
    );
  }
}
