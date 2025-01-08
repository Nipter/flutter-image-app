import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/models/image/image_input_model.dart';
import 'package:image_viewer_app/providers/folders_provider.dart';
import 'package:image_viewer_app/screens/tabs_screen.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/constrained_container.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:image_viewer_app/widgets/image/images_input.dart';

class AddFolderScreen extends ConsumerStatefulWidget {
  const AddFolderScreen({super.key});

  @override
  ConsumerState<AddFolderScreen> createState() {
    return _AddFolderScreenState();
  }
}

class _AddFolderScreenState extends ConsumerState<AddFolderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  List<ImageInputModel> _selectedImages = [];

  bool _isLoading = false;

  void _onImagesSelect(List<ImageInputModel>? images) {
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
      await FoldersNotifier.createFolder(_selectedImages, _nameController.text);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const TabsScreen(),
          ),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Folder created.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to create folder. Please try again or contact administrators.'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new folder"),
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
                    ImagesInput(
                      allowMultiple: true,
                      onImageSelect: _onImagesSelect,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveFolder,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Add folder'),
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
