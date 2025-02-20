import 'package:flutter/material.dart';
import 'package:test_app/widgets/video_player_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../widgets/youtube_embed.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final int currentUserId; // ✅ Pass the logged-in user's ID

  const PostCard({super.key, required this.post, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final user = post['user'] ?? {};
    final int postOwnerId = user['id'] ?? -1; // ✅ Owner of the post
    final String userName = user['name'] ?? 'Unknown User';
    final String postTime = post['created_at'] != null
        ? timeago.format(DateTime.parse(post['created_at']))
        : "Unknown Time";
    final String? imageUrl = post['image'];
    final String? videoUrl = post['video'];
    final String content = post['content'] ?? 'No content available';
    final int likeCount = post['like_count'] ?? 0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ User Information Row with Three Dots Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: (user['profile_image'] != null &&
                              user['profile_image'].isNotEmpty)
                          ? NetworkImage(user['profile_image'])
                          : null, // ✅ Use default icon if null
                      child: (user['profile_image'] == null ||
                              user['profile_image'].isEmpty)
                          ? Icon(Icons.person,
                              size: 24, color: Colors.grey[700])
                          : null,
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

                // ✅ Three Dots Menu (Only if User Owns the Post)
                if (currentUserId == postOwnerId)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDeletePost(context, post['id']);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Delete Post"),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 10),

            // ✅ Post Content (If No Media)
            if (imageUrl == null && videoUrl == null) _buildContentBox(content),

            // ✅ Show Image Below Video (if available)
            if (imageUrl != null && imageUrl.isNotEmpty)
              _buildImageWidget(imageUrl),

            // ✅ Detect & Display Video (YouTube or Uploaded)
            if (videoUrl != null && videoUrl.isNotEmpty)
              _buildVideoWidget(videoUrl, content),

            SizedBox(height: 10),

            // ✅ Like & Interaction Row
            _buildInteractionRow(context, likeCount),
          ],
        ),
      ),
    );
  }

  /// ✅ Function to Confirm Post Deletion
  void _confirmDeletePost(BuildContext context, int postId) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete Post"),
            content: isDeleting
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Deleting post..."),
                    ],
                  )
                : Text("Are you sure you want to delete this post?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  setState(() => isDeleting = true); // ✅ Show loader

                  // ✅ Dispatch delete event
                  context.read<PostBloc>().add(DeletePostEvent(postId));

                  // ✅ Wait briefly before closing
                  await Future.delayed(Duration(milliseconds: 500));

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
      },
    );
  }

  /// ✅ Function to Display Post Content in a Box
  Widget _buildContentBox(String content) {
    return Container(
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
    );
  }

  /// ✅ Function to Load Image with Error Handling
  Widget _buildImageWidget(String imageUrl) {
    // ✅ Convert relative path to full URL
    final String baseUrl = "https://api-nando.batubhayangkara.com/storage/";
    String fixedImageUrl =
        (!imageUrl.startsWith("http")) ? "$baseUrl$imageUrl" : imageUrl;

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          fixedImageUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text("Image not available",
                style: TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  /// ✅ Function to Detect & Display Videos (Uploaded or YouTube)
  Widget _buildVideoWidget(String videoUrl, String content) {
    final String baseUrl = "https://api-nando.batubhayangkara.com/storage/";

    // ✅ Convert relative path to full URL
    if (!videoUrl.startsWith("http")) {
      videoUrl = "$baseUrl$videoUrl";
    }

    if (videoUrl.contains("youtube.com") || videoUrl.contains("youtu.be")) {
      return Column(
        children: [
          YouTubeEmbed(youtubeUrl: videoUrl), // ✅ Show YouTube Video
          if (content.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(content, style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      );
    } else {
      return _buildUploadedVideoPlayer(videoUrl, content);
    }
  }

  /// ✅ Function to Play Uploaded Videos Using `video_player`
  Widget _buildUploadedVideoPlayer(String videoUrl, String content) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity, // ✅ Set width
          height: 200, // ✅ Set a fixed height
          child: VideoPlayerWidget(videoUrl: videoUrl),
        ),
        if (content.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(content, style: TextStyle(fontSize: 16)),
          ),
      ],
    );
  }

  /// ✅ Function to Build Like Button & Interactions
  Widget _buildInteractionRow(BuildContext context, int likeCount) {
    return Row(
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
