import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';

class CreatePostWidget extends StatefulWidget {
  final String profileImageUrl;
  final String userName;

  CreatePostWidget({required this.profileImageUrl, required this.userName});

  @override
  _CreatePostWidgetState createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController contentController = TextEditingController();
  String? youtubeLink; // ✅ Store YouTube link
  File? _selectedImage;
  File? _selectedVideo;

  final picker = ImagePicker();

  /// ✅ Pick Image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null)
      setState(() => _selectedImage = File(pickedFile.path));
  }

  /// ✅ Pick Video from Camera or Gallery
  Future<void> _pickVideo(ImageSource source) async {
    final pickedFile = await picker.pickVideo(source: source);
    if (pickedFile != null)
      setState(() => _selectedVideo = File(pickedFile.path));
  }

  /// ✅ Paste YouTube Link from Clipboard
  Future<void> _pasteYoutubeLink() async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text!.contains("youtube.com")) {
      setState(() {
        youtubeLink = clipboardData.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("YouTube link pasted!"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid YouTube link!"),
        backgroundColor: Colors.red,
      ));
    }
  }

  /// ✅ Show Attachment Dialog (Image, Video, YouTube Link)
  void _showAttachmentDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 📷 **Photo Options**
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue, size: 20),
                title: Text("Take Photo", style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image, color: Colors.blue, size: 20),
                title:
                    Text("Select from Gallery", style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              /// 🎥 **Video Options**
              ListTile(
                leading: Icon(Icons.videocam, color: Colors.red, size: 20),
                title: Text("Record Video", style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: Colors.red, size: 20),
                title: Text("Select Video from Gallery",
                    style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),

              /// 🔗 **YouTube Link Option**
              ListTile(
                leading: Icon(Icons.paste, color: Colors.green, size: 20),
                title:
                    Text("Paste YouTube Link", style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _pasteYoutubeLink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitPost() {
    if (contentController.text.isEmpty &&
        _selectedImage == null &&
        _selectedVideo == null &&
        youtubeLink == null) {
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
          youtubeLink: youtubeLink,
        ));

    // ✅ Clear inputs after posting
    setState(() {
      contentController.clear();
      youtubeLink = null;
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
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Compact Row: Profile, Input, Attach & Post Buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20, // ✅ Smaller Profile Picture
                  backgroundColor: Colors.grey[300],
                  child: widget.profileImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.profileImageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person,
                                  size: 24,
                                  color: Colors
                                      .grey[700]); // ✅ Fallback to default icon
                            },
                          ),
                        )
                      : Icon(Icons.person,
                          size: 24,
                          color: Colors
                              .grey[700]), // ✅ Default icon if no profile image
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind, ${widget.userName}?",
                      hintStyle: TextStyle(fontSize: 14),
                      border: InputBorder.none,
                    ),
                    maxLines: 1,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.blue, size: 20),
                  onPressed: _showAttachmentDialog,
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green, size: 20),
                  onPressed: _submitPost,
                ),
              ],
            ),

            SizedBox(height: 6),

            // ✅ Show Selected YouTube Link
            if (youtubeLink != null)
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        youtubeLink!,
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: () => setState(() => youtubeLink = null),
                    ),
                  ],
                ),
              ),

            // ✅ Show Selected Media (Image or Video)
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child:
                    Image.file(_selectedImage!, height: 120, fit: BoxFit.cover),
              ),

            if (_selectedVideo != null)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child:
                      Icon(Icons.video_library, color: Colors.white, size: 30),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
