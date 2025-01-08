import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_viewer_app/firebase_options.dart';
import 'package:image_viewer_app/screens/auth_screen.dart';
import 'package:image_viewer_app/screens/loading_screen.dart';
import 'package:image_viewer_app/screens/tabs_screen.dart';
import 'package:image_viewer_app/themes/base_theme.dart';
import 'package:image_viewer_app/themes/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (dotenv.env["EMULATOR_MODE"]?.toLowerCase() == 'true') {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, TEXT_THEME, TEXT_THEME);

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Image Viewer',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }

          if (snapshot.hasData) {
            return const TabsScreen();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
