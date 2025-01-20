import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'package:image_viewer_app/assets.dart';
import 'package:image_viewer_app/providers/settings_provider.dart';
import 'package:image_viewer_app/widgets/container/shadow_container.dart';

enum ImageType { folderIcon, folderPreview, oryginalImage }

class ImageLoader extends ConsumerWidget {
  final String? imageCloudId;
  final ImageType imageType;

  const ImageLoader(
      {super.key, this.imageCloudId = "", required this.imageType});

  static Uint8List? _cachedEmptyImage;

  double _getImagePhysicalWidth(double physicalWidth) {
    switch (imageType) {
      case ImageType.folderIcon:
        return physicalWidth / 8;
      case ImageType.folderPreview:
        return physicalWidth / 4;
      case ImageType.oryginalImage:
        return physicalWidth;
    }
  }

  Future<Uint8List> _fetchIconImage(double physicalWidth, String functionsUrl) async {
    String url =
        '$functionsUrl/getResizedImage?pictureId=$imageCloudId&width=$physicalWidth';
    if (functionsUrl.trim().isNotEmpty && imageCloudId!.trim().isNotEmpty) {
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
    final double width = MediaQuery.of(context).size.width;
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double physicalWidth = width * pixelRatio;
    var settings = ref.read(settingsProvider.notifier).settings;
    String functionsUrl = settings[EnvironmentalVariables.functionsUrl.variable]?.asString() ?? "";

    return FutureBuilder<Uint8List>(
      future: _fetchIconImage(
        _getImagePhysicalWidth(physicalWidth),
        functionsUrl
      ),
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
