import 'package:flutter/material.dart';
import '../models/touch_up_models.dart';
import '../utils/helpers.dart';

class TouchUpPanel extends StatefulWidget {
  final List<TouchUpCategory> categories;
  final Function(List<String>) onApplyChanges;
  final VoidCallback onClose;

  const TouchUpPanel({
    Key? key,
    required this.categories,
    required this.onApplyChanges,
    required this.onClose,
  }) : super(key: key);

  @override
  State<TouchUpPanel> createState() => _TouchUpPanelState();
}

class _TouchUpPanelState extends State<TouchUpPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
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
                  onTap: widget.onClose,
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
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                return _buildTouchUpCategoryExpansionTile(
                    widget.categories[index]);
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
                widget.onApplyChanges(feature.processor(value / 100));
              },
            ),
          ),
        ],
      ),
    );
  }
}
