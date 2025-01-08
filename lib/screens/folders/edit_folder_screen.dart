import 'package:flutter/material.dart';
import 'package:image_viewer_app/constants.dart';
import 'package:image_viewer_app/models/folder_model.dart';
import 'package:image_viewer_app/models/image/image_model.dart';
import 'package:image_viewer_app/providers/folders_provider.dart';
import 'package:image_viewer_app/screens/tabs_screen.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/constrained_container.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:image_viewer_app/widgets/container/shadow_container.dart';
import 'package:image_viewer_app/widgets/image/image_loader.dart';
import 'package:intl/intl.dart';

class EditFolderScreen extends StatefulWidget {
  final FolderModel folder;

  const EditFolderScreen({super.key, required this.folder});

  @override
  State<EditFolderScreen> createState() {
    return _EditFolderScreenState();
  }
}

class _EditFolderScreenState extends State<EditFolderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  List<ImageModel> _selectedImages = [];

  bool _isLoading = false;

  void _onImagesChange(List<ImageModel>? images) {
    if (images != null && images.isNotEmpty) {
      _selectedImages = images;
    }
  }

  String? _onNameValidation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> _saveFolder() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await FoldersNotifier.editFolder(
          widget.folder, _selectedImages, _nameController.text);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const TabsScreen(),
          ),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Folder edited.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to edit folder. Please try again or contact administrators.'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFolder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FoldersNotifier.deleteFolder(widget.folder);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const TabsScreen(),
          ),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Folder deleted'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to delete folder. Please try again or contact administrators.'),
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
    _selectedImages = List.from(widget.folder.images);
    _nameController.text = widget.folder.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit folder"),
      ),
      body: BackgroundContainer(
        child: LoadingContainer(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ConstrainedContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      validator: _onNameValidation,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller:
                          TextEditingController(text: widget.folder.createdBy),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Created by',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller:
                          TextEditingController(text: widget.folder.updatedBy),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Updated by',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: TextEditingController(
                        text: DateFormat(TIME_FORMAT)
                            .format(widget.folder.createdAt),
                      ),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Created at',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: TextEditingController(
                        text: DateFormat(TIME_FORMAT)
                            .format(widget.folder.updatedAt),
                      ),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Updated at',
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: ValueKey(_selectedImages[index].id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setState(() {
                              _selectedImages.remove(
                                _selectedImages.firstWhere((image) =>
                                    image.id == _selectedImages[index].id),
                              );
                            });
                            // widget.onImageSelect(_selectedImages);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Image successfully removed',
                                ),
                              ),
                            );
                          },
                          background: Container(
                            color: Theme.of(context).colorScheme.errorContainer,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface),
                          ),
                          child: ShadowContainer(
                            child: ImageLoader(
                              imageType: ImageType.folderPreview,
                              imageCloudId: _selectedImages[index].imageCloudId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _deleteFolder,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Delete folder'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _saveFolder,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Edit folder'),
                        ),
                      ],
                    ),
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
