import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          Vibration.vibrate();
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
    Vibration.vibrate();

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
    String name = '';
    String phone = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onChanged: (value) => phone = value,
                keyboardType: const TextInputType.numberWithOptions(),
              ),
            ],
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
                setState(() {
                  _emergencyContacts.add({'name': name, 'phone': phone});
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Emergency SOS'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isCancelled) // Show the timer if not cancelled
              Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 20,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.error),
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Text(
                            '${(_durationInSeconds - (_progress * _durationInSeconds)).floor()}',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SlideAction(
                      sliderButtonIcon: const FaIcon(FontAwesomeIcons.xmark),
                      height: 80,
                      borderRadius: 12,
                      elevation: 0,
                      innerColor: Theme.of(context).colorScheme.error,
                      outerColor: Theme.of(context).colorScheme.errorContainer,
                      animationDuration: const Duration(milliseconds: 500),
                      text: 'Slide to Cancel',
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
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
            if (_isCancelled)
              Expanded(
                child: ReorderableListView(
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
                        (entry) => ListTile(
                          key: ValueKey(entry.key),
                          leading: const FaIcon(
                            FontAwesomeIcons.gripVertical,
                            size: 15,
                          ),
                          title: Row(
                            children: [
                              Text(entry.value['name']!),
                              if (entry.key == 0) const SizedBox(width: 5),
                              if (entry.key == 0)
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ), // First contact is auto-dialed on trigger
                            ],
                          ),
                          subtitle: Text(entry.value['phone']!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.location_on_outlined),
                                tooltip: 'Text my location',
                                onPressed: () {
                                  _shareLocationViaSms(entry.value['phone']!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.phone),
                                onPressed: () {
                                  _callNumber(entry.value['phone']!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
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
              )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SosActionButton(
                icon: FontAwesomeIcons.userPlus,
                label: 'Add contact',
                active: false,
                onTap: () => _onItemTapped(0),
              ),
              _SosActionButton(
                icon: FontAwesomeIcons.bullhorn,
                label: 'Buzzer',
                active: _isBuzzerOn,
                onTap: () => _onItemTapped(1),
              ),
              _SosActionButton(
                icon: _isFlashOn
                    ? FontAwesomeIcons.solidLightbulb
                    : FontAwesomeIcons.lightbulb,
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

  final FaIconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = active ? colorScheme.error : colorScheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
