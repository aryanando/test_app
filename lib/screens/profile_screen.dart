import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/blocs/auth/auth_bloc.dart';
import 'package:test_app/blocs/auth/auth_event.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  /// ✅ Dispatch Logout Event to `AuthBloc`
  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon:
                Icon(Icons.logout, color: Colors.redAccent), // 🔴 Logout Button
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  /// ✅ Profile Avatar with Default Icon Handling
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: state.user['profile_image'] != null &&
                              state.user['profile_image'].isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                state.user['profile_image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person,
                                      size: 50,
                                      color: Colors.grey[
                                          700]); // ✅ Fallback to default icon
                                },
                              ),
                            )
                          : Icon(Icons.person,
                              size: 50,
                              color: Colors.grey[
                                  700]), // ✅ Default icon if no profile image
                    ),
                  ),
                  SizedBox(height: 15),

                  /// ✅ User Info Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              Icons.person, "Name", state.user['name']),
                          Divider(),
                          _buildInfoRow(
                              Icons.email, "Email", state.user['email']),
                          Divider(),
                          _buildInfoRow(Icons.phone, "Phone",
                              state.user['phone'] ?? "Not Provided"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  /// ✅ Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text("Edit Profile",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateProfileScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProfileError) {
            return Center(
                child:
                    Text(state.message, style: TextStyle(color: Colors.red)));
          }

          return Center(
              child: Text("No profile data available",
                  style: TextStyle(fontSize: 16)));
        },
      ),
    );
  }

  /// ✅ Reusable Info Row Widget
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text("$label: $value", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
