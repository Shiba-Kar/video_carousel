# Video Carousel

This package provides a simple and customizable way to create a video carousel in Flutter. It allows you to display a list of video files in a carousel format, with options for autoplay and custom tap actions.

## Installation

To use this package, add `video_carousel` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

```yaml
dependencies:
    video_carousel: ^version_number
```
```dart
import 'package:video_carousel/video_carousel.dart';

VideoCarousel(
    files: ['assets/video1.mp4', 'assets/video2.mp4', 'assets/video3.mp4'],
    onTap: (index) {
        print('Tapped on video $index');
    },
    autoPlay: true,
)

```