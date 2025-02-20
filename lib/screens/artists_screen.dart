import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/blocs/artist/artist_state.dart';
import 'package:test_app/screens/update_artist_screen.dart';
import '../blocs/artist/artist_bloc.dart';
import '../blocs/artist/artist_event.dart';
import 'create_artist_screen.dart'; // ✅ Import Create Artist Screen

class ArtistsScreen extends StatefulWidget {
  @override
  _ArtistsScreenState createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ArtistBloc>().add(LoadArtistsEvent());
  }

  /// ✅ Navigate to CreateArtistScreen
  void _navigateToCreateArtist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateArtistScreen()),
    ).then((_) {
      context.read<ArtistBloc>().add(LoadArtistsEvent()); // ✅ Reload artists
    });
  }

  /// ✅ Confirm Delete Artist
  void _confirmDeleteArtist(int artistId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Artist"),
        content: Text("Are you sure you want to delete this artist?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<ArtistBloc>().add(DeleteArtistEvent(artistId));
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artists'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 28), // ✅ Plus Button
            onPressed: _navigateToCreateArtist, // ✅ Open CreateArtistScreen
          ),
        ],
      ),
      body: BlocBuilder<ArtistBloc, ArtistsState>(
        builder: (context, state) {
          if (state is ArtistLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ArtistLoaded) {
            return ListView.builder(
              itemCount: state.artists.length,
              itemBuilder: (context, index) {
                final artist = state.artists[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(artist['name'][0]), // ✅ First Letter of Name
                  ),
                  title: Text(artist['name']),
                  subtitle: Text("Phone: ${artist['phone']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateArtistScreen(
                                artistId: artist['id'],
                                name: artist['name'],
                                phone: artist['phone'],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteArtist(artist['id']),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is ArtistError) {
            return Center(child: Text(state.message));
          }

          return Center(child: Text("No artists available"));
        },
      ),
    );
  }
}
