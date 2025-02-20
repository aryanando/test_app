import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repository/auth_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/artist/artist_bloc.dart';
import 'blocs/post/post_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/bottom_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AuthRepository authRepository = AuthRepository();
  final token = await authRepository.getToken();

  runApp(
      MyApp(initialScreen: token != null ? BottomNavScreen() : LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(AuthRepository())),
        BlocProvider(create: (context) => ProfileBloc(AuthRepository())),
        BlocProvider(create: (context) => ArtistBloc(AuthRepository())),
        BlocProvider(create: (context) => PostBloc(AuthRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: initialScreen,
      ),
    );
  }
}
