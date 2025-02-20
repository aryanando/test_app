import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../repository/auth_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;

  ProfileBloc(this.authRepository) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final profileData = await authRepository.getProfile();

    if (profileData != null) {
      emit(ProfileLoaded(profileData));
    } else {
      emit(ProfileError("Failed to fetch profile"));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final response = await authRepository.updateProfile(
      event.name,
      event.email,
      event.password,
      event.phone,
    );

    if (response.containsKey('user')) {
      emit(ProfileUpdated(response['user']));
      emit(ProfileLoaded(response['user'])); // ✅ Ensure UI updates correctly
    } else {
      emit(ProfileError("Profile update failed"));
    }
  }
}
