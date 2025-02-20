import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Import url_launcher

class YouTubeEmbed extends StatefulWidget {
  final String youtubeUrl;

  YouTubeEmbed({required this.youtubeUrl});

  @override
  _YouTubeEmbedState createState() => _YouTubeEmbedState();
}

class _YouTubeEmbedState extends State<YouTubeEmbed> {
  late YoutubePlayerController _controller;
  String? videoId;

  @override
  void initState() {
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoId == null) {
      return Center(child: Text("Invalid YouTube Link"));
    }

    return GestureDetector(
      onTap: () => {
        _launchYouTube("https://www.youtube.com/watch?v=$videoId"),
        print('https://www.youtube.com/watch?v=$videoId')
      }, // ✅ Ensure tap works
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // ✅ Make it look better
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
        ),
      ),
    );
  }

  // ✅ Function to launch YouTube link in a browser or app
  Future<void> _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
