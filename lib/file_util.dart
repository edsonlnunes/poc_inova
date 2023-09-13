import 'dart:developer';
import 'dart:io';

class FileUtil {
  Future<List<List<int>>> splitFileIntoChunks(File file, int chunkSize) async {
    final List<List<int>> chunks = [];

    final bytes = await file.readAsBytes();

    if (bytes.length <= chunkSize) {
      final fileBytes = await file.readAsBytes();
      chunks.add(fileBytes);
    } else {
      final totalChunks = (bytes.length / chunkSize).ceil();
      log('total: $totalChunks');

      final fileStream = file.openRead();

      int chunkIndex = 0;

      await for (final chunk in fileStream) {
        final currentChunk = chunk.sublist(0, chunkSize);
        chunks.add(currentChunk);
        chunkIndex++;

        if (chunkIndex == totalChunks) {
          break;
        }
      }
    }

    return chunks;
  }
}
