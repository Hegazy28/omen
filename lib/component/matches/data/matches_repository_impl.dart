import 'package:omen/component/matches/data/matches_model.dart';
import 'package:omen/component/matches/data/matches_remote_data_source.dart';
import 'package:omen/component/matches/data/matches_repository%20.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;

  MatchesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MatchesModel>> getMatches() async {
    final result = await remoteDataSource.getMatches();
    return result.expand((list) => list).toList();
  }
}
