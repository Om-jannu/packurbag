import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:all_bluetooth/all_bluetooth.dart';

import '../screens/BtScreen.dart';

class BluetoothChat extends StatefulWidget {
  const BluetoothChat({super.key});

  @override
  State<BluetoothChat> createState() => _BluetoothChatState();
}

class _BluetoothChatState extends State<BluetoothChat> {
  final bondedDevice = ValueNotifier<List<BluetoothDevice>>([]);
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    Future.wait([
      Permission.bluetooth.request(),
      Permission.bluetoothScan.request(),
      Permission.bluetoothConnect.request(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: allBluetooth.streamBluetoothState,
      builder: (context, snapshot) {
        final bluetoothOn = snapshot.data ?? false;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Bluetooth Connect"),
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
          floatingActionButton: isListening
              ? null
              : FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: bluetoothOn
                      ? () {
                          allBluetooth.startBluetoothServer();
                          setState(() => isListening = true);
                        }
                      : null,
                  child: !bluetoothOn
                      ? const FaIcon(
                          FontAwesomeIcons.ban,
                          color: Colors.grey,
                        )
                      : const Icon(Icons.bluetooth_searching),
                ),
          body: isListening
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Listening for Connections",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          allBluetooth.closeConnection();
                          setState(() {
                            isListening = false;
                          });
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text("Stop Listening"),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Bluetooth ${bluetoothOn ? 'ON' : 'OFF'}",
                            style: TextStyle(
                              color: bluetoothOn ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: bluetoothOn
                                ? () async {
                                    final devices =
                                        await allBluetooth.getBondedDevices();
                                    bondedDevice.value = devices;
                                  }
                                : null,
                            child: const Text("Available Devices"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!bluetoothOn)
                        const Center(
                          child: Text("Turn Bluetooth on to continue"),
                        ),
                      ValueListenableBuilder(
                        valueListenable: bondedDevice,
                        builder: (context, devices, child) {
                          if (!bluetoothOn || devices.isEmpty) {
                            return const Center(
                              child: Text(
                                "No devices found",
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }

                          return Expanded(
                            child: ListView.builder(
                              itemCount: devices.length,
                              itemBuilder: (context, index) {
                                final device = devices[index];
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.bluetooth),
                                    title: Text(device.name),
                                    subtitle: Text(device.address),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.link),
                                      onPressed: () {
                                        allBluetooth
                                            .connectToDevice(device.address);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
