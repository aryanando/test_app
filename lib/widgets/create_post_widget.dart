import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';

class CreatePostWidget extends StatefulWidget {
  @override
  _CreatePostWidgetState createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController youtubeLinkController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null)
      setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null)
      setState(() => _selectedVideo = File(pickedFile.path));
  }

  void _submitPost() {
    if (contentController.text.isEmpty &&
        _selectedImage == null &&
        _selectedVideo == null &&
        youtubeLinkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Post cannot be empty!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    context.read<PostBloc>().add(CreatePostEvent(
          content: contentController.text,
          image: _selectedImage,
          video: _selectedVideo,
          youtubeLink: youtubeLinkController.text.isNotEmpty
              ? youtubeLinkController.text
              : null,
        ));

    // Clear inputs after posting
    setState(() {
      contentController.clear();
      youtubeLinkController.clear();
      _selectedImage = null;
      _selectedVideo = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Post Created!"),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Content Input
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
              maxLines: 2,
            ),
            SizedBox(height: 10),

            // YouTube Link Input
            TextField(
              controller: youtubeLinkController,
              decoration: InputDecoration(
                hintText: "Paste YouTube link (Optional)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Selected Image Preview
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 100, fit: BoxFit.cover),

            // Selected Video Placeholder
            if (_selectedVideo != null)
              Container(
                height: 100,
                color: Colors.black,
                child: Center(
                    child: Icon(Icons.video_library, color: Colors.white)),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image Picker Button
                IconButton(
                  icon: Icon(Icons.image, color: Colors.blue),
                  onPressed: _pickImage,
                ),

                // Video Picker Button
                IconButton(
                  icon: Icon(Icons.videocam, color: Colors.red),
                  onPressed: _pickVideo,
                ),

                // Submit Post Button
                ElevatedButton(
                  onPressed: _submitPost,
                  child: Text("Post"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
