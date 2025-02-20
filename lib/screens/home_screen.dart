import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../blocs/post/post_state.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_widget.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool isLoading = false;
  int? currentUserId; // ✅ Store the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<PostBloc>().add(LoadPostsEvent());
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  /// ✅ Load more posts when reaching bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !isLoading) {
      setState(() => isLoading = true);
      context.read<PostBloc>().add(LoadPostsEvent());
      Future.delayed(
          Duration(seconds: 1), () => setState(() => isLoading = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            /// ✅ `SliverToBoxAdapter` to include `CreatePostWidget`
            SliverToBoxAdapter(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoaded) {
                    currentUserId = state.user['id']; // ✅ Store user ID
                    return CreatePostWidget(
                      profileImageUrl: state.user['profile_image'] ?? "",
                      userName: state.user['name'] ?? "User",
                    );
                  } else if (state is ProfileLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return CreatePostWidget(
                      profileImageUrl: "",
                      userName: "User",
                    );
                  }
                },
              ),
            ),

            /// ✅ `SliverList` for better performance
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading && state is! PostLoaded) {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is PostLoaded) {
                  if (state.posts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(child: Text("No posts available")),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return PostCard(
                          post: state.posts[index],
                          currentUserId: currentUserId ?? -1, // ✅ Pass user ID
                        );
                      },
                      childCount: state.posts.length,
                    ),
                  );
                } else if (state is PostError) {
                  return SliverFillRemaining(
                    child: Center(child: Text(state.message)),
                  );
                }

                return SliverFillRemaining(
                  child: Center(child: Text("No posts available")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
