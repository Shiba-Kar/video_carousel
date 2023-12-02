import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:video_carousel/video_carousel.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<File> files = [];
  Future<File> createFileFromAsset(String asset) async {
    ByteData data = await rootBundle.load(asset);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final fileName = asset.split('/').last;
    File tempFile = File('$tempPath/$fileName');
    await tempFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return tempFile;
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    var fs = await Future.wait([
      createFileFromAsset('assets/1.mp4'),
      createFileFromAsset('assets/2.mp4'),
      createFileFromAsset('assets/3.mp4'),
      createFileFromAsset('assets/4.mp4')
    ]);

    files.addAll(fs);

    print(files);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: files.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  VideoCarousel(files: files),
                  const SizedBox(height: 200),
                  VideoCarousel(files: files),
                ],
              ),
      ),
    );
  }
}
