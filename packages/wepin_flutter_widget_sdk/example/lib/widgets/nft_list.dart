import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // 동영상 재생을 위해 추가
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class WepinNFTListScreen extends StatelessWidget {
  final List<WepinNFT> wepinNFTs;

  const WepinNFTListScreen({Key? key, required this.wepinNFTs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wepin NFTs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: wepinNFTs.length,
        itemBuilder: (context, index) {
          return _buildNFTCard(wepinNFTs[index]);
        },
      ),
    );
  }

  Widget _buildNFTCard(WepinNFT wepinNFT) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wepinNFT.contentType == 'image') ...[
            _buildImage(wepinNFT.imageUrl),
          ] else if (wepinNFT.contentType == 'video') ...[
            _buildVideo(wepinNFT.contentUrl),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wepinNFT.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  wepinNFT.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Network: ${wepinNFT.account.network}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Contract: ${wepinNFT.contract.address}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Scheme: ${wepinNFT.contract.scheme}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'ContentType: ${wepinNFT.contentType}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 250.0,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 250.0,
            color: Colors.grey[300],
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideo(String? videoUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
      child: VideoPlayerWidget(videoUrl: videoUrl),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;

  const VideoPlayerWidget({Key? key, this.videoUrl}) : super(key: key);

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          setState(() {}); // 동영상이 초기화된 후 다시 빌드
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null && _controller!.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    )
        : const SizedBox(
      height: 250.0,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
