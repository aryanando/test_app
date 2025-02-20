import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../widgets/youtube_embed.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final user = post['user'] ?? {};
    final String userName = user['name'] ?? 'Unknown User';
    final String postTime = post['created_at'] != null
        ? timeago.format(DateTime.parse(post['created_at']))
        : "Unknown Time";
    final String? imageUrl = post['image'];
    final String? videoUrl =
        post['video']; // ✅ Video can be YouTube or uploaded file
    final String content = post['content'] ?? 'No content available';
    final int likeCount = post['like_count'] ?? 0;
    // final int dislikeCount = post['dislike_count'] ?? 0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Information Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(postTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // Post Content (If No Media)
            if (imageUrl == null && videoUrl == null)
              Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: 200),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    content,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                  ),
                ),
              ),

            // ✅ Show Image Below Video (if available)
            if (imageUrl != null && imageUrl.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    headers: {"Access-Control-Allow-Origin": "*"},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text("Image not found link: $error",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),

            // Detect if Video is YouTube or Uploaded File
            if (videoUrl != null && videoUrl.isNotEmpty)
              _buildVideoWidget(videoUrl, content),

            SizedBox(height: 10),

            // Like & Dislike Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.blue),
                      onPressed: () {
                        context.read<PostBloc>().add(LikePostEvent(post['id']));
                      },
                    ),
                    Text("$likeCount",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                // Row(
                //   children: [
                //     Icon(Icons.thumb_down, color: Colors.red, size: 20),
                //     SizedBox(width: 5),
                //     Text("$dislikeCount",
                //         style: TextStyle(
                //             fontSize: 14, fontWeight: FontWeight.bold)),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Function to detect YouTube videos or normal uploaded videos
  Widget _buildVideoWidget(String videoUrl, String content) {
    if (videoUrl.contains("youtube.com") || videoUrl.contains("youtu.be")) {
      return Column(
        children: [
          YouTubeEmbed(youtubeUrl: videoUrl),
          if (content.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft, // ✅ Aligns text to the left
                child: Text(
                  content,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left, // ✅ Ensures text is left-aligned
                ),
              ),
            ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child:
                  Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
            ),
          ),
          if (content.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                content,
                style: TextStyle(fontSize: 16),
              ),
            ),
        ],
      );
    }
  }
}
