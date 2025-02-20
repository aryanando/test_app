import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final String baseUrl = "https://api-nando.batubhayangkara.com/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      return data;
    } else {
      return {'error': 'Login failed'};
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, dynamic>> updateProfile(
      String name, String email, String password, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return {'error': 'Unauthorized'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/update-profile'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password.isNotEmpty
            ? password
            : null, // Only send password if provided
        'phone': phone.isNotEmpty ? phone : null, // Only send phone if provided
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': 'Update failed'};
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getArtists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/artist'), // Update with actual API URL
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPosts(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/posts?page=$page'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // ✅ Return entire pagination response
    } else {
      return null;
    }
  }

  Future<int?> likePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Ensure we extract only the like_count field
      if (data is Map<String, dynamic> && data.containsKey('like_count')) {
        return data['like_count'] as int;
      }
    }

    return null; // ✅ Return null if anything fails
  }

  Future<Map<String, dynamic>?> createPost({
    String? content,
    File? image,
    File? video,
    String? youtubeLink,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return null;

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));

    request.headers['Authorization'] = 'Bearer $token';

    if (content != null) request.fields['content'] = content;
    if (youtubeLink != null) request.fields['youtube_link'] = youtubeLink;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    if (video != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'video',
        video.path,
        contentType: MediaType('video', 'mp4'),
      ));
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseData);
    } else {
      return null;
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/posts/$postId"));

      if (response.statusCode == 200) {
        return true; // ✅ Successfully deleted
      }
      return false;
    } catch (e) {
      print("Error deleting post: $e");
      return false;
    }
  }
}
