import 'package:flutter/material.dart';
import 'package:image_viewer_app/assets.dart';
import 'package:image_viewer_app/models/folder_model.dart';
import 'package:image_viewer_app/models/image/image_model.dart';
import 'package:image_viewer_app/permissions/access_checker.dart';
import 'package:image_viewer_app/screens/folders/edit_folder_screen.dart';
import 'package:image_viewer_app/screens/images/add_image_screen.dart';
import 'package:image_viewer_app/screens/images/edit_image_screen.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/shadow_container.dart';

import 'package:image_viewer_app/widgets/image/image_loader.dart';

class FolderScreen extends StatelessWidget {
  final FolderModel folder;

  const FolderScreen({super.key, required this.folder});

  void onDoubleTap(ImageModel image, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditImageScreen(
          image: image,
          folder: folder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => EditFolderScreen(
                        folder: folder,
                      )));
            },
          ),
        ],
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
            ),
            itemCount: folder.images.length,
            itemBuilder: (context, index) {
              return ShadowContainer(
                child: GestureDetector(
                  onDoubleTap: () {
                    onDoubleTap(folder.images[index], context);
                  },
                  child: ImageLoader(
                    imageType: ImageType.folderPreview,
                    imageCloudId: folder.images.isNotEmpty
                        ? folder.images[index].imageCloudId
                        : '',
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton:
          isFeatureAvailable(EnvironmentalVariables.featureAddImage.variable)
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => AddImageScreen(
                          folder: folder,
                        ),
                      ),
                    );
                  },
                  tooltip: 'Add image',
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}
