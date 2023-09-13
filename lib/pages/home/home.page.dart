import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:poc_inova/controllers/wifi.controller.dart';
import 'package:poc_inova/file_util.dart';

import '../../socket_uploader.dart';

class HomePage extends StatelessWidget {
  final webSocketUploader = SocketUploader();

  Future<void> sendFile(BuildContext ctx) async {
    // final urlController = TextEditingController();
    // final url = await showDialog<String>(
    //   context: ctx,
    //   builder: (_) {
    //     return AlertDialog(
    //       content: SizedBox(
    //         width: MediaQuery.sizeOf(ctx).width,
    //         child: TextField(
    //           controller: urlController,
    //           decoration: const InputDecoration(
    //             border: OutlineInputBorder(),
    //             hintText: "URL",
    //           ),
    //         ),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(ctx, urlController.text),
    //           child: const Text("Definir"),
    //         ),
    //         TextButton(
    //           onPressed: () => Navigator.pop(ctx),
    //           child: const Text("Nao definir"),
    //         ),
    //       ],
    //     );
    //   },
    // );

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final chunks = await FileUtil().splitFileIntoChunks(
        File(result.files.single.path!),
        1024,
      );

      await webSocketUploader.uploadFile(chunks);
    }
  }

  Future<void> getWifiInfo(BuildContext ctx) async {
    final ssidController = TextEditingController(text: "Test_NDrive");
    final passController = TextEditingController(text: "87654321");
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ssidController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Wifi",
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              TextField(
                controller: passController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    final controller = WifiController();
                    controller.connectToHardwareWiFi(
                      ssid: ssidController.text,
                      pass: passController.text,
                    );
                  },
                  child: const Text("Conectar"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: () async {
                  final wifi = WifiController();
                  await wifi.disconnectToHardwareWiFi();
                },
                child: const Text("Desconectar do wifi"),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: () async {
                  getWifiInfo(context);
                },
                child: const Text("Conectar no wifi"),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: () => sendFile(context),
                child: const Text("Enviar arquivo"),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: () => webSocketUploader.closeConnection(),
                child: const Text("Fechar websocket"),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: () => webSocketUploader.connectWebSocket(),
                child: const Text("Conectar websocket"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
