import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/screens/create_post_screen.dart';
// import 'package:timeago/timeago.dart' as timeago;
import '../widgets/post_card.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../blocs/post/post_state.dart';

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
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context
          .read<PostBloc>()
          .add(LoadPostsEvent()); // ✅ Load more posts only when at the bottom
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
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
              itemCount: state.posts.length +
                  (isLoading ? 1 : 0), // ✅ Show loader when fetching
              itemBuilder: (context, index) {
                if (index == state.posts.length) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // ✅ Show loader at bottom
                }
                return PostCard(post: state.posts[index]);
              },
            );
          } else if (state is PostError) {
            return Center(child: Text(state.message));
          }

          return Center(child: Text("No posts available"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => CreatePostScreen()));
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
