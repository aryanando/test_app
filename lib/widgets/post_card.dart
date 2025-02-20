import 'package:flutter/material.dart';
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
                      child: user['profile_image'] != null &&
                              user['profile_image'].isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.network(
                                user['profile_image'],
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person,
                                      size: 24, color: Colors.grey[700]);
                                },
                              ),
                            )
                          : Icon(Icons.person,
                              size: 24, color: Colors.grey[700]),
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
      builder: (context) => AlertDialog(
        title: Text("Delete Post"),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<PostBloc>().add(DeletePostEvent(postId));
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
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

  /// ✅ Function to Detect & Display Videos (YouTube or Uploaded)
  Widget _buildVideoWidget(String videoUrl, String content) {
    print(videoUrl);
    if (videoUrl.contains("youtube.com") || videoUrl.contains("youtu.be")) {
      return Column(
        children: [
          YouTubeEmbed(youtubeUrl: videoUrl),
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
              child: Text(content, style: TextStyle(fontSize: 16)),
            ),
        ],
      );
    }
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
