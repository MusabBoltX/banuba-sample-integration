import 'dart:async';
import 'dart:io' as io;

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/camera_models.dart';
import '../models/touch_up_data.dart';
import '../models/touch_up_models.dart';
import '../utils/helpers.dart';
import '../widgets/camera_controls.dart';
import '../widgets/touch_up_panel.dart';
import '../widgets/video_player_widget.dart';

/// Clean, modular camera page with separated concerns
class CameraPageClean extends StatefulWidget {
  final String banubaToken;

  const CameraPageClean({super.key, required this.banubaToken});

  @override
  State<CameraPageClean> createState() => _CameraPageCleanState();
}

class _CameraPageCleanState extends State<CameraPageClean>
    with WidgetsBindingObserver {
  // SDK Management
  final _banubaSdkManager = BanubaSdkManager();
  final _epWidget = EffectPlayerWidget(key: null);

  // Camera State
  bool _isVideoRecording = false;
  bool _isFacingFront = true;
  double _zoom = 1.0;
  bool _enableFlashlight = false;
  bool _showTouchUpPanel = false;
  bool _showPreview = false;
  bool _showVideoPreview = false;

  // File Management
  String? _filePath;
  String? _capturedImagePath;

  // Effects
  final _effects = CameraSettings.availableEffects;
  int _currentEffectIndex = -1;
  String? _currentEffectName = null;

  // Touch-up features
  late List<TouchUpCategory> _touchUpCategories;

  @override
  void initState() {
    debugPrint('CameraPageClean: init');
    super.initState();

    // Initialize touch-up categories
    _touchUpCategories = TouchUpData.getCategories();

    initSDK();

    // Request permissions
    requestPermissions().then((granted) {
      if (granted) {
        debugPrint('CameraPageClean: Thanks! All permissions are granted!');
        openCamera();
      } else {
        debugPrint(
            'CameraPageClean: WARNING! Not all required permissions are granted!');
        SystemNavigator.pop();
      }
    }).onError((error, stackTrace) {
      debugPrint('CameraPageClean: ERROR! Plugin cannot be used : $error');
      SystemNavigator.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('CameraPageClean: release SDK');
    _banubaSdkManager.unloadEffect();
    _banubaSdkManager.stopPlayer();
    _banubaSdkManager.closeCamera();
    _banubaSdkManager.deinitialize();
  }

  // SDK Initialization
  Future<void> initSDK() async {
    debugPrint('CameraPageClean: start init SDK');
    await _banubaSdkManager
        .initialize([], widget.banubaToken, SeverityLevel.info);
    debugPrint('CameraPageClean: SDK initialized successfully');
  }

  Future<void> openCamera() async {
    debugPrint('CameraPageClean: open camera');
    if (!mounted) {
      debugPrint('CameraPageClean: Warning! widget is not mounted!');
      return;
    }
    await _banubaSdkManager.openCamera();
    await _banubaSdkManager.attachWidget(_epWidget.banubaId);
    _banubaSdkManager.startPlayer();
  }

  // Camera Controls
  Future<void> _toggleFlashlight() async {
    if (!_isFacingFront) {
      setState(() {
        _enableFlashlight = !_enableFlashlight;
      });
      _banubaSdkManager.enableFlashlight(_enableFlashlight);
    } else {
      showToastMessage('Flashlight only available on back camera! 📸');
    }
  }

  Future<void> _flipCamera() async {
    _isFacingFront = !_isFacingFront;
    _banubaSdkManager.setCameraFacing(_isFacingFront);
    setState(() {});
  }

  Future<void> _changeZoom(double zoom) async {
    setState(() {
      _zoom = zoom;
    });
    _banubaSdkManager.setZoom(_zoom);
  }

  // Photo and Video Capture
  Future<void> _takePhoto() async {
    final photoFilePath = await generateFilePath('image_', '.png');
    debugPrint('CameraPageClean: Take photo = $photoFilePath');
    _banubaSdkManager
        .takePhoto(
            photoFilePath,
            CameraSettings.videoResolutionHD.width.toInt(),
            CameraSettings.videoResolutionHD.height.toInt())
        .then((value) {
      debugPrint('CameraPageClean: Photo taken successfully');
      setState(() {
        _capturedImagePath = photoFilePath;
        _showPreview = true;
      });
      showToastMessage('Photo captured! 📸');
    }).onError((error, stackTrace) {
      debugPrint('CameraPageClean: Error while taking photo');
    });
  }

  Future<void> _toggleVideoRecording() async {
    if (_isVideoRecording) {
      // Stop recording
      final isVideoRecording = _isVideoRecording;
      setState(() {
        _isVideoRecording = false;
      });
      await _handleVideoRecording(isVideoRecording);
    } else {
      // Start recording
      setState(() {
        _isVideoRecording = true;
      });
      await _handleVideoRecording(false);
    }
  }

  Future<void> _handleVideoRecording(bool isVideoRecording) async {
    if (isVideoRecording) {
      debugPrint('CameraPageClean: stopVideoRecording');
      await _banubaSdkManager.stopVideoRecording().then((_) {
        if (_filePath != null) {
          debugPrint(
              'CameraPageClean: Video recorded successfully.\n File path $_filePath.\n File exists ${io.File(_filePath!).existsSync()}');
          showToastMessage('Video recorded successfully! 🎥');
          setState(() {
            _showVideoPreview = true;
          });
        } else {
          debugPrint('CameraPageClean: recording file path is null');
        }
      });
    } else {
      final filePath = await generateFilePath('video_', '.mp4');
      debugPrint('CameraPageClean: startVideoRecording = $filePath');
      await _banubaSdkManager.startVideoRecording(
          filePath,
          CameraSettings.captureAudioInVideoRecording,
          CameraSettings.videoResolutionHD.width.toInt(),
          CameraSettings.videoResolutionHD.height.toInt());
      _filePath = filePath;
    }
  }

  // Touch-up Features
  Future<void> _loadTouchUpEffect() async {
    try {
      debugPrint('CameraPageClean: Loading TouchUp effect');
      await _banubaSdkManager.loadEffect('effects/TouchUp', false);
      setState(() {
        _currentEffectName = 'TouchUp';
        _currentEffectIndex = _effects.indexOf('TouchUp');
      });
      debugPrint('CameraPageClean: TouchUp effect loaded successfully');
    } catch (e) {
      debugPrint('CameraPageClean: Error loading TouchUp effect: $e');
    }
  }

  void _applyTouchUpChanges(List<String> changes) async {
    // Ensure TouchUp effect is loaded before applying changes
    if (_currentEffectName != 'TouchUp') {
      debugPrint('CameraPageClean: TouchUp effect not loaded, loading now...');
      await _loadTouchUpEffect();
    }

    for (var element in changes) {
      debugPrint('CameraPageClean: apply touch-up changes = $element');
      try {
        _banubaSdkManager.evalJs(element);
      } catch (e) {
        debugPrint('CameraPageClean: Error applying touch-up change: $e');
      }
    }
  }

  // Preview Management
  void _closePreview() {
    setState(() {
      _showPreview = false;
      _capturedImagePath = null;
    });
    _restartCamera();
  }

  void _closeVideoPreview() {
    setState(() {
      _showVideoPreview = false;
      _filePath = null;
    });
    _restartCamera();
  }

  Future<void> _restartCamera() async {
    try {
      debugPrint('CameraPageClean: Restarting camera');
      await _banubaSdkManager.stopPlayer();
      await _banubaSdkManager.closeCamera();
      await Future.delayed(const Duration(milliseconds: 500));
      await openCamera();
      debugPrint('CameraPageClean: Camera restarted successfully');
    } catch (e) {
      debugPrint('CameraPageClean: Error restarting camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CameraPageClean: build');
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Show preview screen if image is captured
    if (_showPreview && _capturedImagePath != null) {
      return _buildPreviewScreen();
    }

    // Show video preview screen if video is recorded
    if (_showVideoPreview && _filePath != null) {
      return _buildVideoPreviewScreen();
    }

    return WillPopScope(
      onWillPop: () async {
        if (_showVideoPreview) {
          _closeVideoPreview();
          return false;
        }
        if (_showPreview) {
          _closePreview();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera view
            SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: _epWidget),

            // Top controls
            Positioned(
              top: statusBarHeight + 20,
              left: 0,
              right: 0,
              child: _buildTopControls(),
            ),

            // Touch-up panel on the right side
            if (_showTouchUpPanel)
              Positioned(
                top: statusBarHeight + 80,
                right: 0,
                bottom: 200,
                child: TouchUpPanel(
                  categories: _touchUpCategories,
                  onApplyChanges: _applyTouchUpChanges,
                  onClose: () {
                    setState(() {
                      _showTouchUpPanel = false;
                    });
                  },
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CameraControls(
                enableFlashlight: _enableFlashlight,
                isFacingFront: _isFacingFront,
                zoom: _zoom,
                isVideoRecording: _isVideoRecording,
                onFlashlightToggle: _toggleFlashlight,
                onCameraFlip: _flipCamera,
                onZoomChange: _changeZoom,
                onPhotoCapture: _takePhoto,
                onVideoRecord: _toggleVideoRecording,
              ),
            ),

            // Recording indicator
            if (_isVideoRecording)
              Positioned(
                top: statusBarHeight + 60,
                right: 20,
                child: _buildRecordingIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 50),
          const SizedBox(width: 50),
          _buildCircularButton(
            icon: Icons.face_retouching_natural,
            onTap: () async {
              if (!_showTouchUpPanel) {
                await _loadTouchUpEffect();
              }
              setState(() {
                _showTouchUpPanel = !_showTouchUpPanel;
              });
            },
            backgroundColor: _showTouchUpPanel ? Colors.purple : Colors.black54,
            isActive: _showTouchUpPanel,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required Function() onTap,
    required Color backgroundColor,
    double size = 40,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'REC',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: _capturedImagePath != null
                  ? Image.file(
                      io.File(_capturedImagePath!),
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.white54,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularButton(
                    icon: Icons.arrow_back,
                    onTap: _closePreview,
                    backgroundColor: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Retake',
                    onTap: _closePreview,
                    backgroundColor: Colors.red,
                  ),
                  _buildActionButton(
                    icon: Icons.save,
                    label: 'Save',
                    onTap: () {
                      showToastMessage('Image saved to gallery! 💾');
                    },
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreviewScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: _filePath != null
                  ? VideoPlayerWidget(videoPath: _filePath!)
                  : Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.videocam,
                          size: 100,
                          color: Colors.white54,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularButton(
                    icon: Icons.arrow_back,
                    onTap: _closeVideoPreview,
                    backgroundColor: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Retake',
                    onTap: _closeVideoPreview,
                    backgroundColor: Colors.red,
                  ),
                  _buildActionButton(
                    icon: Icons.save,
                    label: 'Save',
                    onTap: () {
                      showToastMessage('Video saved to gallery! 💾');
                    },
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
