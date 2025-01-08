import 'dart:typed_data';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class ImageInputModel {
  final String id;
  String name;
  final Uint8List imageBytes;

  ImageInputModel({
    required this.name,
    required this.imageBytes,
  }) : id = uuid.v4();
}
