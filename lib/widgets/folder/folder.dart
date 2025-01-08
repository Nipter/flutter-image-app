import 'package:flutter/material.dart';
import 'package:image_viewer_app/models/folder_model.dart';
import 'package:image_viewer_app/screens/folders/folder_screen.dart';
import 'package:image_viewer_app/widgets/container/shadow_container.dart';
import 'package:image_viewer_app/widgets/image/image_loader.dart';

class Folder extends StatelessWidget {
  final FolderModel folder;

  const Folder({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        10,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => FolderScreen(
                folder: folder,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadowContainer(
              width: 150,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ImageLoader(
                  imageType: ImageType.folderIcon,
                  imageCloudId: folder.images.isNotEmpty
                      ? folder.images[0].imageCloudId
                      : '',
                ),
              ),
            ),
            Text(
              folder.name.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            Text(
              '${folder.images.length}',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
          ],
        ),
      ),
    );
  }
}
