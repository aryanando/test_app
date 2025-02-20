import 'dart:io';

abstract class PostEvent {}

class LoadPostsEvent extends PostEvent {}

class LikePostEvent extends PostEvent {
  final int postId;
  LikePostEvent(this.postId);
}

class CreatePostEvent extends PostEvent {
  final String? content;
  final File? image;
  final File? video;
  final String? youtubeLink;

  CreatePostEvent({this.content, this.image, this.video, this.youtubeLink});
}
