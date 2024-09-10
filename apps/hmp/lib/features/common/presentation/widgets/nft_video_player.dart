import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class NftVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const NftVideoPlayer({super.key, required this.videoUrl});

  @override
  State<NftVideoPlayer> createState() => _NftVideoPlayerState();
}

class _NftVideoPlayerState extends State<NftVideoPlayer> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            looping: true,
            autoPlay: true,
          );
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized && _chewieController != null
          ? Chewie(
              controller: _chewieController!,
            )
          : const CircularProgressIndicator(),
    );
  }
}
