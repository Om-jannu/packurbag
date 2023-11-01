// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class BluetoothChatScreen extends StatefulWidget {
//   BluetoothChatScreen({Key? key}) : super(key: key);

//   final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
//   final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
//   final TextEditingController _writeController = TextEditingController();

//   @override
//   BluetoothChatScreenState createState() => BluetoothChatScreenState();
// }

// class BluetoothChatScreenState extends State<BluetoothChatScreen> {
//   BluetoothDevice? _connectedDevice;
//   List<BluetoothService> _services = [];

//   void _addDeviceToList(final BluetoothDevice device) {
//     if (!widget.devicesList.contains(device)) {
//       setState(() {
//         widget.devicesList.add(device);
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     FlutterBluePlus.connectedSystemDevices.asStream().listen((List<BluetoothDevice> devices) {
//       for (BluetoothDevice device in devices) {
//         _addDeviceToList(device);
//       }
//     });
//     FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
//       for (ScanResult result in results) {
//         _addDeviceToList(result.device);
//       }
//     });
//     FlutterBluePlus.startScan();
//   }

//   @override
//   void dispose() {
//     widget._writeController.dispose();
//     FlutterBluePlus.stopScan();
//     FlutterBluePlus.connectedSystemDevices.asStream().listen((devices) {
//       for (BluetoothDevice device in devices) {
//         device.disconnect();
//       }
//     });
//     super.dispose();
//   }

//   List<ButtonTheme> _buildReadWriteNotifyButton(BluetoothCharacteristic characteristic) {
//     List<ButtonTheme> buttons = <ButtonTheme>[];

//     if (characteristic.properties.read) {
//       buttons.add(
//         ButtonTheme(
//           minWidth: 10,
//           height: 20,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: TextButton(
//               child: const Text('READ', style: TextStyle(color: Colors.white)),
//               onPressed: () async {
//                 var sub = characteristic.value.listen((value) {
//                   setState(() {
//                     widget.readValues[characteristic.uuid] = value;
//                   });
//                 });
//                 await characteristic.read();
//                 sub.cancel();
//               },
//             ),
//           ),
//         ),
//       );
//     }
//     if (characteristic.properties.write) {
//       buttons.add(
//         ButtonTheme(
//           minWidth: 10,
//           height: 20,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: ElevatedButton(
//               child: const Text('WRITE', style: TextStyle(color: Colors.white)),
//               onPressed: () async {
//                 await showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Text("Write"),
//                       content: Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: TextField(
//                               controller: widget._writeController,
//                             ),
//                           ),
//                         ],
//                       ),
//                       actions: <Widget>[
//                         TextButton(
//                           child: const Text("Send"),
//                           onPressed: () {
//                             characteristic.write(utf8.encode(widget._writeController.value.text));
//                             Navigator.pop(context);
//                           },
//                         ),
//                         TextButton(
//                           child: const Text("Cancel"),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//       );
//     }
//     if (characteristic.properties.notify) {
//       buttons.add(
//         ButtonTheme(
//           minWidth: 10,
//           height: 20,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: ElevatedButton(
//               child: const Text('NOTIFY', style: TextStyle(color: Colors.white)),
//               onPressed: () async {
//                 characteristic.value.listen((value) {
//                   setState(() {
//                     widget.readValues[characteristic.uuid] = value;
//                   });
//                 });
//                 await characteristic.setNotifyValue(true);
//               },
//             ),
//           ),
//         ),
//       );
//     }

//     return buttons;
//   }

//   ListView _buildConnectDeviceView() {
//     List<Widget> containers = <Widget>[];

//     for (BluetoothService service in _services) {
//       List<Widget> characteristicsWidget = <Widget>[];

//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         characteristicsWidget.add(
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     Text(characteristic.uuid.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 Row(
//                   children: <Widget>[
//                     ..._buildReadWriteNotifyButton(characteristic),
//                   ],
//                 ),
//                 Row(
//                   children: <Widget>[
//                     Text('Value: ${widget.readValues[characteristic.uuid]}'),
//                   ],
//                 ),
//                 const Divider(),
//               ],
//             ),
//           ),
//         );
//       }
//       containers.add(
//         ExpansionTile(
//           title: Text(service.uuid.toString()),
//           children: characteristicsWidget,
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(8),
//       children: <Widget>[
//         ...containers,
//       ],
//     );
//   }

//   ListView _buildListViewOfDevices() {
//     List<Widget> containers = <Widget>[];
//     for (BluetoothDevice device in widget.devicesList) {
//       containers.add(
//         SizedBox(
//           height: 50,
//           child: Row(
//             children: <Widget>[
//               Expanded(
//                 child: Column(
//                   children: <Widget>[
//                     Text(device.name == '' ? '(unknown device)' : device.name),
//                     Text(device.id.toString()),
//                   ],
//                 ),
//               ),
//               TextButton(
//                 child: const Text('Connect', style: TextStyle(color: Colors.white)),
//                 onPressed: () async {
//                   FlutterBluePlus.stopScan();
//                   try {
//                     await device.connect();
//                   } on PlatformException catch (e) {
//                     if (e.code != 'already_connected') {
//                       rethrow;
//                     }
//                   } finally {
//                     _services = await device.discoverServices();
//                   }
//                   setState(() {
//                     _connectedDevice = device;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(8),
//       children: <Widget>[
//         ...containers,
//       ],
//     );
//   }

//   ListView _buildView() {
//     if (_connectedDevice != null) {
//       return _buildConnectDeviceView();
//     }
//     return _buildListViewOfDevices();
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: _buildView(),
//       );
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothChatScreen extends StatefulWidget {
  BluetoothChatScreen({Key? key}) : super(key: key);

  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  final TextEditingController _writeController = TextEditingController();

  @override
  BluetoothChatScreenState createState() => BluetoothChatScreenState();
}

class BluetoothChatScreenState extends State<BluetoothChatScreen> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  void _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    widget.devicesList.clear(); // Clear existing devices
    FlutterBluePlus.startScan(); // Start scanning for devices

    // Listen for scan results
    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
  }

  @override
  void dispose() {
    widget._writeController.dispose();
    FlutterBluePlus.stopScan();
    FlutterBluePlus.connectedSystemDevices.asStream().listen((devices) {
      for (BluetoothDevice device in devices) {
        device.disconnect();
      }
    });
    super.dispose();
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = <ButtonTheme>[];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              child: const Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: const Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Write"),
                      content: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: widget._writeController,
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Send"),
                          onPressed: () {
                            characteristic.write(utf8
                                .encode(widget._writeController.value.text));
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child:
                  const Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Widget> containers = <Widget>[];

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = <Widget>[];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Value: ${widget.readValues[characteristic.uuid]}'),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        ExpansionTile(
          title: Text(service.uuid.toString()),
          children: characteristicsWidget,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              TextButton(
                child: const Text('Connect',
                    style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  FlutterBluePlus.stopScan();
                  try {
                    await device.connect();
                  } on PlatformException catch (e) {
                    if (e.code != 'already_connected') {
                      rethrow;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }
                  setState(() {
                    _connectedDevice = device;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Bluetooth Chat'),
          actions: [
            ElevatedButton(
              onPressed: () {
                _startScan(); // Function to start scanning for devices
              },
              child: Text('Send'),
            ),
            ElevatedButton(
              onPressed: () {
                _startScan(); // Function to start scanning for devices
              },
              child: Text('Receive'),
            ),
          ],
        ),
        body: _buildView(),
      );
}
