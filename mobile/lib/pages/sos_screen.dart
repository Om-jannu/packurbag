import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:torch_light/torch_light.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Literal reds matching the design reference's `red-500`/`red-100` (this
/// screen reads as an alert, so it intentionally uses a literal red rather
/// than the brand's coral/teal roles).
const _sosRed = Color(0xFFEF4444);
const _sosRedTrack = Color(0xFFFEE2E2);

/// What became of the countdown — kept distinct from a plain bool because
/// "the user cancelled" and "the alert actually fired" need different UI
/// afterward (a fired alert should say who's being called; a cancellation
/// shouldn't imply anything happened).
enum _SosOutcome { counting, cancelled, triggered }

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  Timer? _timer;
  final int _durationInSeconds = 10; // Duration for the SOS timer in seconds
  double _progress = 0.0;
  _SosOutcome _outcome = _SosOutcome.counting;
  // null: still trying to send / not yet attempted. true: sent. false:
  // failed (no location permission, GPS off, no fix, or no SMS app) — the
  // triggered banner must reflect this truthfully rather than always
  // claiming the location was shared.
  bool? _locationShareSucceeded;
  bool _isBuzzerOn = false; // Track the state of the buzzer
  bool _isFlashOn = false; // Track whether the SOS strobe loop is running
  bool _isTorchLit =
      false; // Track the flashlight's actual physical on/off state
  Timer? _flashTimer;
  final player = AudioPlayer();

  List<Map<String, String>> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    // Wait for any saved contacts to actually load before the countdown can
    // fire — otherwise a countdown that completes very quickly could decide
    // "no contacts" against the still-empty initial value while real,
    // already-saved contacts are just a beat away from finishing their load.
    _loadEmergencyContacts().then((_) {
      if (mounted) _startTimer();
    });
  }

  @override
  void dispose() {
    // Own cleanup before super.dispose(), not after — once the base class's
    // dispose runs, the framework considers this State defunct. _timer may
    // never have been assigned if the widget was disposed while still
    // waiting on _loadEmergencyContacts() in initState.
    _timer?.cancel();
    _flashTimer?.cancel();
    if (_isTorchLit) {
      TorchLight.disableTorch().catchError((_) {});
    }
    player.stop();
    player.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _showAddContactDialog();
      case 1:
        _toggleBuzzer();
      case 2:
        _toggleFlash();
    }
  }

  void _startTimer() {
    // Start a timer for the specified duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_outcome == _SosOutcome.counting) {
        setState(() {
          _progress = timer.tick / _durationInSeconds;
          Vibration.vibrate().catchError((_) {});
          if (timer.tick == _durationInSeconds) {
            _triggerSOS();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _callNumber(String number) async {
    try {
      final placed = await FlutterPhoneDirectCaller.callNumber(number);
      if (placed != true) _showCallFailedMessage();
    } catch (_) {
      _showCallFailedMessage();
    }
  }

  void _showCallFailedMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Couldn't place the call — try calling manually."),
      ),
    );
  }

  /// Grabs the current position (best-effort — this must never block or
  /// fail the SOS flow itself) and texts a Google Maps link to [number].
  /// Returns whether the SMS was actually launched, so callers can tell the
  /// user the truth instead of assuming it worked.
  Future<bool> _shareLocationViaSms(String number) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      Position? position;
      try {
        // A precise fix can take a long time (or never arrive) indoors or
        // with poor signal — exactly the conditions someone triggering an
        // emergency alert might be in — so this doesn't wait indefinitely.
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) return false;

      final mapsLink =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      final body = 'I need help. My location: $mapsLink';
      // iOS's Messages app has a long-documented quirk where the sms: URL
      // scheme needs "&" rather than "?" before the body parameter for the
      // pre-filled text to actually show up; Android accepts either.
      final separator = defaultTargetPlatform == TargetPlatform.iOS ? '&' : '?';
      final smsUri = Uri.parse(
        'sms:$number$separator'
        'body=${Uri.encodeQueryComponent(body)}',
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      }
      return false;
    } catch (_) {
      // Best-effort only — a failure here shouldn't interrupt the SOS flow.
      return false;
    }
  }

  void _triggerSOS() {
    Vibration.vibrate().catchError((_) {});

    if (_emergencyContacts.isNotEmpty) {
      final phone = _emergencyContacts[0]['phone']!;
      _callNumber(phone);
      _shareLocationViaSms(phone).then((sent) {
        if (mounted) setState(() => _locationShareSucceeded = sent);
      });
    }

    setState(() {
      _outcome = _SosOutcome.triggered;
    });
  }

  void _toggleBuzzer() async {
    setState(() {
      _isBuzzerOn = !_isBuzzerOn;
    });

    if (_isBuzzerOn) {
      // Start playing the buzzer sound on a loop until toggled off.
      await player.setReleaseMode(ReleaseMode.loop);
      player.play(AssetSource("sounds/sos.mp3"), mode: PlayerMode.mediaPlayer);
    } else {
      // Stop playing the buzzer sound
      await player.stop();
    }
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    if (_isFlashOn) {
      // Start the flashlight toggle loop
      _startFlashToggle();
    } else {
      // Stop the flashlight toggle loop
      _stopFlashToggle();
    }
  }

  void _startFlashToggle() {
    // A rapid on/off/on tap sequence could otherwise leave a previous timer
    // running alongside this new one, with both racing to flip the same
    // torch state.
    _flashTimer?.cancel();
    // Start a timer to toggle the flashlight every 100 milliseconds
    _flashTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) async {
      if (!_isFlashOn) {
        // If flashlight is turned off externally, cancel the timer
        timer.cancel();
        return;
      }
      try {
        if (_isTorchLit) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
        _isTorchLit = !_isTorchLit;
      } catch (_) {
        // No flashlight on this device, or it's in use elsewhere — stop
        // trying rather than throwing every 100ms.
        timer.cancel();
      }
    });
  }

  void _stopFlashToggle() async {
    if (_isTorchLit) {
      try {
        await TorchLight.disableTorch();
      } catch (_) {
        // Already off or unavailable — nothing to clean up.
      }
      _isTorchLit = false;
    }
  }

  Future<void> _loadEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = prefs.getStringList('emergencyContacts');
    if (contacts == null) return;

    final parsed = <Map<String, String>>[];
    for (final raw in contacts) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        parsed.add({
          'name': decoded['name'] as String,
          'phone': decoded['phone'] as String,
        });
      } catch (_) {
        // Fall back to the old comma-joined format ("name,phone") so
        // contacts saved before this screen switched to JSON storage still
        // load once, rather than being silently dropped.
        final parts = raw.split(',');
        if (parts.length >= 2) {
          parsed.add({
            'name': parts.first,
            'phone': parts.sublist(1).join(','),
          });
        }
      }
    }
    if (mounted) setState(() => _emergencyContacts = parsed);
  }

  Future<void> _saveEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    // JSON-encoded per contact rather than a bare "name,phone" join — a
    // comma in a saved name (e.g. "Smith, John") used to silently corrupt
    // the split on load.
    final contacts = _emergencyContacts.map(jsonEncode).toList();
    await prefs.setStringList('emergencyContacts', contacts);
  }

  void _showAddContactDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final phonePattern = RegExp(r'^[0-9+\-\s]{7,15}$');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Please enter a phone number';
                    if (!phonePattern.hasMatch(trimmed)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                setState(() {
                  _emergencyContacts.add({
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });
                  _saveEmergencyContacts();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteContactDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Emergency Contact'),
          content: const Text('Are you sure you want to delete this contact?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _emergencyContacts.removeAt(index);
                  _saveEmergencyContacts();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_durationInSeconds - (_progress * _durationInSeconds))
        .floor();
    final counting = _outcome == _SosOutcome.counting;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderMuted(context)),
                ),
              ),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        size: 20,
                        color: AppTheme.textPrimary(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 12),
                  const Icon(
                    LucideIcons.triangleAlert,
                    size: 20,
                    color: _sosRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Emergency SOS',
                    style: AppTextStyles.appBarTitle(
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: counting
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                const CircularProgressIndicator(
                                  value: 1,
                                  strokeWidth: 20,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _sosRedTrack,
                                  ),
                                ),
                                CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 20,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        _sosRed,
                                      ),
                                  strokeCap: StrokeCap.round,
                                ),
                                Center(
                                  child: Text(
                                    '$remaining',
                                    style: AppTextStyles.display(
                                      color: AppTheme.textPrimary(context),
                                    ).copyWith(fontSize: 40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _emergencyContacts.isEmpty
                                  ? "No emergency contact added — add one below so SOS can call for help"
                                  : 'Calling your emergency contact in ${remaining}s',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption(
                                color: _emergencyContacts.isEmpty
                                    ? _sosRed
                                    : AppTheme.textMuted(context),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SlideAction(
                              sliderButtonIcon: const Icon(
                                LucideIcons.x,
                                color: Colors.white,
                              ),
                              height: 60,
                              // Full pill shape (half the height) to match the
                              // app's other primary interactive controls (chat
                              // input, send button) rather than the softer
                              // card-corner radius used for static containers.
                              borderRadius: 30,
                              elevation: 0,
                              innerColor: _sosRed,
                              outerColor: _sosRedTrack,
                              animationDuration: const Duration(
                                milliseconds: 500,
                              ),
                              text: 'Slide to Cancel',
                              textStyle: AppTextStyles.bodyBold(
                                color: _sosRed,
                              ).copyWith(fontStyle: FontStyle.italic),
                              onSubmit: () {
                                setState(() {
                                  _outcome = _SosOutcome.cancelled;
                                });
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        if (_outcome == _SosOutcome.triggered &&
                            _emergencyContacts.isNotEmpty)
                          Container(
                            width: double.infinity,
                            color: _sosRedTrack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.phoneCall,
                                  color: _sosRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _locationShareSucceeded == false
                                        ? "Calling ${_emergencyContacts[0]['name']}. Couldn't send your location — tell them where you are."
                                        : 'Calling ${_emergencyContacts[0]['name']} and sharing your location.',
                                    style: AppTextStyles.label(
                                      color: _sosRed,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: _emergencyContacts.isEmpty
                              ? _EmptyContactsView(
                                  onAddContact: _showAddContactDialog,
                                )
                              : ReorderableListView(
                                  buildDefaultDragHandles: false,
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    16,
                                    12,
                                  ),
                                  onReorderItem: (oldIndex, newIndex) {
                                    setState(() {
                                      final item = _emergencyContacts.removeAt(
                                        oldIndex,
                                      );
                                      _emergencyContacts.insert(newIndex, item);
                                      _saveEmergencyContacts();
                                    });
                                  },
                                  children: _emergencyContacts
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => Container(
                                          // Keyed by identity (name+phone), not
                                          // position — a position-based key
                                          // means the framework can't correctly
                                          // track which specific contact moved
                                          // where during a reorder.
                                          key: ValueKey(
                                            '${entry.value['name']}|${entry.value['phone']}',
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: AppTheme.flatCard(
                                            context,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              ReorderableDragStartListener(
                                                index: entry.key,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 8,
                                                      ),
                                                  child: Icon(
                                                    LucideIcons.gripVertical,
                                                    size: 18,
                                                    color: AppTheme.textMuted(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            entry
                                                                .value['name']!,
                                                            style: AppTextStyles.bodyBold(
                                                              color:
                                                                  AppTheme.textPrimary(
                                                                    context,
                                                                  ),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        if (entry.key == 0)
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                        if (entry.key == 0)
                                                          const Icon(
                                                            LucideIcons.star,
                                                            size: 16,
                                                            color:
                                                                AppTheme.amber,
                                                          ), // First contact is auto-dialed on trigger
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      entry.value['phone']!,
                                                      style: AppTextStyles.caption(
                                                        color:
                                                            AppTheme.textMuted(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  LucideIcons.mapPin,
                                                  color: AppTheme.textMuted(
                                                    context,
                                                  ),
                                                ),
                                                tooltip: 'Text my location',
                                                onPressed: () async {
                                                  final sent =
                                                      await _shareLocationViaSms(
                                                        entry.value['phone']!,
                                                      );
                                                  if (!mounted) return;
                                                  if (sent) return;
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Couldn't send your location — check location permission and try again.",
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  LucideIcons.phone,
                                                  color: AppTheme.textMuted(
                                                    context,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _callNumber(
                                                    entry.value['phone']!,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  LucideIcons.trash2,
                                                  color: AppTheme.textMuted(
                                                    context,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _showDeleteContactDialog(
                                                    entry.key,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppTheme.borderMuted(context)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SosActionButton(
                icon: LucideIcons.userPlus,
                label: 'Add contact',
                active: false,
                onTap: () => _onItemTapped(0),
              ),
              _SosActionButton(
                icon: LucideIcons.megaphone,
                label: 'Buzzer',
                active: _isBuzzerOn,
                onTap: () => _onItemTapped(1),
              ),
              _SosActionButton(
                icon: _isFlashOn
                    ? LucideIcons.lightbulb
                    : LucideIcons.lightbulbOff,
                label: 'Flashlight',
                active: _isFlashOn,
                onTap: () => _onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyContactsView extends StatelessWidget {
  const _EmptyContactsView({required this.onAddContact});

  final VoidCallback onAddContact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _sosRedTrack,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.userPlus, size: 28, color: _sosRed),
            ),
            const SizedBox(height: 16),
            Text(
              'No emergency contacts yet',
              style: AppTextStyles.bodyBold(
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a contact so SOS can call and text your location to '
              'someone automatically the next time you need help.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: AppTheme.textMuted(context)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddContact,
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: const Text('Add emergency contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _sosRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SosActionButton extends StatelessWidget {
  const _SosActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _sosRed : AppTheme.textMuted(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.micro(color: color)),
          ],
        ),
      ),
    );
  }
}
