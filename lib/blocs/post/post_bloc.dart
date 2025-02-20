import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../repository/auth_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final AuthRepository authRepository;
  List<Map<String, dynamic>> _allPosts = []; // ✅ Keep track of posts
  int _currentPage = 1; // ✅ Keep track of pagination
  bool _isFetching = false;
  bool _hasMorePages = true;

  PostBloc(this.authRepository) : super(PostInitial()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<LikePostEvent>(_onLikePost);
    on<CreatePostEvent>(_onCreatePost);
    on<DeletePostEvent>(_onDeletePost); // ✅ Handle delete post
  }

  Future<void> _onLoadPosts(
      LoadPostsEvent event, Emitter<PostState> emit) async {
    if (_isFetching || !_hasMorePages) return; // ✅ Prevent unnecessary calls

    _isFetching = true;

    final response = await authRepository.getPosts(_currentPage);

    if (response != null) {
      final List<Map<String, dynamic>> newPosts =
          List<Map<String, dynamic>>.from(response['data']);
      final String? nextPageUrl = response['next_page_url'];

      if (newPosts.isNotEmpty) {
        _allPosts.addAll(newPosts);
        _currentPage++;
      }

      _hasMorePages =
          nextPageUrl != null; // ✅ Stop fetching if last page reached

      emit(PostLoaded(List.from(_allPosts)));
    } else {
      emit(PostError("Failed to load posts"));
    }

    _isFetching = false;
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<PostState> emit) async {
    final newLikeCount = await authRepository.likePost(event.postId);

    if (newLikeCount != null) {
      // ✅ Update post in the list
      _allPosts = _allPosts.map((post) {
        if (post['id'] == event.postId) {
          return {
            ...post,
            'like_count': newLikeCount, // ✅ Correctly update like count
          };
        }
        return post;
      }).toList();

      emit(PostLoaded(List.from(_allPosts))); // ✅ Refresh UI
    }
  }

  Future<void> _onCreatePost(
      CreatePostEvent event, Emitter<PostState> emit) async {
    final response = await authRepository.createPost(
      content: event.content,
      image: event.image,
      video: event.video,
      youtubeLink: event.youtubeLink,
    );

    if (response != null && response.containsKey('post')) {
      _allPosts.insert(0, response['post']); // ✅ Add new post to the top
      emit(PostLoaded(List.from(_allPosts))); // ✅ Refresh UI
    } else {
      emit(PostError("Failed to create post"));
    }
  }

  /// ✅ Delete Post Function
  Future<void> _onDeletePost(
      DeletePostEvent event, Emitter<PostState> emit) async {
    final bool isDeleted = await authRepository.deletePost(event.postId);

    if (isDeleted) {
      _allPosts.removeWhere(
          (post) => post['id'] == event.postId); // ✅ Remove from list
      emit(PostLoaded(List.from(_allPosts))); // ✅ Refresh UI
    } else {
      emit(PostError("Failed to delete post"));
    }
  }
}
