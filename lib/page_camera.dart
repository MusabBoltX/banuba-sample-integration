import 'dart:async';
import 'dart:io' as io;

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:banuba_sdk_example/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:video_player/video_player.dart';

import 'main.dart';

typedef List<String> Processor(double progress);

/// Snapchat-like camera screen with modern UI and comprehensive touch-up features
/// 1. Open camera
/// 2. Apply Face AR effect
/// 3. Record video(with/out AR effect)
/// 4. Take a picture(with/out AR effect)
/// 5. Comprehensive touch-up features
/// 6. Image preview screen
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  // Avoid creating multiple instances
  final _banubaSdkManager = BanubaSdkManager();

  final _epWidget = EffectPlayerWidget(key: null);

  // The higher resolution the more CPU and GPU resources are used.
  // Please take into account that low level devices might have performance issues with HD resolution.
  final _videoResolutionHD = const Size(720, 1280);

  final _captureAudioInVideoRecording = true;

  final _effects = ["80s", "TouchUp"];
  int _currentEffectIndex = -1;
  String? _currentEffectName = null;

  bool _isVideoRecording = false;
  bool _isFacingFront = true;
  double _zoom = 1.0;
  bool _enableFlashlight = false;
  bool _showEffectsPanel = false;
  bool _showPreview = false;
  bool _showTouchUpPanel = false;
  bool _showVideoPreview = false;

  String? _filePath;
  String? _capturedImagePath;

  // Touch-up features organized by categories
  final List<TouchUpCategory> _touchUpCategories = [
    TouchUpCategory(
      name: 'Skin',
      icon: Icons.face,
      features: [
        TouchUpFeature(
          name: 'Smooth',
          progressValue: 0.0,
          min: 0,
          max: 100.0,
          processor: (double progress) => ['Skin.softening($progress)'],
        ),
        TouchUpFeature(
          name: 'Brightening',
          progressValue: 0.0,
          min: 0,
          max: 100.0,
          processor: (double progress) => ['Eyes.whitening($progress)'],
        ),
        TouchUpFeature(
          name: 'Teeth Whitening',
          progressValue: 0.0,
          min: 0,
          max: 100.0,
          processor: (double progress) => ['Teeth.whitening($progress)'],
        ),
      ],
    ),
    TouchUpCategory(
      name: 'Eyes',
      icon: Icons.visibility,
      features: [
        TouchUpFeature(
          name: 'Size',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyes({enlargement: $progress})'],
        ),
        TouchUpFeature(
          name: 'Rounding',
          progressValue: 0.0,
          min: 0.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyes({rounding: $progress})'],
        ),
        TouchUpFeature(
          name: 'Height',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyes({height: $progress})'],
        ),
        TouchUpFeature(
          name: 'Spacing',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyes({spacing: $progress})'],
        ),
        TouchUpFeature(
          name: 'Squint',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyes({squint: $progress})'],
        ),
        TouchUpFeature(
          name: 'Upper Eyelid',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyes({upper_eyelid_pos: $progress})'],
        ),
        TouchUpFeature(
          name: 'Lower Eyelid',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyes({lower_eyelid_pos: $progress})'],
        ),
      ],
    ),
    TouchUpCategory(
      name: 'Eyebrows',
      icon: Icons.brush,
      features: [
        TouchUpFeature(
          name: 'Spacing',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyebrows({spacing: $progress})'],
        ),
        TouchUpFeature(
          name: 'Height',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyebrows({height: $progress})'],
        ),
        TouchUpFeature(
          name: 'Bend',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.eyebrows({bend: $progress})'],
        ),
      ],
    ),
    TouchUpCategory(
      name: 'Nose',
      icon: Icons.face_retouching_natural,
      features: [
        TouchUpFeature(
          name: 'Width',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.nose({width: $progress})'],
        ),
        TouchUpFeature(
          name: 'Length',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.nose({width: $progress})'],
        ),
        TouchUpFeature(
          name: 'Tip Width',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.nose({tip_width: $progress})'],
        ),
      ],
    ),
    TouchUpCategory(
      name: 'Lips',
      icon: Icons.face_retouching_off,
      features: [
        TouchUpFeature(
          name: 'Size',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) => ['FaceMorph.lips({size: $progress})'],
        ),
        TouchUpFeature(
          name: 'Shape',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.lips({shape: 1.0, thickness: $progress})'],
        ),
        TouchUpFeature(
          name: 'Thickness',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.lips({thickness: $progress})'],
        ),
        TouchUpFeature(
          name: 'Position',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.lips({height: $progress})'],
        ),
        TouchUpFeature(
          name: 'Width',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.lips({mouth_size: $progress})'],
        ),
        TouchUpFeature(
          name: 'Smile',
          progressValue: 0.0,
          min: 0.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.lips({smile: $progress})'],
        ),
      ],
    ),
    TouchUpCategory(
      name: 'Face Shape',
      icon: Icons.face,
      features: [
        TouchUpFeature(
          name: 'Width',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.face({narrowing: $progress})'],
        ),
        TouchUpFeature(
          name: 'V-Shape',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.face({v_shape: $progress})'],
        ),
        TouchUpFeature(
          name: 'Cheekbones',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.face({cheekbones_narrowing: $progress})'],
        ),
        TouchUpFeature(
          name: 'Cheeks Size',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.face({cheeks_narrowing: $progress})'],
        ),
        TouchUpFeature(
          name: 'Jaw Width',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.face({jaw_narrowing: $progress})'],
        ),
        TouchUpFeature(
          name: 'Chin',
          progressValue: 0.0,
          min: 0,
          max: 100.0,
          processor: (double progress) => [
            'FaceMesh.chin_jaw_shortening($progress)',
            'FaceMorph.face({jaw_narrowing: 1.0, chin_narrowing: 1.0})'
          ],
        ),
        TouchUpFeature(
          name: 'Chin Length',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.face({chin_shortening: $progress})'],
        ),
        TouchUpFeature(
          name: 'Chin Width',
          progressValue: 0.0,
          min: -100.0,
          max: 100.0,
          processor: (double progress) =>
              ['FaceMorph.face({chin_narrowing: $progress})'],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    debugPrint('CameraPage: init');
    super.initState();

    initSDK();

    // It is required to grant all permissions for the plugin: Camera, Micro, Storage
    requestPermissions().then((granted) {
      if (granted) {
        debugPrint('CameraPage: Thanks! All permissions are granted!');
        openCamera();
      } else {
        debugPrint(
            'CameraPage: WARNING! Not all required permissions are granted!');
        // Plugin cannot be used. Handle this state on your app side
        SystemNavigator.pop();
      }
    }).onError((error, stackTrace) {
      debugPrint('CameraPage: ERROR! Plugin cannot be used : $error');
      // Plugin cannot be used. Handle this state on your app side
      SystemNavigator.pop();
    });
  }

  // Platform messages are asynchronous, so we initialize it in an async method.
  // Avoid calling this method frequently
  Future<void> initSDK() async {
    debugPrint('CameraPage: start init SDK');

    await _banubaSdkManager.initialize([], banubaToken, SeverityLevel.info);

    debugPrint('CameraPage: SDK initialized successfully');
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('CameraPage: release SDK');
    _banubaSdkManager.unloadEffect();
    _banubaSdkManager.stopPlayer();
    _banubaSdkManager.closeCamera();
    _banubaSdkManager.deinitialize();
  }

  Future<void> openCamera() async {
    debugPrint('CameraPage: open camera');
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      debugPrint('CameraPage: Warning! widget is not mounted!');
      return;
    }
    await _banubaSdkManager.openCamera();
    await _banubaSdkManager.attachWidget(_epWidget.banubaId);
    _banubaSdkManager.startPlayer();
  }

  Future<void> toggleEffect() async {
    _currentEffectIndex += 1;
    if (_currentEffectIndex >= _effects.length) {
      await _banubaSdkManager.unloadEffect();
      setState(() {
        _currentEffectName = null;
      });
      _currentEffectIndex = -1;
      return;
    }

    final effect = _effects[_currentEffectIndex];
    setState(() {
      _currentEffectName = effect;
    });
    await _banubaSdkManager.loadEffect('effects/$effect', false);
  }

  Future<void> handleVideoRecording(bool isVideoRecording) async {
    if (isVideoRecording) {
      debugPrint('CameraPage: stopVideoRecording');
      await _banubaSdkManager.stopVideoRecording().then((_) {
        if (_filePath != null) {
          debugPrint(
              'CameraPage: Video recorded successfully.\n File path $_filePath.\n File exists ${io.File(_filePath!).existsSync()}');
          showToastMessage('Video recorded successfully! 🎥');
          // Show video preview after recording
          setState(() {
            _showVideoPreview = true;
          });
        } else {
          debugPrint('CameraPage: recording file path is null');
        }
      });
    } else {
      final filePath = await generateFilePath('video_', '.mp4');
      debugPrint('CameraPage: startVideoRecording = $filePath');
      await _banubaSdkManager.startVideoRecording(
          filePath,
          _captureAudioInVideoRecording,
          _videoResolutionHD.width.toInt(),
          _videoResolutionHD.height.toInt());
      _filePath = filePath;
    }
  }

  Future<void> takePhoto() async {
    final photoFilePath = await generateFilePath('image_', '.png');
    debugPrint('CameraPage: Take photo = $photoFilePath');
    _banubaSdkManager
        .takePhoto(photoFilePath, _videoResolutionHD.width.toInt(),
            _videoResolutionHD.height.toInt())
        .then((value) {
      debugPrint('CameraPage: Photo taken successfully');
      setState(() {
        _capturedImagePath = photoFilePath;
        _showPreview = true;
      });
      showToastMessage('Photo captured! 📸');
    }).onError((error, stackTrace) {
      debugPrint('CameraPage: Error while taking photo');
    });
  }

  Future<void> _loadTouchUpEffect() async {
    try {
      debugPrint('CameraPage: Loading TouchUp effect');
      await _banubaSdkManager.loadEffect('effects/TouchUp', false);
      setState(() {
        _currentEffectName = 'TouchUp';
        _currentEffectIndex = _effects.indexOf('TouchUp');
      });
      debugPrint('CameraPage: TouchUp effect loaded successfully');
    } catch (e) {
      debugPrint('CameraPage: Error loading TouchUp effect: $e');
    }
  }

  void _applyTouchUpChanges(List<String> changes) async {
    // Ensure TouchUp effect is loaded before applying changes
    if (_currentEffectName != 'TouchUp') {
      debugPrint('CameraPage: TouchUp effect not loaded, loading now...');
      await _loadTouchUpEffect();
    }

    for (var element in changes) {
      debugPrint('CameraPage: apply touch-up changes = $element');
      try {
        _banubaSdkManager.evalJs(element);
      } catch (e) {
        debugPrint('CameraPage: Error applying touch-up change: $e');
      }
    }
  }

  void _closePreview() {
    setState(() {
      _showPreview = false;
      _capturedImagePath = null;
    });
    // Restart camera when returning from image preview
    _restartCamera();
  }

  void _closeVideoPreview() {
    setState(() {
      _showVideoPreview = false;
      _filePath = null;
    });
    // Restart camera when returning from video preview
    _restartCamera();
  }

  Future<void> _restartCamera() async {
    try {
      debugPrint('CameraPage: Restarting camera');
      await _banubaSdkManager.stopPlayer();
      await _banubaSdkManager.closeCamera();
      await Future.delayed(
          const Duration(milliseconds: 500)); // Small delay to ensure cleanup
      await openCamera();
      debugPrint('CameraPage: Camera restarted successfully');
    } catch (e) {
      debugPrint('CameraPage: Error restarting camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CameraPage: build');
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

    // Show video preview screen if video is recorded
    if (_showVideoPreview && _filePath != null) {
      return _buildVideoPreviewScreen();
    }

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        if (_showVideoPreview) {
          _closeVideoPreview();
          return false; // Don't pop, we'll handle it ourselves
        }
        if (_showPreview) {
          _closePreview();
          return false; // Don't pop, we'll handle it ourselves
        }
        return true; // Allow normal back navigation
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

            // Effects panel - smaller and positioned better
            if (_showEffectsPanel)
              Positioned(
                top: statusBarHeight + 80,
                left: 20,
                right: 20,
                child: _buildEffectsPanel(),
              ),

            // Touch-up panel on the right side
            if (_showTouchUpPanel)
              Positioned(
                top: statusBarHeight + 80,
                right: 0,
                bottom: 200,
                child: _buildTouchUpPanel(),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(screenSize),
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

  Widget _buildPreviewScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image preview
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

          // Top controls for preview
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back to camera button
                  _buildCircularButton(
                    icon: Icons.arrow_back,
                    onTap: _closePreview,
                    backgroundColor: Colors.black54,
                  ),

                  // Share button
                  // _buildCircularButton(
                  //   icon: Icons.share,
                  //   onTap: () {
                  //     showToastMessage('Share feature coming soon! 📤');
                  //   },
                  //   backgroundColor: Colors.black54,
                  // ),
                ],
              ),
            ),
          ),

          // Bottom controls for preview
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake button
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Retake',
                    onTap: _closePreview,
                    backgroundColor: Colors.red,
                  ),

                  // Save button
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
          // Video preview
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: _filePath != null
                  ? VideoPlayerWidget(
                      videoPath: _filePath!,
                    )
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

          // Top controls for video preview
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back to camera button
                  _buildCircularButton(
                    icon: Icons.arrow_back,
                    onTap: _closeVideoPreview,
                    backgroundColor: Colors.black54,
                  ),

                  // Share button
                  // _buildCircularButton(
                  //   icon: Icons.share,
                  //   onTap: () {
                  //     showToastMessage('Share feature coming soon! 📤');
                  //   },
                  //   backgroundColor: Colors.black54,
                  // ),
                ],
              ),
            ),
          ),

          // Bottom controls for video preview
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake button
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Retake',
                    onTap: _closeVideoPreview,
                    backgroundColor: Colors.red,
                  ),

                  // Save button
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

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - empty for balance
          const SizedBox(width: 50),

          // Center - empty for balance
          const SizedBox(width: 50),

          // Right side - Touch-up toggle button
          _buildCircularButton(
            icon: Icons.face_retouching_natural,
            onTap: () async {
              if (!_showTouchUpPanel) {
                // Load TouchUp effect when opening panel
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

  Widget _buildEffectsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Effects',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildEffectButton('None', null,
                  isSelected: _currentEffectName == null),
              const SizedBox(width: 12),
              ..._effects.map((effect) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildEffectButton(effect, effect,
                        isSelected: _currentEffectName == effect),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEffectButton(String label, String? effect,
      {required bool isSelected}) {
    return GestureDetector(
      onTap: () async {
        if (effect == null) {
          await _banubaSdkManager.unloadEffect();
          setState(() {
            _currentEffectName = null;
            _currentEffectIndex = -1;
          });
        } else {
          setState(() {
            _currentEffectName = effect;
            _currentEffectIndex = _effects.indexOf(effect);
          });
          await _banubaSdkManager.loadEffect('effects/$effect', false);
        }
        setState(() {
          _showEffectsPanel = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white24,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white38,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(Size screenSize) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flashlight button (left)
          _buildCircularButton(
            icon: _enableFlashlight ? Icons.flash_on : Icons.flash_off,
            onTap: () {
              if (!_isFacingFront) {
                setState(() {
                  _enableFlashlight = !_enableFlashlight;
                });
                _banubaSdkManager.enableFlashlight(_enableFlashlight);
              } else {
                showToastMessage(
                    'Flashlight only available on back camera! 📸');
              }
            },
            backgroundColor: _enableFlashlight ? Colors.yellow : Colors.black54,
            size: 50,
          ),

          // Center controls with zoom and capture buttons
          Column(
            children: [
              // Zoom controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildZoomButton('1x', 1.0),
                    _buildZoomButton('2x', 2.0),
                    _buildZoomButton('3x', 3.0),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Capture and record buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo capture button
                  _buildMainCaptureButton(),
                  const SizedBox(width: 20),
                  // Video record button
                  _buildVideoRecordButton(),
                ],
              ),
            ],
          ),

          // Camera flip button (right)
          _buildCircularButton(
            icon: Icons.flip_camera_ios,
            onTap: () {
              _isFacingFront = !_isFacingFront;
              _banubaSdkManager.setCameraFacing(_isFacingFront);
              setState(() {});
            },
            backgroundColor: Colors.black54,
            size: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCaptureButton() {
    return GestureDetector(
      onTap: () {
        // Take photo
        takePhoto();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          color: Colors.white,
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.black,
          size: 35,
        ),
      ),
    );
  }

  Widget _buildVideoRecordButton() {
    return GestureDetector(
      onTap: () {
        if (_isVideoRecording) {
          // Stop recording
          final isVideoRecording = _isVideoRecording;
          setState(() {
            _isVideoRecording = false;
          });
          handleVideoRecording(isVideoRecording);
        } else {
          // Start recording
          setState(() {
            _isVideoRecording = true;
          });
          handleVideoRecording(false);
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isVideoRecording ? Colors.red : Colors.white,
            width: 4,
          ),
          color: _isVideoRecording ? Colors.red : Colors.transparent,
        ),
        child: Icon(
          _isVideoRecording ? Icons.stop : Icons.videocam,
          color: _isVideoRecording ? Colors.white : Colors.white,
          size: 35,
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

  Widget _buildZoomButton(String label, double zoomLevel) {
    final isSelected = _zoom == zoomLevel;
    return GestureDetector(
      onTap: () {
        setState(() {
          _zoom = zoomLevel;
        });
        _banubaSdkManager.setZoom(_zoom);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTouchUpPanel() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.face_retouching_natural,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Touch Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showTouchUpPanel = false;
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Categories list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _touchUpCategories.length,
              itemBuilder: (context, index) {
                return _buildTouchUpCategoryExpansionTile(
                    _touchUpCategories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouchUpCategoryExpansionTile(TouchUpCategory category) {
    return ExpansionTile(
      title: Text(
        category.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconColor: Colors.purple,
      collapsedIconColor: Colors.purple,
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      children: category.features.map((feature) {
        return _buildTouchUpSlider(feature);
      }).toList(),
    );
  }

  Widget _buildTouchUpSlider(TouchUpFeature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                feature.name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '${feature.progressValue.toInt()}',
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.purple,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.purple,
              overlayColor: Colors.purple.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: feature.progressValue,
              min: feature.min,
              max: feature.max,
              onChanged: (value) {
                setState(() {
                  feature.progressValue = value;
                });
                _applyTouchUpChanges(feature.processor(value / 100));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyCategoryFilters(TouchUpCategory category) {
    // Apply default values for all features in the category
    for (var feature in category.features) {
      // Set a moderate default value (50% of max)
      double defaultValue = feature.max * 0.5;
      if (feature.min < 0) {
        defaultValue = 0; // For features that can be negative, start at 0
      }

      setState(() {
        feature.progressValue = defaultValue;
      });
      _applyTouchUpChanges(feature.processor(defaultValue / 100));
    }

    showToastMessage('${category.name} filters applied! ✨');
  }
}

class TouchUpCategory {
  final String name;
  final IconData icon;
  final List<TouchUpFeature> features;

  TouchUpCategory({
    required this.name,
    required this.icon,
    required this.features,
  });
}

class TouchUpFeature {
  String name;
  double progressValue;
  Processor processor;
  double min;
  double max;

  TouchUpFeature({
    required this.name,
    required this.progressValue,
    required this.processor,
    required this.min,
    required this.max,
  });
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({Key? key, required this.videoPath})
      : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(io.File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        // Auto-play the video when initialized
        _controller.play();
        _isPlaying = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? SafeArea(
            child: Stack(
              children: [
                // Video player
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),

                // Video controls overlay
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isPlaying) {
                          _controller.pause();
                          _isPlaying = false;
                        } else {
                          _controller.play();
                          _isPlaying = true;
                        }
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-right controls
                Positioned(
                  top: 20,
                  right: 20,
                  child: Row(
                    children: [
                      // Mute/Unmute button
                      _buildControlButton(
                        icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                        onTap: () {
                          setState(() {
                            _isMuted = !_isMuted;
                            _controller.setVolume(_isMuted ? 0.0 : 1.0);
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      // Play/Pause button
                      _buildControlButton(
                        icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                        onTap: () {
                          setState(() {
                            if (_isPlaying) {
                              _controller.pause();
                              _isPlaying = false;
                            } else {
                              _controller.play();
                              _isPlaying = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Video progress indicator
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _controller.value.position.inMilliseconds /
                          _controller.value.duration.inMilliseconds,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            ),
          );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
