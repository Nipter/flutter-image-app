import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/assets.dart';
import 'package:image_viewer_app/models/folder_model.dart';
import 'package:image_viewer_app/models/image/image_model.dart';
import 'package:image_viewer_app/providers/settings_provider.dart';
import 'package:image_viewer_app/screens/folders/edit_folder_screen.dart';
import 'package:image_viewer_app/screens/images/add_image_screen.dart';
import 'package:image_viewer_app/screens/images/edit_image_screen.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/shadow_container.dart';

import 'package:image_viewer_app/widgets/image/image_loader.dart';

class FolderScreen extends StatefulWidget {
  final FolderModel folder;

  const FolderScreen({super.key, required this.folder});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  String _searchQuery = "";
  late List<ImageModel> _searchImages;

  void onDoubleTap(ImageModel image, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditImageScreen(
          image: image,
          folder: widget.folder,
        ),
      ),
    );
  }

  void onSearchButton(String text) {
    setState(() {
      _searchImages = widget.folder.images
          .where((image) => image.name.contains(_searchQuery))
          .toList();

      print(_searchImages.length);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchImages = widget.folder.images;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
      var settings = ref.read(settingsProvider.notifier).settings;
      var showAddImageScreen = settings[EnvironmentalVariables.featureAddImage.variable]?.asBool() ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        flexibleSpace: Align(
          alignment: Alignment.center,
          child: kIsWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: TextField(
                        onChanged: (text) {
                          _searchQuery = text;
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        onSearchButton(_searchQuery);
                      },
                    ),
                  ],
                )
              : null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => EditFolderScreen(
                        folder: widget.folder,
                      )));
            },
          ),
        ],
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            if (!kIsWeb)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 70,
                      child: TextField(
                        onChanged: (text) {
                          _searchQuery = text;
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        onSearchButton(_searchQuery);
                      },
                    ),
                  ],
                ),
              ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                ),
                itemCount: _searchImages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        child: ShadowContainer(
                          child: GestureDetector(
                            onDoubleTap: () {
                              onDoubleTap(_searchImages[index], context);
                            },
                            child: ImageLoader(
                              imageType: ImageType.folderPreview,
                              imageCloudId: _searchImages.isNotEmpty
                                  ? _searchImages[index].imageCloudId
                                  : '',
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _searchImages[index].name.substring(
                            0, _searchImages[index].name.lastIndexOf('.')),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize:
                              Theme.of(context).textTheme.titleSmall?.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          //isFeatureAvailable(EnvironmentalVariables.featureAddImage.variable)
            showAddImageScreen
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => AddImageScreen(
                          folder: widget.folder,
                        ),
                      ),
                    );
                  },
                  tooltip: 'Add image',
                  child: const Icon(Icons.add),
                )
              : null,
    );
    });
  }
}
