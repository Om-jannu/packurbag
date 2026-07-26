import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Literal reds matching the design reference's `red-500`/`red-100` (this
/// screen reads as an alert, so it intentionally uses a literal red rather
/// than the brand's coral/teal roles).
const _sosRed = Color(0xFFEF4444);
const _sosRedTrack = Color(0xFFFEE2E2);

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  late Timer _timer;
  final int _durationInSeconds = 10; // Duration for the SOS timer in seconds
  double _progress = 0.0;
  bool _isCancelled = false;
  bool _isBuzzerOn = false; // Track the state of the buzzer
  bool _isFlashOn = false; // Track the state of the flashlight
  final player = AudioPlayer();
  final torchController = TorchController();

  List<Map<String, String>> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    // Start the SOS timer
    _startTimer();
    _loadEmergencyContacts();
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer when the screen is disposed
    _timer.cancel();
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
      if (!_isCancelled) {
        setState(() {
          _progress = timer.tick / _durationInSeconds;
          Vibration.vibrate().catchError((_) {});
          if (timer.tick == _durationInSeconds) {
            _triggerSOS();
          }
        });
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  /// Grabs the current position (best-effort — this must never block or
  /// fail the SOS flow itself) and texts a Google Maps link to [number].
  Future<void> _shareLocationViaSms(String number) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final mapsLink =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      final smsUri = Uri(
        scheme: 'sms',
        path: number,
        queryParameters: {'body': "I need help. My location: $mapsLink"},
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (_) {
      // Best-effort only — a failure here shouldn't interrupt the SOS flow.
    }
  }

  void _triggerSOS() {
    Vibration.vibrate().catchError((_) {});

    if (_emergencyContacts.isNotEmpty) {
      final phone = _emergencyContacts[0]['phone']!;
      _callNumber(phone);
      _shareLocationViaSms(phone);
    }

    setState(() {
      _isCancelled = true;
    });
  }

  void _toggleBuzzer() async {
    setState(() {
      _isBuzzerOn = !_isBuzzerOn;
    });

    if (_isBuzzerOn) {
      // Start playing the buzzer sound repeatedly
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
    // Start a timer to toggle the flashlight every 500 milliseconds
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isFlashOn) {
        // If flashlight is turned off externally, cancel the timer
        timer.cancel();
      } else {
        torchController.toggle();
      }
    });
  }

  void _stopFlashToggle() async {
    // Cancel the flashlight toggle timer
    bool? flashInstance = await torchController.isTorchActive;
    if (flashInstance!) {
      torchController.toggle();
    }
  }

  Future<void> _loadEmergencyContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? contacts = prefs.getStringList('emergencyContacts');
    if (contacts != null) {
      setState(() {
        _emergencyContacts = contacts
            .map((contact) => Map<String, String>.from(contact
                .split(',')
                .asMap()
                .map((i, e) => MapEntry(i == 0 ? 'name' : 'phone', e))))
            .toList();
      });
    }
  }

  Future<void> _saveEmergencyContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contacts = _emergencyContacts
        .map((contact) => '${contact['name']},${contact['phone']}')
        .toList();
    prefs.setStringList('emergencyContacts', contacts);
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
                  keyboardType: const TextInputType.numberWithOptions(),
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
    final remaining =
        (_durationInSeconds - (_progress * _durationInSeconds)).floor();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: Icon(LucideIcons.arrowLeft, size: 20, color: AppTheme.textPrimary(context)),
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
                    style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !_isCancelled
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
                                  valueColor: AlwaysStoppedAnimation<Color>(_sosRedTrack),
                                ),
                                CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 20,
                                  valueColor: const AlwaysStoppedAnimation<Color>(_sosRed),
                                  strokeCap: StrokeCap.round,
                                ),
                                Center(
                                  child: Text(
                                    '$remaining',
                                    style: AppTextStyles.display(color: AppTheme.textPrimary(context))
                                        .copyWith(fontSize: 40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Calling your emergency contact in ${remaining}s',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(color: AppTheme.textMuted(context)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SlideAction(
                              sliderButtonIcon: const Icon(LucideIcons.x, color: Colors.white),
                              height: 60,
                              borderRadius: AppTheme.radiusMd,
                              elevation: 0,
                              innerColor: _sosRed,
                              outerColor: _sosRedTrack,
                              animationDuration: const Duration(milliseconds: 500),
                              text: 'Slide to Cancel',
                              textStyle: AppTextStyles.bodyBold(color: _sosRed)
                                  .copyWith(fontStyle: FontStyle.italic),
                              onSubmit: () {
                                setState(() {
                                  _isCancelled = true;
                                });
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          final item = _emergencyContacts.removeAt(oldIndex);
                          _emergencyContacts.insert(newIndex, item);
                          _saveEmergencyContacts();
                        });
                      },
                      children: _emergencyContacts
                          .asMap()
                          .entries
                          .map(
                            (entry) => Container(
                              key: ValueKey(entry.key),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: AppTheme.flatCard(context),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: entry.key,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        LucideIcons.gripVertical,
                                        size: 18,
                                        color: AppTheme.textMuted(context),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                entry.value['name']!,
                                                style: AppTextStyles.bodyBold(
                                                    color: AppTheme.textPrimary(context)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (entry.key == 0) const SizedBox(width: 5),
                                            if (entry.key == 0)
                                              const Icon(
                                                LucideIcons.star,
                                                size: 16,
                                                color: AppTheme.amber,
                                              ), // First contact is auto-dialed on trigger
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          entry.value['phone']!,
                                          style: AppTextStyles.caption(color: AppTheme.textMuted(context)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(LucideIcons.mapPin,
                                        color: AppTheme.textMuted(context)),
                                    tooltip: 'Text my location',
                                    onPressed: () {
                                      _shareLocationViaSms(entry.value['phone']!);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(LucideIcons.phone, color: AppTheme.textMuted(context)),
                                    onPressed: () {
                                      _callNumber(entry.value['phone']!);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(LucideIcons.trash2, color: AppTheme.textMuted(context)),
                                    onPressed: () {
                                      _showDeleteContactDialog(entry.key);
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.borderMuted(context))),
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
                icon: _isFlashOn ? LucideIcons.lightbulb : LucideIcons.lightbulb,
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
