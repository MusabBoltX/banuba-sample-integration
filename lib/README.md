# Flutter Banuba SDK Example - Modular Structure

This project has been refactored to follow a clean, modular architecture with separated concerns.

## Project Structure

```
lib/
├── models/                 # Data models and enums
│   ├── camera_models.dart  # Camera-related enums and constants
│   ├── touch_up_models.dart # Touch-up feature data models
│   └── touch_up_data.dart  # Touch-up feature configurations
├── services/              # Business logic and SDK management
│   └── banuba_service.dart # Banuba SDK wrapper service
├── utils/                 # Helper functions and utilities
│   └── helpers.dart       # Common utility functions
├── widgets/               # Reusable UI components
│   ├── camera_controls.dart    # Camera control buttons
│   ├── touch_up_panel.dart     # Touch-up features panel
│   └── video_player_widget.dart # Video player component
├── pages/                 # Page implementations
│   └── camera_page_clean.dart  # Clean, modular camera page
└── main.dart              # App entry point
```

## Key Improvements

### 1. **Separation of Concerns**
- **Models**: Data structures and configurations
- **Services**: Business logic and SDK operations
- **Widgets**: Reusable UI components
- **Utils**: Helper functions and constants

### 2. **Modular Components**
- `CameraControls`: Handles all camera control buttons
- `TouchUpPanel`: Manages touch-up features interface
- `VideoPlayerWidget`: Video playback functionality
- `BanubaService`: SDK operations wrapper

### 3. **Clean Data Management**
- `TouchUpData`: Centralized touch-up feature configurations
- `CameraSettings`: Camera-related constants
- Type-safe models with proper encapsulation

### 4. **Reduced Code Duplication**
- Common functionality extracted to reusable components
- Shared utility functions
- Consistent UI patterns

## Usage

### Using the Clean Camera Page

```dart
// Navigate to the clean camera page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CameraPageClean(banubaToken: banubaToken),
  ),
);
```

### Adding New Touch-up Features

1. Add the feature to `TouchUpData.getCategories()` in `models/touch_up_data.dart`
2. The feature will automatically appear in the touch-up panel

### Creating New Widgets

1. Create a new file in the `widgets/` directory
2. Follow the established patterns for props and callbacks
3. Import and use in your pages

## Benefits

1. **Maintainability**: Easier to find and modify specific functionality
2. **Testability**: Components can be tested in isolation
3. **Reusability**: Widgets can be used across different pages
4. **Scalability**: Easy to add new features without affecting existing code
5. **Readability**: Clear separation makes code easier to understand

## Migration Notes

- The original `page_camera.dart` is still available for reference
- All functionality has been preserved in the new structure
- The clean camera page (`CameraPageClean`) is now the default implementation
- Helper functions have been moved to `utils/helpers.dart`

## Next Steps

1. Apply similar refactoring to other pages (`page_image.dart`, `page_touchup.dart`, `page_arcloud.dart`)
2. Create additional services for image processing and AR cloud functionality
3. Add unit tests for the new modular components
4. Implement state management (Provider/Riverpod) for better data flow 