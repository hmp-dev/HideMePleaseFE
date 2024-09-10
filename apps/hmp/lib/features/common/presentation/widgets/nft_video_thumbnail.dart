import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class NftVideoThumbnailFromUrl extends StatefulWidget {
  final String videoUrl;
  final double imgHeight;
  final double imageWidth;

  const NftVideoThumbnailFromUrl({
    super.key,
    required this.videoUrl,
    this.imgHeight = 64,
    this.imageWidth = 63,
  });

  @override
  State<NftVideoThumbnailFromUrl> createState() =>
      _NftVideoThumbnailFromUrlState();
}

class _NftVideoThumbnailFromUrlState extends State<NftVideoThumbnailFromUrl> {
  String? _thumbnailFilePath;

  @override
  void initState() {
    super.initState();
    _generateThumbnailFromUrl();
  }

  Future<void> _generateThumbnailFromUrl() async {
    "NftVideoThumbnailFromUrl -> _generateThumbnailFromUrl is called for ${widget.videoUrl}"
        .log();

    try {
      // Generate thumbnail from video URL
      final String? fileName = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: (await getTemporaryDirectory())
            .path, // Store in temporary directory
        imageFormat: ImageFormat.JPEG, // Format of the thumbnail image
        maxHeight: widget.imgHeight
            .toInt(), // Set height, width auto-scales to keep the aspect ratio
        quality: 100, // Quality of the image
      );

      setState(() {
        _thumbnailFilePath = fileName;
      });
    } catch (e) {
      print("Error generating thumbnail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnailFilePath != null
        ? Image.file(
            File(_thumbnailFilePath!),
            width: widget.imageWidth,
            height: widget.imgHeight,
            fit: BoxFit.cover,
          )
        : SizedBox(
            width: widget.imageWidth,
            height: widget.imgHeight,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
  }
}
