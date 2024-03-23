import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:all_bluetooth/all_bluetooth.dart';

import '../main.dart';

class BluetoothChat extends StatefulWidget {
  const BluetoothChat({super.key});

  @override
  State<BluetoothChat> createState() => _BluetoothChatState();
}

class _BluetoothChatState extends State<BluetoothChat> {
  final bondedDevice = ValueNotifier(<BluetoothDevice>[]);

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
            ),
            floatingActionButton: switch (isListening) {
              true => null,
              false => FloatingActionButton(
                  onPressed: switch (bluetoothOn) {
                    false => null,
                    true => () {
                        allBluetooth.startBluetoothServer();
                        setState(() => isListening = true);
                      },
                  },
                  child: const Icon(Icons.wifi_tethering),
                ),
            },
            body: isListening
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Listening for Connections"),
                        const CircularProgressIndicator(),
                        FloatingActionButton(
                          child: const Icon(Icons.stop),
                          onPressed: () {
                            allBluetooth.closeConnection();
                            setState(() {
                              isListening = false;
                            });
                          },
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              switch (bluetoothOn) {
                                true => "ON",
                                false => "OFF",
                              },
                              style: TextStyle(
                                  color:
                                      bluetoothOn ? Colors.green : Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: switch (bluetoothOn) {
                                false => null,
                                true => () async {
                                    final devices =
                                        await allBluetooth.getBondedDevices();
                                    bondedDevice.value = devices;
                                  },
                              },
                              child: const Text("Available Devices"),
                            ),
                          ],
                        ),
                        if (!bluetoothOn)
                          const Center(
                            child: Text("Turn bluetooth on"),
                          ),
                        ValueListenableBuilder(
                            valueListenable: bondedDevice,
                            builder: (context, devices, child) {
                              // Check if Bluetooth is off
                              if (!bluetoothOn) {
                                return Container(); // Return an empty container
                              }

                              // If Bluetooth is on, build the list of devices
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: bondedDevice.value.length,
                                  itemBuilder: (context, index) {
                                    final device = devices[index];
                                    return ListTile(
                                      title: Text(device.name),
                                      subtitle: Text(device.address),
                                      onTap: () {
                                        allBluetooth
                                            .connectToDevice(device.address);
                                      },
                                    );
                                  },
                                ),
                              );
                            })
                      ],
                    ),
                  ),
          );
        });
  }
}
