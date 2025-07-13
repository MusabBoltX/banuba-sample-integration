import 'dart:ui';
import 'package:flutter/material.dart';

enum EntryPage { camera, image, touchUp, arCloud }

enum CameraFacing { front, back }

enum FlashMode { off, on }

enum ZoomLevel { x1, x2, x3 }

class CameraSettings {
  static const Size videoResolutionHD = Size(720, 1280);
  static const bool captureAudioInVideoRecording = true;
  static const List<String> availableEffects = [
    "80s",
    "TouchUp",
    "ColorTest",
    "SimpleVintage",
    "Vintage",
    "Cinematic",
    "Neon",
    "Monochrome",
    "Sunset",
    "Cyberpunk"
  ];
}
