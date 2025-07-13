import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class CameraControls extends StatelessWidget {
  final bool enableFlashlight;
  final bool isFacingFront;
  final double zoom;
  final bool isVideoRecording;
  final VoidCallback onFlashlightToggle;
  final VoidCallback onCameraFlip;
  final Function(double) onZoomChange;
  final VoidCallback onPhotoCapture;
  final VoidCallback onVideoRecord;

  const CameraControls({
    Key? key,
    required this.enableFlashlight,
    required this.isFacingFront,
    required this.zoom,
    required this.isVideoRecording,
    required this.onFlashlightToggle,
    required this.onCameraFlip,
    required this.onZoomChange,
    required this.onPhotoCapture,
    required this.onVideoRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flashlight button (left)

          _buildCircularButton(
            icon: enableFlashlight ? Icons.flash_on : Icons.flash_off,
            onTap: onFlashlightToggle,
            backgroundColor: enableFlashlight ? Colors.yellow : Colors.black54,
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
            onTap: onCameraFlip,
            backgroundColor: Colors.black54,
            size: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCaptureButton() {
    return GestureDetector(
      onTap: onPhotoCapture,
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
      onTap: onVideoRecord,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isVideoRecording ? Colors.red : Colors.white,
            width: 4,
          ),
          color: isVideoRecording ? Colors.red : Colors.transparent,
        ),
        child: Icon(
          isVideoRecording ? Icons.stop : Icons.videocam,
          color: isVideoRecording ? Colors.white : Colors.white,
          size: 35,
        ),
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
    final isSelected = zoom == zoomLevel;
    return GestureDetector(
      onTap: () => onZoomChange(zoomLevel),
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
}
