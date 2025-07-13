import 'package:flutter/material.dart';

typedef List<String> Processor(double progress);

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

class Feature {
  String name;
  double progressValue;
  Processor processor;
  double min;
  double max;

  Feature({
    required this.name,
    required this.progressValue,
    required this.processor,
    required this.min,
    required this.max,
  });
}
