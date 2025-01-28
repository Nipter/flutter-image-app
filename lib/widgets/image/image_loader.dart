import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'package:image_viewer_app/assets.dart';
import 'package:image_viewer_app/widgets/container/shadow_container.dart';

enum ImageType { folderIcon, folderPreview, screenSize, oryginalImage }

class ImageLoader extends ConsumerWidget {
  final String? imageCloudId;
  final ImageType imageType;

  const ImageLoader(
      {super.key, this.imageCloudId = "", required this.imageType});

  static Uint8List? _cachedEmptyImage;

  static double _getImagePhysicalWidth(
      BuildContext context, ImageType imageType) {
    final double width = MediaQuery.of(context).size.width;
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double physicalWidth = width * pixelRatio;

    switch (imageType) {
      case ImageType.folderIcon:
        return physicalWidth / 8;
      case ImageType.folderPreview:
        return physicalWidth / 4;
      case ImageType.oryginalImage:
        return physicalWidth;
      case ImageType.screenSize:
        return 0;
    }
  }

  static Future<Uint8List> fetchImage(
      BuildContext context, String? imageCloudId, ImageType imageType) async {
    double physicalWidth = _getImagePhysicalWidth(context, imageType);
    //TODO: get url from settingsProvider
    String url =
        'http://127.0.0.1:5001/testproject1-cda8a/us-central1/getResizedImage?pictureId=$imageCloudId&width=$physicalWidth';
    if (url.trim().isNotEmpty && imageCloudId!.trim().isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(url),
        );

        if (response.statusCode == 200) {
          return response.bodyBytes;
        } else {
          throw Exception('Error while fetching image');
        }
      } catch (e) {
        throw Exception(
            'Error while fetching image. Please try again or contact administrators.');
      }
    } else {
      if (_cachedEmptyImage == null) {
        final byteData = await rootBundle.load(Images.empty_folder.path);
        _cachedEmptyImage = byteData.buffer.asUint8List();
      }
      return _cachedEmptyImage!;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Uint8List>(
      future: fetchImage(context, imageCloudId, imageType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          return Center(
            child: ShadowContainer(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Image not found'),
          );
        }
      },
    );
  }
}
