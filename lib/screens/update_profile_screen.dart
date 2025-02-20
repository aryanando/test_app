import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Profile updated successfully!")),
            );

            // ✅ Navigate back to Profile Screen after update
            Future.delayed(Duration(seconds: 1), () {
              Navigator.pop(context);
            });
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            nameController.text = state.user['name'];
            emailController.text = state.user['email'];
            phoneController.text = state.user['phone'] ?? '';

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name')),
                  TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email')),
                  TextField(
                      controller: phoneController,
                      decoration:
                          InputDecoration(labelText: 'Phone (Optional)')),
                  TextField(
                      controller: passwordController,
                      decoration:
                          InputDecoration(labelText: 'New Password (Optional)'),
                      obscureText: true),
                  SizedBox(height: 20),
                  state is ProfileLoading
                      ? CircularProgressIndicator() // Show loading when updating
                      : ElevatedButton(
                          onPressed: () {
                            context.read<ProfileBloc>().add(UpdateProfileEvent(
                                nameController.text,
                                emailController.text,
                                passwordController.text,
                                phoneController.text));
                          },
                          child: Text('Update Profile'),
                        ),
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
