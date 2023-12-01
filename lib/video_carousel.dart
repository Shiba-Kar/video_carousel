/// A library for creating a video carousel widget in Flutter.
library video_carousel;

import 'dart:io';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';

/// A widget that displays a carousel of videos.
class VideoCarousel extends StatefulWidget {
  final List<File> files;
  final double? height;
  final Function(File file)? onTap;
  final bool? autoPlay;

  /// Creates a [VideoCarousel] widget.
  ///
  /// The [files] parameter is a list of video files to be displayed in the carousel.
  /// The [height] parameter specifies the height of the carousel.
  /// The [onTap] parameter is a callback function that is called when a video is tapped.
  /// The [autoPlay] parameter specifies whether the videos should autoplay.
  const VideoCarousel({
    super.key,
    required this.files,
    this.onTap,
    this.height = 400,
    this.autoPlay = false,
  });

  @override
  State<VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel> {
  final List<GlobalKey<VideoScreenState>> keys = [];
  bool autoplay = false;
  final CarouselController _carouselController = CarouselController();

  @override
  void dispose() {
    super.dispose();
    _carouselController.stopAutoPlay();
    for (var key in keys) {
      key.currentState?.dispose();
    }
  }

  @override
  void initState() {
    keys.addAll(List.generate(
      widget.files.length,
      (index) => GlobalKey<VideoScreenState>(
          debugLabel: "$index ${_carouselController.hashCode}"),
    ));
    autoplay = widget.autoPlay!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    onPageChanged(int index, CarouselPageChangedReason reason) async {
      if (index != 0) {
        await keys[index - 1].currentState?.stop();
      }

      keys[index].currentState?.play();
    }

    List<Widget> widgets = [];

    for (var i = 0; i < widget.files.length; i++) {
      widgets.add(VideoScreen(
        widget.files[i],
        key: keys[i],
        onTap: (f) {
          widget.onTap?.call(f);
        },
      ));
    }
    return VisibilityDetector(
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage == 100.0) {
          autoplay = true;
          setState(() {});
        } else {
          if (mounted) {
            autoplay = false;
            setState(() {});
          }
        }
      },
      key: Key("${_carouselController.hashCode}"),
      child: CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
          height: widget.height,
          enableInfiniteScroll: false,
          autoPlay: autoplay,
          viewportFraction: 0.6,
          enlargeCenterPage: false,
          onPageChanged: onPageChanged,
          initialPage: 0,
        ),
        items: widgets,
      ),
    );
  }
}

/// A widget that displays a video.
class VideoScreen extends StatefulWidget {
  final File file;
  final bool run;
  final Function(File file)? onTap;

  /// Creates a [VideoScreen] widget.
  ///
  /// The [file] parameter is the video file to be displayed.
  /// The [run] parameter specifies whether the video should start playing immediately.
  /// The [onTap] parameter is a callback function that is called when the video is tapped.
  const VideoScreen(
    this.file, {
    super.key,
    this.run = false,
    this.onTap,
  });

  @override
  State<VideoScreen> createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        if (widget.run) play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: InkWell(
                onTap: () {
                  if (widget.onTap != null) widget.onTap!(widget.file);
                },
                child: VisibilityDetector(
                    onVisibilityChanged: (visibilityInfo) async {
                      var visiblePercentage =
                          visibilityInfo.visibleFraction * 100;
                      if (visiblePercentage == 100.0) {
                        await play();
                      } else {
                        await stop();
                      }
                    },
                    key: Key("${_controller.hashCode}"),
                    child: VideoPlayer(_controller)),
              ),
            ),
          )
        : Container();
  }

  Future stop() async {
    if (mounted) await _controller.pause();
  }

  Future play() async {
    if (mounted) await _controller.play();
  }

  Future noAudio() async {
    if (mounted) await _controller.setVolume(0.0);
  }

  @override
  void dispose() async {
    super.dispose();
    await stop();
    await _controller.dispose();
  }
}
