import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:flutter/material.dart';

import '../pages/BluetoothChat.dart';
import '../pages/BluetoothChatScreen.dart';

class BtScreen extends StatefulWidget {
  const BtScreen({super.key});

  @override
  State<BtScreen> createState() => _BtScreenState();
}

final allBluetooth = AllBluetooth();

class _BtScreenState extends State<BtScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: allBluetooth.listenForConnection,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result?.state == true) {
            return const BluetoothChatScreen();
          }
          return const BluetoothChat();
        });
  }
}
