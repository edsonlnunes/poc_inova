import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

const String serverUrl = 'ws://1.7.0.1:8787';

class WebSocketUploader {
  WebSocketChannel? _channel;

  WebSocketUploader([String? url]);

  void connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
  }

  Future<void> uploadFile(List<List<int>> chunks) async {
    await _channel!.ready;
    try {
      for (final chunk in chunks) {
        await _sendChunkWithTimeout(chunk);
      }
      print('File sent successfully.');
    } catch (e) {
      print('Error occurred while sending the file: $e');
    } finally {
      _channel!.sink.close();
    }
  }

  Future<void> _sendChunkWithTimeout(List<int> chunk) async {
    const timeoutDuration = Duration(seconds: 5);

    try {
      _channel!.stream.timeout(timeoutDuration);
      _channel!.sink.add(chunk);
      print('Chunk sent successfully.');
    } on TimeoutException {
      throw TimeoutException('Sending chunk timed out.');
    } catch (e) {
      throw Exception('Error sending chunk: $e');
    }
  }
}
