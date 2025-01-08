import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_viewer_app/models/image/image_input_model.dart';
import 'package:image_viewer_app/widgets/container/shadow_container.dart';

class ImagesInput extends StatefulWidget {
  final bool allowMultiple;
  final void Function(List<ImageInputModel>? images) onImageSelect;
  final String? Function(List<ImageInputModel>? images)? onImageValidation;

  const ImagesInput({
    super.key,
    this.allowMultiple = false,
    required this.onImageSelect,
    this.onImageValidation,
  });
  @override
  State<StatefulWidget> createState() {
    return _ImagesInputState();
  }
}

class _ImagesInputState extends State<ImagesInput> {
  final List<ImageInputModel> _selectedImages = [];

  void _takePicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: widget.allowMultiple,
    );
    if (result != null && result.files.isNotEmpty) {
      List<ImageInputModel> tempSelectedImages = [];
      for (var image in result.files) {
        final Uint8List imageInBytes;

        if (kIsWeb) {
          imageInBytes = image.bytes!;
        } else {
          File file = File(image.path!);

          imageInBytes = await file.readAsBytes();
        }
        tempSelectedImages.add(
          ImageInputModel(imageBytes: imageInBytes, name: image.name),
        );
      }

      setState(() {
        _selectedImages.addAll(tempSelectedImages);
      });

      widget.onImageSelect(_selectedImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget addImageButton = TextButton.icon(
      icon: const Icon(Icons.camera),
      label: Text(widget.allowMultiple ? 'Select Pictures' : 'Select Picture'),
      onPressed: _takePicture,
    );

    Widget content = addImageButton;

    if (_selectedImages.isNotEmpty) {
      content = GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  _selectedImages.firstWhere(
                    (image) => image.id == _selectedImages[index].id,
                  ),
                );
              });
              widget.onImageSelect(_selectedImages);
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
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
            child: ShadowContainer(
              child: Image.memory(
                _selectedImages[index].imageBytes,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      );
    }

    return FormField<List<ImageInputModel>>(
      initialValue: _selectedImages,
      validator: (value) {
        if (widget.onImageValidation != null &&
            widget.onImageValidation is Function) {
          return widget.onImageValidation!(_selectedImages);
        }
        return null;
      },
      builder: (FormFieldState<List<ImageInputModel>> state) {
        return Container(
          decoration: _selectedImages.isEmpty
              ? BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                )
              : null,
          width: double.infinity,
          height: _selectedImages.isEmpty ? 300 : null,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              content,
              if (_selectedImages.isNotEmpty && widget.allowMultiple)
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    addImageButton,
                  ],
                ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText ?? '',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
