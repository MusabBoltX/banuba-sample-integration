import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/foundation.dart';

class BanubaService {
  static final BanubaService _instance = BanubaService._internal();
  factory BanubaService() => _instance;
  BanubaService._internal();

  final BanubaSdkManager _sdkManager = BanubaSdkManager();

  BanubaSdkManager get sdkManager => _sdkManager;

  Future<void> openCamera() async {
    debugPrint('BanubaService: open camera');
    await _sdkManager.openCamera();
  }

  Future<void> attachWidget(int banubaId) async {
    await _sdkManager.attachWidget(banubaId);
  }

  Future<void> startPlayer() async {
    _sdkManager.startPlayer();
  }

  Future<void> stopPlayer() async {
    _sdkManager.stopPlayer();
  }

  Future<void> closeCamera() async {
    _sdkManager.closeCamera();
  }

  Future<void> loadEffect(String effectPath, bool isImage) async {
    await _sdkManager.loadEffect(effectPath, isImage);
  }

  Future<void> unloadEffect() async {
    await _sdkManager.unloadEffect();
  }

  Future<void> setCameraFacing(bool isFront) async {
    _sdkManager.setCameraFacing(isFront);
  }

  Future<void> setZoom(double zoom) async {
    _sdkManager.setZoom(zoom);
  }

  Future<void> enableFlashlight(bool enable) async {
    _sdkManager.enableFlashlight(enable);
  }

  Future<void> startVideoRecording(
    String filePath,
    bool captureAudio,
    int width,
    int height,
  ) async {
    await _sdkManager.startVideoRecording(
        filePath, captureAudio, width, height);
  }

  Future<void> stopVideoRecording() async {
    await _sdkManager.stopVideoRecording();
  }

  Future<void> takePhoto(String filePath, int width, int height) async {
    await _sdkManager.takePhoto(filePath, width, height);
  }

  Future<void> evalJs(String script) async {
    _sdkManager.evalJs(script);
  }

  Future<void> startEditingImage(String imagePath) async {
    await _sdkManager.startEditingImage(imagePath);
  }

  Future<void> endEditingImage(String outputPath) async {
    await _sdkManager.endEditingImage(outputPath);
  }

  Future<void> discardEditingImage() async {
    _sdkManager.discardEditingImage();
  }

  void deinitialize() {
    _sdkManager.deinitialize();
  }
}
