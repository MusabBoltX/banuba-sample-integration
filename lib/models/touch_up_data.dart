import 'package:flutter/material.dart';
import 'touch_up_models.dart';

class TouchUpData {
  static List<TouchUpCategory> getCategories() {
    return [
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
            processor: (double progress) =>
                ['FaceMorph.lips({size: $progress})'],
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
  }
}
