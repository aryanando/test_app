import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/artist/artist_bloc.dart';
import '../blocs/artist/artist_event.dart';

class UpdateArtistScreen extends StatefulWidget {
  final int artistId;
  final String name;
  final String phone;

  const UpdateArtistScreen(
      {super.key,
      required this.artistId,
      required this.name,
      required this.phone});

  @override
  UpdateArtistScreenState createState() => UpdateArtistScreenState();
}

class UpdateArtistScreenState extends State<UpdateArtistScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
  }

  void _updateArtist() {
    context.read<ArtistBloc>().add(UpdateArtistEvent(
          artistId: widget.artistId,
          name: nameController.text,
          phone: phoneController.text,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Artist')),
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
            ElevatedButton(
              onPressed: _updateArtist,
              child: Text('Update Artist'),
            ),
          ],
        ),
      ),
    );
  }
}
