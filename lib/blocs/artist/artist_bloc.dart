import 'package:flutter_bloc/flutter_bloc.dart';
import 'artist_event.dart';
import 'artist_state.dart';
import '../../repository/auth_repository.dart';

class ArtistBloc extends Bloc<ArtistsEvent, ArtistsState> {
  final AuthRepository authRepository;
  List<Map<String, dynamic>> _allArtists = [];

  ArtistBloc(this.authRepository) : super(ArtistInitial()) {
    on<LoadArtistsEvent>(_onLoadArtists);
    on<CreateArtistEvent>(_onCreateArtist);
    on<UpdateArtistEvent>(_onUpdateArtist);
    on<DeleteArtistEvent>(_onDeleteArtist);
  }

  /// ✅ Load Artists
  Future<void> _onLoadArtists(
      LoadArtistsEvent event, Emitter<ArtistsState> emit) async {
    emit(ArtistLoading());

    final response = await authRepository.getArtists();

    _allArtists = List<Map<String, dynamic>>.from(response);
    emit(ArtistLoaded(List.from(_allArtists)));
  }

  /// ✅ Create Artist
  Future<void> _onCreateArtist(
      CreateArtistEvent event, Emitter<ArtistsState> emit) async {
    final response =
        await authRepository.createArtist(name: event.name, phone: event.phone);

    if (response != null) {
      _allArtists.insert(0, response); // ✅ Insert new artist at top
      emit(ArtistLoaded(List.from(_allArtists))); // ✅ Refresh UI
    } else {
      emit(ArtistError("Failed to create artist"));
    }
  }

  /// ✅ Update Artist
  Future<void> _onUpdateArtist(
      UpdateArtistEvent event, Emitter<ArtistsState> emit) async {
    final response = await authRepository.updateArtist(
        artistId: event.artistId, name: event.name, phone: event.phone);

    if (response != null) {
      _allArtists = _allArtists.map((artist) {
        if (artist['id'] == event.artistId) {
          return {
            "id": event.artistId,
            "name": event.name,
            "phone": event.phone,
            "updated_at": response["updated_at"],
          };
        }
        return artist;
      }).toList();

      emit(ArtistLoaded(List.from(_allArtists)));
    } else {
      emit(ArtistError("Failed to update artist"));
    }
  }

  /// ✅ Delete Artist
  Future<void> _onDeleteArtist(
      DeleteArtistEvent event, Emitter<ArtistsState> emit) async {
    final bool isDeleted = await authRepository.deleteArtist(event.artistId);

    if (isDeleted) {
      _allArtists.removeWhere((artist) => artist['id'] == event.artistId);
      emit(ArtistLoaded(List.from(_allArtists))); // ✅ Refresh UI
    } else {
      emit(ArtistError("Failed to delete artist"));
    }
  }
}
