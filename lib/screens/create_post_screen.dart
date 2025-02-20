import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController youtubeLinkController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedVideo = File(pickedFile.path));
    }
  }

  void _submitPost() {
    context.read<PostBloc>().add(CreatePostEvent(
          content: contentController.text,
          image: _selectedImage,
          video: _selectedVideo,
          youtubeLink: youtubeLinkController.text.isNotEmpty
              ? youtubeLinkController.text
              : null,
        ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Post Content')),
            TextField(
                controller: youtubeLinkController,
                decoration:
                    InputDecoration(labelText: 'YouTube Link (Optional)')),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: Text("Pick Image")),
            ElevatedButton(onPressed: _pickVideo, child: Text("Pick Video")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _submitPost, child: Text("Create Post")),
          ],
        ),
      ),
    );
  }
}
