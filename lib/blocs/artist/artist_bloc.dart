import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/blocs/artist/artist_event.dart';
import 'package:test_app/blocs/artist/artist_state.dart';
import '../../repository/auth_repository.dart';

class ArtistsBloc extends Bloc<ArtistsEvent, ArtistsState> {
  final AuthRepository authRepository;

  ArtistsBloc(this.authRepository) : super(ArtistsInitial()) {
    on<LoadArtistsEvent>(_onLoadArtists);
  }

  Future<void> _onLoadArtists(
      LoadArtistsEvent event, Emitter<ArtistsState> emit) async {
    emit(ArtistsLoading());

    final artists = await authRepository.getArtists();

    if (artists.isNotEmpty) {
      emit(ArtistsLoaded(artists));
    } else {
      emit(ArtistsError("Failed to fetch artists"));
    }
  }
}
