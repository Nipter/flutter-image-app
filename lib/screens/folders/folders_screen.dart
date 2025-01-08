import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/assets.dart';
import 'package:image_viewer_app/permissions/access_checker.dart';
import 'package:image_viewer_app/providers/folders_provider.dart';
import 'package:image_viewer_app/screens/folders/add_folder_screen.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:image_viewer_app/widgets/folder/folder.dart';

class FoldersScreen extends ConsumerStatefulWidget {
  const FoldersScreen({super.key});

  @override
  ConsumerState<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends ConsumerState<FoldersScreen> {
  bool _isLoading = false;
  List<dynamic> _folders = [];

  Future<void> _loadFolders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(foldersProvider.notifier).loadFolders();
      final folders = ref.watch(preparedFoldersProvider);

      setState(() {
        _folders = folders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not load folder. Please try again or contact administrators.'),
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
    super.initState();
    _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: LoadingContainer(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Wrap(
                    spacing: 30.0,
                    runSpacing: 30.0,
                    children: [
                      for (var folder in _folders) Folder(folder: folder),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton:
          isFeatureAvailable(EnvironmentalVariables.featureAddFolder.variable)
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const AddFolderScreen(),
                      ),
                    );
                  },
                  tooltip: 'Create folder',
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}
