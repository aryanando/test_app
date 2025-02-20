abstract class ArtistsEvent {}

/// ✅ Create Artist Event
class CreateArtistEvent extends ArtistsEvent {
  final String name;
  final String phone;

  CreateArtistEvent({required this.name, required this.phone});

  List<Object?> get props => [name, phone];
}

class LoadArtistsEvent extends ArtistsEvent {}

/// ✅ Update Artist Event
class UpdateArtistEvent extends ArtistsEvent {
  final int artistId;
  final String name;
  final String phone;

  UpdateArtistEvent(
      {required this.artistId, required this.name, required this.phone});

  List<Object?> get props => [artistId, name, phone];
}

class DeleteArtistEvent extends ArtistsEvent {
  final int artistId;
  DeleteArtistEvent(this.artistId);

  List<Object?> get props => [artistId];
}
