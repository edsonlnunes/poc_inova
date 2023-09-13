import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

const String serverUrl = 'ws://1.7.0.1:8787';

class SocketUploader {
  Socket? _channel;

  SocketUploader([String? url]);

  void connectWebSocket() async {
    _channel = await Socket.connect('1.7.0.1', 8787);
    _channel!.listen(
      (event) {
        log("Chamou o listen");
        print('${event.buffer.asInt16List()}');
      },
    );
  }

  Future<void> uploadFile(List<List<int>> chunks) async {
    try {
      // set config
      _channel!.add(Uint8List.fromList([
        0x43,
        0x00,
        0x0e,
        0x03,
        0xff,
        0x00,
        0x00,
        0x00,
        0x00,
        0xb9,
        0x8e,
        0xe3,
        0x03,
        0xe4,
        0x22,
        0xa8,
        0xa2,
        0x2e
      ]));

      await Future.delayed(Duration(milliseconds: 500));

      _channel!.add(Uint8List.fromList([
        0x57,
        0x00,
        0x1e,
        0x00,
        0x00,
        0x0b,
        0xcc,
        0x54,
        0x45,
        0x53,
        0x54,
        0x45,
        0x5f,
        0x44,
        0x45,
        0x5f,
        0x4c,
        0x45,
        0x44,
        0x5f,
        0x38,
        0x5f,
        0x31,
        0x31,
        0x5f,
        0x31,
        0x33,
        0x5f,
        0x31,
        0x2e,
        0x69,
        0x73,
        0x69,
        0x2e
      ]));

      for (var i = 0; i < chunks.length; i++) {
        await Future.delayed(Duration(milliseconds: 500));
        final chunk = chunks[i];

        final payloadLenght = chunk.length + 2;
        log('payloadLenght: ${payloadLenght}');

        final payloadLenghtHex =
            payloadLenght.toRadixString(16).padLeft(4, '0');

        log('payload hex: ${payloadLenghtHex}');

        final firstByte = int.parse(payloadLenghtHex.substring(0, 2));
        log('firstByte: ${firstByte}');

        final secondByte = int.parse(payloadLenghtHex.substring(2));
        log('secondByte: ${secondByte}');

        final teste = Uint8List.fromList(
            [0x44, firstByte, secondByte, 0x00, i, ...chunk, 0x2e]);
        await _sendChunkWithTimeout(teste);
      }

      _channel!.add(Uint8List.fromList([
        0x57,
        0x00,
        0x04,
        0x00,
        0x00,
        0x00,
        0x00,
        0x2e,
      ]));
      log('File sent successfully.');
    } catch (e) {
      log('Error occurred while sending the file: $e');
    }
  }

  void closeConnection() async {
    await _channel!.close();
    _channel = null;
  }

  Future<void> _sendChunkWithTimeout(Uint8List chunk) async {
    const timeoutDuration = Duration(seconds: 5);

    try {
      _channel!.timeout(timeoutDuration);
      _channel!.add(chunk);
      log('Chunk sent successfully.');
    } on TimeoutException {
      throw TimeoutException('Sending chunk timed out.');
    } catch (e) {
      throw Exception('Error sending chunk: $e');
    }
  }
}
