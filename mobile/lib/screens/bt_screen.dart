import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../components/global_snackbar.dart';
import '../data/app_exception.dart';
import '../models/nearby_traveler.dart';
import '../providers/auth_provider.dart';
import '../providers/discovery_providers.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_state.dart';

/// "Nearby Travelers" — social travel discovery. Registered users opt in to
/// share their live location and can see (and chat with) other nearby
/// registered travelers. Replaces the old Wi-Fi Direct offline chat, which
/// couldn't discover *registered* users, only physically-adjacent devices.
class BtScreen extends ConsumerStatefulWidget {
  const BtScreen({super.key});

  @override
  ConsumerState<BtScreen> createState() => _BtScreenState();
}

class _BtScreenState extends ConsumerState<BtScreen> {
  bool _isToggling = false;

  Future<void> _setDiscoverable(bool value) async {
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;
    setState(() => _isToggling = true);

    try {
      if (value) {
        final position = await _getCurrentPosition();
        if (position == null) {
          if (mounted) {
            GlobalSnackbar.show(context,
                'Location permission is required to find nearby travelers.');
          }
          return;
        }
        await ref.read(discoveryRepositoryProvider).updateLocation(
              userId: userId,
              lat: position.latitude,
              lng: position.longitude,
              isDiscoverable: true,
            );
      } else {
        await ref
            .read(discoveryRepositoryProvider)
            .updateLocation(userId: userId, isDiscoverable: false);
      }
      await ref.read(authProvider.notifier).setDiscoverableLocally(value);
      ref.invalidate(nearbyTravelersProvider(userId));
    } on AppException catch (error) {
      if (mounted) GlobalSnackbar.show(context, error.message);
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  Future<Position?> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final userId = user?.id;
    final isDiscoverable = user?.isDiscoverable ?? false;
    final travelersAsync =
        (userId == null || !isDiscoverable) ? null : ref.watch(nearbyTravelersProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Travelers')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Share my location'),
            subtitle: Text(
              isDiscoverable
                  ? 'Other nearby travelers can see and message you'
                  : 'Turn on to find travelers near you',
            ),
            value: isDiscoverable,
            onChanged: _isToggling ? null : _setDiscoverable,
          ),
          const Divider(height: 1),
          Expanded(
            child: !isDiscoverable
                ? const EmptyState(
                    icon: Icons.travel_explore,
                    title: 'Discovery is off',
                    message:
                        'Turn on location sharing above to see travelers near you and start chatting.',
                  )
                : travelersAsync == null
                    ? const SizedBox.shrink()
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(nearbyTravelersProvider(userId!)),
                        child: travelersAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(child: Text('$error')),
                          data: (travelers) {
                            if (travelers.isEmpty) {
                              return const EmptyState(
                                icon: Icons.person_search,
                                title: 'No travelers nearby yet',
                                message: 'Check back later, or widen your travels!',
                              );
                            }
                            return ListView.builder(
                              itemCount: travelers.length,
                              itemBuilder: (context, index) {
                                final traveler = travelers[index];
                                return _TravelerTile(traveler: traveler);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TravelerTile extends StatelessWidget {
  const _TravelerTile({required this.traveler});
  final NearbyTraveler traveler;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(traveler.username[0].toUpperCase())),
      title: Text(traveler.username),
      subtitle: Text('${traveler.distanceKm.toStringAsFixed(1)} km away'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(
        '/nearby/chat',
        extra: traveler,
      ),
    );
  }
}
