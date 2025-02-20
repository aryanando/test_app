abstract class ArtistsState {}

class ArtistsInitial extends ArtistsState {}

class ArtistsLoading extends ArtistsState {}

class ArtistsLoaded extends ArtistsState {
  final List<Map<String, dynamic>> artists;
  ArtistsLoaded(this.artists);
}

class ArtistsError extends ArtistsState {
  final String message;
  ArtistsError(this.message);
}
