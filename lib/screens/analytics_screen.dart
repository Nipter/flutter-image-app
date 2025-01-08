import 'package:flutter/material.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
      ),
      body: const BackgroundContainer(
        //TODO: add logic of analytics page, pref use context
        child: Center(
          child: Text('Todo Analytics page'),
        ),
      ),
    );
  }
}
