import 'package:flutter/material.dart';

import '../main.dart';
import '../pages/BluetoothChat.dart';
import '../pages/BluetoothChatScreen.dart';

class BtScreen extends StatefulWidget {
  const BtScreen({super.key});

  @override
  State<BtScreen> createState() => _BtScreenState();
}

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
