import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../blocs/post/post_state.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_widget.dart';
import 'login_screen.dart'; // ✅ Import Login Screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<PostBloc>().add(LoadPostsEvent());
  }

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

  /// ✅ Dispatch Logout Event to `AuthBloc`
  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent()); // ✅ Dispatch logout event
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // ✅ Redirect to Login Screen on Logout
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white), // ✅ Logout Button
              onPressed: _logout,
            ),
          ],
        ),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading && state is! PostLoaded) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PostLoaded) {
              if (state.posts.isEmpty) {
                return Center(child: Text("No posts available"));
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: state.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CreatePostWidget();
                  }
                  return PostCard(post: state.posts[index - 1]);
                },
              );
            } else if (state is PostError) {
              return Center(child: Text(state.message));
            }

            return Center(child: Text("No posts available"));
          },
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
