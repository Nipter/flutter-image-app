import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';

/// Initialize the [FlutterLocalNotificationsPlugin] package.
//late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    name: "zaliczenie-pl-kl",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (dotenv.env["EMULATOR_MODE"]?.toLowerCase() == 'true') {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
  }

  // subscribe to topic on each app start-up
  //await FirebaseMessaging.instance.subscribeToTopic('errors');
  //  //opened from terminated state
  //      FirebaseMessaging.instance.getInitialMessage().then(
  //        (value) => print(value),
  //      );
  //
  //
  //  // listen to messages when app is in the foreground
  //  FirebaseMessaging.onMessage.listen(_handleMessageForeground);
  //
  //  //opened from from background
  //  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);


  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
  void _handleMessage(RemoteMessage message) {
    print("background: " + message.toString());
  }
  void _handleMessageForeground(RemoteMessage message) {
    print("foreground: " + message.toString());
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
