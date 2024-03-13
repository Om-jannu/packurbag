import 'package:flutter/material.dart';
import 'package:pub/screens/BluetoothChat.dart';
import 'package:pub/screens/BluetoothChatScreen.dart';

import '../main.dart';

class BtScreen extends StatefulWidget {
  const BtScreen({super.key});

  @override
  State<BtScreen> createState() => _BtScreenState();
}

class _BtScreenState extends State<BtScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
          stream: allBluetooth.listenForConnection,
          builder: (context, snapshot) {
            final result = snapshot.data;
            if (result?.state == true) {
              return const BluetoothChatScreen();
            }
            return const BluetoothChat();
          }),
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
