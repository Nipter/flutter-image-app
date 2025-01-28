import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/constants.dart';
import 'package:image_viewer_app/models/folder_model.dart';
import 'package:image_viewer_app/models/image/image_model.dart';
import 'package:image_viewer_app/providers/folders_provider.dart';
import 'package:image_viewer_app/providers/images_provider.dart';
import 'package:image_viewer_app/screens/tabs_screen.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/constrained_container.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:image_viewer_app/widgets/image/image_loader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:html' as html;

class EditImageScreen extends ConsumerStatefulWidget {
  final ImageModel image;
  final FolderModel folder;
  final bool allowToEdit;

  const EditImageScreen(
      {super.key,
      required this.image,
      required this.folder,
      this.allowToEdit = false});

  @override
  ConsumerState<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends ConsumerState<EditImageScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  late final List<FolderModel> folders;
  late String _selectedFolderId;

  bool _isLoading = false;

  void _onFolderSelect(String? value) {
    if (value != null) {
      _selectedFolderId = value;
    }
  }

  String? _onNameValidation(String? value) {
    if (value == null || value.toString().isEmpty) {
      return 'Name is required';
    } else if (value.endsWith('.jpg') || value.endsWith('.png')) {
      return null;
    }
    return 'Only .png and .jpg formats are supported';
  }

  String? _onFolderValidation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Folder is required';
    }
    return null;
  }

  Future<void> _editImage() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      widget.image.name = _nameController.text;
      await ImagesDataController.editImage(widget.image, _selectedFolderId);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const TabsScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to edit image. Please try again or contact administrators.'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ImagesDataController.deleteImageWithFromFolder(
          widget.image.id, widget.folder.id);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const TabsScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to delete image. Please try again or contact administrators.'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    folders = ref.read(foldersProvider);
    _selectedFolderId = widget.folder.id;
    _nameController.text = widget.image.name;
    super.initState();
  }

  Future<void> downloadImage(BuildContext context, ImageModel image) async {
    try {
      final imageBytes = await ImageLoader.fetchImage(
          context, image.imageCloudId, ImageType.oryginalImage);

      if (kIsWeb) {
        final blob = html.Blob([imageBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = image.name;
        anchor.click();

        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${image.name}';
        final file = io.File(filePath);
        await file.writeAsBytes(imageBytes);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Error while downloading image. Please try again or contact administrators.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget>? actions = [
      IconButton(
        icon: const Icon(Icons.download_outlined),
        onPressed: () {
          downloadImage(context, widget.image);
        },
      )
    ];

    if (!widget.allowToEdit) {
      actions.add(IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => EditImageScreen(
                folder: widget.folder,
                image: widget.image,
                allowToEdit: true,
              ),
            ),
          );
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Image details"),
        actions: actions,
      ),
      body: BackgroundContainer(
        child: LoadingContainer(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 400,
                      child: ImageLoader(
                          imageType: ImageType.screenSize,
                          imageCloudId: widget.image.imageCloudId),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _nameController,
                      validator: _onNameValidation,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.allowToEdit)
                      DropdownButtonFormField<String>(
                        value: _selectedFolderId.trim().isEmpty
                            ? null
                            : _selectedFolderId,
                        hint: Text(
                          'Select folder',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        dropdownColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        items: folders.map((folder) {
                          return DropdownMenuItem<String>(
                            value: folder.id,
                            child: Text(
                              folder.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: _onFolderSelect,
                        validator: _onFolderValidation,
                      ),
                    if (!widget.allowToEdit)
                      TextField(
                        controller:
                            TextEditingController(text: widget.folder.name),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Folder',
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller:
                          TextEditingController(text: widget.image.createdBy),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Created by',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller:
                          TextEditingController(text: widget.image.updatedBy),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Updated by',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: TextEditingController(
                        text: DateFormat(TIME_FORMAT)
                            .format(widget.image.createdAt),
                      ),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Created At',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: TextEditingController(
                        text: DateFormat(TIME_FORMAT)
                            .format(widget.image.updatedAt),
                      ),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Updated At',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.allowToEdit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _deleteImage,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Delete image'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _editImage,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save image'),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
