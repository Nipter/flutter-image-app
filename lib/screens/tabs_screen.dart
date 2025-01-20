import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/providers/users_provider.dart';
import 'package:image_viewer_app/screens/analytics_screen.dart';
import 'package:image_viewer_app/screens/folders/add_folder_screen.dart';
import 'package:image_viewer_app/screens/folders/folders_screen.dart';
import 'package:image_viewer_app/screens/images/add_image_screen.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:image_viewer_app/widgets/drawer/main_drawer.dart';

enum Screens {
  addImageScreen,
  addFolderScreen,
  folderScreen,
  analyticsScreen,
}

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreen();
  }
}

class _TabsScreen extends ConsumerState<TabsScreen> {
  bool _isLoading = false;

  void _setScreen(Enum identifier) async {
    if (identifier == Screens.addImageScreen) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const AddImageScreen(),
        ),
      );
    } else if (identifier == Screens.addFolderScreen) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const AddFolderScreen(),
        ),
      );
    } else if (identifier == Screens.analyticsScreen) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const AnalyticsScreen(),
        ),
      );
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(usersProvider.notifier).loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not load users. Please try again or contact administrators.'),
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
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const FoldersScreen();
    String activePageTitle = 'Folders';

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: LoadingContainer(
        isLoading: _isLoading,
        child: MainDrawer(
          onSelectScreen: _setScreen,
        ),
      ),
      body: activePage,
    );
  }
}
