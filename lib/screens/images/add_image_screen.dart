import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/models/folder_model.dart';
import 'package:image_viewer_app/models/image/image_input_model.dart';
import 'package:image_viewer_app/providers/folders_provider.dart';
import 'package:image_viewer_app/providers/images_provider.dart';
import 'package:image_viewer_app/screens/tabs_screen.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/constrained_container.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:image_viewer_app/widgets/image/images_input.dart';

class AddImageScreen extends ConsumerStatefulWidget {
  final FolderModel? folder;

  const AddImageScreen({
    super.key,
    this.folder,
  });

  @override
  ConsumerState<AddImageScreen> createState() {
    return _AddImageScreenState();
  }
}

class _AddImageScreenState extends ConsumerState<AddImageScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  late String _selectedFolderId;
  ImageInputModel? _selectedImage;

  late final List<FolderModel> folders;

  bool _isLoading = false;

  void _onFolderSelect(String? value) {
    if (value != null) {
      _selectedFolderId = value;
    }
  }

  void _onImageSelect(List<ImageInputModel>? images) {
    if (images != null && images.isNotEmpty) {
      _selectedImage = images.first;
      setState(() {
        _nameController.text = images.first.name;
      });
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

  String? _onImageValidation(List<ImageInputModel>? images) {
    if (images == null || images.isEmpty) {
      return 'Image is required';
    }
    return null;
  }

  Future<void> _saveImage() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      _selectedImage!.name = _nameController.text;
      await ImagesDataController.createImage(
          _selectedImage!, _selectedFolderId);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const TabsScreen(),
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
    _selectedFolderId = widget.folder != null ? widget.folder!.id : "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new image"),
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
                    if (widget.folder != null)
                      TextFormField(
                        initialValue: widget.folder?.name,
                        decoration: const InputDecoration(
                          labelText: 'Folder',
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        readOnly: true,
                      ),
                    if (widget.folder == null)
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
                    const SizedBox(height: 20),
                    ImagesInput(
                      onImageSelect: _onImageSelect,
                      onImageValidation: _onImageValidation,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveImage,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save image'),
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
