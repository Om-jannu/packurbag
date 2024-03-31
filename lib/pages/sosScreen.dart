import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({Key? key}) : super(key: key);

  @override
  _SosScreenState createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  late Timer _timer;
  final int _durationInSeconds = 10; // Duration for the SOS timer in seconds
  double _progress = 0.0;
  bool _isCancelled = false;
  bool _isBuzzerOn = false; // Track the state of the buzzer
  bool _isFlashOn = false; // Track the state of the flashlight
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
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
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          // Add contact tab
          _showAddContactDialog();
          break;
        case 1:
          // Buzzer tab
          _toggleBuzzer();
          break;
        case 2:
          // Flashlight tab
          _toggleFlash();
          break;
      }
    });
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

  _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  void _triggerSOS() {
    Vibration.vibrate();

    if (_emergencyContacts.isNotEmpty) {
      _callNumber(_emergencyContacts[0]['phone']!);
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
    Timer _flashTimer =
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
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              size: 20,
              color: Colors.red,
            ),
            SizedBox(
              width: 8,
            ),
            Text('Emergency SOS'),
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
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.red),
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Text(
                            '${(_durationInSeconds - (_progress * _durationInSeconds)).floor()}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                      innerColor: Colors.red,
                      outerColor: Colors.red[100],
                      animationDuration: const Duration(milliseconds: 500),
                      text: 'Slide to Cancel',
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
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
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
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
                              if (entry.key == 0)
                                const SizedBox(
                                    width:
                                        5), // Add spacing between text and icon
                              if (entry.key == 0)
                                const FaIcon(
                                  FontAwesomeIcons.star,
                                  size: 12,
                                  color: Colors.amber,
                                ), // Show star icon for the first contact
                            ],
                          ),
                          subtitle: Text(entry.value['phone']!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.userPlus,
              size: 18.0,
            ),
            label: 'Add contact',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.bullhorn,
              color: _isBuzzerOn ? Colors.red : Colors.grey,
              size: 18.0,
            ),
            label: 'Buzzer',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              _isFlashOn
                  ? FontAwesomeIcons.solidLightbulb
                  : FontAwesomeIcons.lightbulb,
              color: _isFlashOn ? Colors.yellow : Colors.grey,
              size: 18.0,
            ),
            label: 'Flashlight',
          ),
        ],
      ),
    );
  }
}
