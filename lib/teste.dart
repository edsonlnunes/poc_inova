import 'dart:typed_data';

void main() {
  final chunkSize = 500;
  final index = 2;

  Uint16List byteArray = Uint16List(1);
  byteArray[0] = chunkSize + index;
  final x = chunkSize + index;

  print(x.toRadixString(16));
}
