import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final response = await authRepository.login(event.email, event.password);

    if (response.containsKey('access_token')) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['access_token']);
      emit(AuthAuthenticated(response['access_token']));
    } else {
      emit(AuthError("Invalid credentials"));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await authRepository.logout();
    await prefs.remove('token');
    emit(AuthUnauthenticated());
  }
}
