abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final String password;
  final String phone;

  UpdateProfileEvent(this.name, this.email, this.password, this.phone);
}
