import 'package:equatable/equatable.dart';

abstract class ArtistsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// ✅ Initial State
class ArtistInitial extends ArtistsState {}

/// ✅ Loading State
class ArtistLoading extends ArtistsState {}

/// ✅ Loaded State
class ArtistLoaded extends ArtistsState {
  final List<Map<String, dynamic>> artists;
  ArtistLoaded(this.artists);

  @override
  List<Object?> get props => [artists];
}

/// ✅ Error State
class ArtistError extends ArtistsState {
  final String message;
  ArtistError(this.message);

  @override
  List<Object?> get props => [message];
}
