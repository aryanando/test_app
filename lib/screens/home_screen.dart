import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../blocs/post/post_state.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_widget.dart'; // ✅ Import CreatePostWidget

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
              itemCount: state.posts.length + 1, // ✅ Extra item for create post
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CreatePostWidget(); // ✅ Show create post widget at the top
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
