import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/blocs/artist/artist_state.dart';
import '../blocs/artist/artist_bloc.dart';
import '../blocs/artist/artist_event.dart';

class ArtistsScreen extends StatefulWidget {
  @override
  _ArtistsScreenState createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ArtistsBloc>().add(LoadArtistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Ensure Scaffold is present
      appBar: AppBar(title: Text('Artists')),
      body: BlocBuilder<ArtistsBloc, ArtistsState>(
        builder: (context, state) {
          if (state is ArtistsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ArtistsLoaded) {
            return ListView.builder(
              itemCount: state.artists.length,
              itemBuilder: (context, index) {
                final artist = state.artists[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(artist['name'][0]),
                  ),
                  title: Text(artist['name']),
                  subtitle: Text("Phone: ${artist['phone']}"),
                );
              },
            );
          } else if (state is ArtistsError) {
            return Center(child: Text(state.message));
          }

          return Center(child: Text("No artists available"));
        },
      ),
    );
  }
}
