// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

// class BluetoothChat extends StatefulWidget {
//   Device connected_device;
//   NearbyService nearbyService;
//   var chat_state;

//   BluetoothChat({required this.connected_device, required this.nearbyService});

//   @override
//   State<BluetoothChat> createState() => _BluetoothChatState();
// }

// class _BluetoothChatState extends State<BluetoothChat> {
// late StreamSubscription subscription;
//   late StreamSubscription receivedDataSubscription;
//   List<ChatMessage> messages = [];
//   final myController = TextEditingController();
//   void addMessgeToList(ChatMessage  obj){

//     setState(() {
//       messages.insert(0, obj);
//     });
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     init();
//   }
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     receivedDataSubscription.cancel();
//   }
//   void init(){
//     receivedDataSubscription =
//         this.widget.nearbyService.dataReceivedSubscription(callback: (data) {
//           var obj = ChatMessage(messageContent: data["message"], messageType: "receiver");
//           addMessgeToList(obj);
//         });

//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       appBar: AppBar(

//         elevation: 0,
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.white,
//         flexibleSpace: SafeArea(
//           child: Container(
//             padding: EdgeInsets.only(right: 16),

//             child: Row(

//               children: <Widget>[
//                 IconButton(
//                   onPressed: (){
//                     Navigator.pop(context);
//                   },
//                   icon: Icon(Icons.arrow_back,color: Colors.black,),
//                 ),

//                 SizedBox(width: 12,),
//                 Expanded(
//                   child: Column(

//                     textDirection: TextDirection.rtl,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       SizedBox(height: 5,),
//                       Text(this.widget.connected_device.deviceName,style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
//                       SizedBox(height: 3,),
//                       Text("connected",style: TextStyle(color: Colors.green, fontSize: 13),),
//                     ],
//                   ),
//                 ),

//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: <Widget>[

//           ListView.builder(
//             itemCount: messages.length,
//             shrinkWrap: true,
//             padding: EdgeInsets.only(top: 10,bottom: 10),
//             itemBuilder: (context, index){
//               return Container(
//                 padding: EdgeInsets.only(left: 10,right: 14,top: 10,bottom: 10),
//                 child: Align(
//                   alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Colors.green[300]),
//                     ),
//                     padding: EdgeInsets.all(16),
//                     child: Text(messages[index].messageContent, style: TextStyle(fontSize: 15),),
//                   ),
//                 ),
//               );
//             },
//           ),
//           Align(
//             alignment: Alignment.bottomLeft,
//             child: Container(
//               padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
//               height: 60,
//               width: double.infinity,
//               color: Colors.white,
//               child: Row(
//                 textDirection: TextDirection.rtl,
//                 children: <Widget>[
//                   SizedBox(width: 15,),
//                   Expanded(
//                     child: TextField(
//                       textDirection: TextDirection.rtl,
//                       decoration: InputDecoration(
//                         hintTextDirection: TextDirection.rtl,
//                         hintText: "Type your message here ...",
//                         hintStyle: TextStyle(color: Colors.black54),
//                         border: InputBorder.none,

//                       ),
//                       controller: myController,
//                     ),
//                   ),
//                   SizedBox(width: 15,),
//                   FloatingActionButton(
//                     onPressed: (){
//                         if(this.widget.connected_device.state == SessionState.notConnected) {
//                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                             content: Text("disconnected"),
//                             backgroundColor: Colors.red,
//                           ));
//                           return;
//                         }

//                         this.widget.nearbyService.sendMessage(
//                         this.widget.connected_device.deviceId, myController.text);
//                         var obj = ChatMessage(messageContent: myController.text, messageType: "sender");

//                         addMessgeToList(obj);
//                         myController.text = "";
//                     },
//                     child: Icon(Icons.send,color: Colors.white,size: 18,textDirection: TextDirection.rtl,),
//                     backgroundColor: Colors.green[700],
//                     elevation: 0,
//                   ),
//                 ],

//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage{
//   String messageContent;
//   String messageType;
//   ChatMessage({ required this.messageContent,  required this.messageType});
// }

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothChat extends StatefulWidget {
  final BluetoothDevice connectedDevice;
  final FlutterBlue flutterBlue;

  BluetoothChat({required this.connectedDevice, required this.flutterBlue});

  @override
  State<BluetoothChat> createState() => _BluetoothChatState();
}

class _BluetoothChatState extends State<BluetoothChat> {
  late StreamSubscription<List<int>> subscription;
  List<ChatMessage> messages = [];
  final myController = TextEditingController();

  void addMessageToList(ChatMessage obj) {
    setState(() {
      messages.insert(0, obj);
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void init() async {
    List<BluetoothService> services = await widget.connectedDevice.discoverServices();
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.properties.read) {
        await characteristic.read();
      }
      if (characteristic.properties.write) {
        // Handle write operations if needed
      }
      if (characteristic.properties.notify || characteristic.properties.indicate) {
        // Listen to notifications or indications
        characteristic.setNotifyValue(true);
        subscription = characteristic.value.listen((value) {
          var obj = ChatMessage(messageContent: String.fromCharCodes(value), messageType: "receiver");
          addMessageToList(obj);
        });
      }
    }
  }
  }

  void sendMessage(String message) async {
  List<BluetoothService> services = await widget.connectedDevice.discoverServices();
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.properties.write) {
        // Use the characteristic to write the message
        await characteristic.write(message.codeUnits, withoutResponse: true);
        return;
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 5,),
                      Text(widget.connectedDevice.name ?? "", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                      SizedBox(height: 3,),
                      Text("connected", style: TextStyle(color: Colors.green, fontSize: 13),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(left: 10, right: 14, top: 10, bottom: 10),
                child: Align(
                  alignment: (messages[index].messageType == "receiver" ? Alignment.topLeft : Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].messageType == "receiver" ? Colors.grey.shade200 : Colors.green[300]),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(messages[index].messageContent, style: TextStyle(fontSize: 15),),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                textDirection: TextDirection.rtl,
                children: <Widget>[
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintTextDirection: TextDirection.rtl,
                        hintText: "Type your message here ...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                      controller: myController,
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: () {
                      if (widget.connectedDevice.state == BluetoothDeviceState.disconnected) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Disconnected"),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }

                      sendMessage(myController.text);
                      var obj = ChatMessage(messageContent: myController.text, messageType: "sender");
                      addMessageToList(obj);
                      myController.text = "";
                    },
                    child: Icon(Icons.send, color: Colors.white, size: 18, textDirection: TextDirection.rtl,),
                    backgroundColor: Colors.green[700],
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  String messageContent;
  String messageType;

  ChatMessage({required this.messageContent, required this.messageType});
}

