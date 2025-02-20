import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/artist/artist_bloc.dart';
import '../blocs/artist/artist_event.dart';
import '../blocs/artist/artist_state.dart';

class CreateArtistScreen extends StatefulWidget {
  const CreateArtistScreen({super.key});

  @override
  CreateArtistScreenState createState() => CreateArtistScreenState();
}

class CreateArtistScreenState extends State<CreateArtistScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void _submitArtist() {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Both fields are required!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    context.read<ArtistBloc>().add(CreateArtistEvent(
          name: nameController.text,
          phone: phoneController.text,
        ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Artist')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Artist Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            BlocConsumer<ArtistBloc, ArtistsState>(
              listener: (context, state) {
                if (state is ArtistError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              builder: (context, state) {
                if (state is ArtistLoading) {
                  return CircularProgressIndicator();
                }

                return ElevatedButton(
                  onPressed: _submitArtist,
                  child: Text('Create Artist'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
