import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/assets.dart';
import 'package:image_viewer_app/permissions/constants.dart';
import 'package:image_viewer_app/providers/users_provider.dart';
import 'package:image_viewer_app/screens/tabs_screen.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:image_viewer_app/widgets/drawer/list_title_item.dart';
import 'package:flutter/foundation.dart';

class MainDrawer extends ConsumerStatefulWidget {
  final void Function(Enum identifier) onSelectScreen;

  const MainDrawer({super.key, required this.onSelectScreen});

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  bool _isLoading = false;
  bool _showAnalyticsScreen = true;

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      setState(() {
        _isLoading = true;
      });

      await ref.read(usersProvider.notifier).loadUsers();

      setState(() {
        _showAnalyticsScreen = ref
            .read(usersProvider.notifier)
            .currentUserRoles
            .contains(UserRoles.Admin.name);
      });
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
    return Drawer(
      child: LoadingContainer(
        isLoading: _isLoading,
        child: Column(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.7),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(Images.logo.path),
              ),
            ),
            ListTitleItem(
              title: 'Add image',
              env: EnvironmentalVariables.featureAddImage.variable,
              iconData: Icons.image_outlined,
              onTap: () {
                widget.onSelectScreen(Screens.addImageScreen);
              },
            ),
            ListTitleItem(
              title: 'Add folder',
              env: EnvironmentalVariables.featureAddFolder.variable,
              iconData: Icons.create_new_folder_outlined,
              onTap: () {
                widget.onSelectScreen(Screens.addFolderScreen);
              },
            ),
            if (_showAnalyticsScreen)
              ListTitleItem(
                title: 'Analytics',
                env: EnvironmentalVariables.featureCheckAnalytics.variable,
                additionalShowCondition: kIsWeb,
                iconData: Icons.analytics_outlined,
                onTap: () {
                  widget.onSelectScreen(Screens.analyticsScreen);
                },
              ),
            ListTitleItem(
              title: 'Logout',
              iconData: Icons.logout_outlined,
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
