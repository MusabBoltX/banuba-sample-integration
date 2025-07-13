import 'dart:async';
import 'dart:io';

import 'package:banuba_sdk_example/page_camera.dart';
import 'package:banuba_sdk_example/page_image.dart';
import 'package:banuba_sdk_example/page_touchup.dart';
import 'package:banuba_sdk_example/page_arcloud.dart';
import 'package:banuba_sdk_example/pages/camera_page_clean.dart';
import 'package:banuba_sdk_example/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String banubaToken = "";

enum EntryPage { camera, image, touchUp, arCloud }

void main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize the banuba token from environment variables
  banubaToken = dotenv.env['BANUBA_TOKEN'] ?? "";

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      fixedSize: Size(MediaQuery.of(context).size.width / 2.0, 50),
    );
    Text textWidget(String text) {
      return Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 13.0),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face AR Flutter Sample'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.camera),
            child: textWidget('Open Camera'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.image),
            child: textWidget('Image processing'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.touchUp),
            child: textWidget('Touch Up features'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.arCloud),
            child: textWidget('Load from AR Cloud'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(EntryPage entryPage) {
    switch (entryPage) {
      case EntryPage.camera:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CameraPageClean(banubaToken: banubaToken)),
        );
        return;

      case EntryPage.image:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ImagePage()),
        );
        return;

      case EntryPage.touchUp:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TouchUpPage()),
        );
        return;

      case EntryPage.arCloud:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ARCloudPage()),
        );
        return;
    }
  }
}

// Helper functions have been moved to utils/helpers.dart
