import 'package:omen/component/matches/data/matches_model.dart';

abstract class MatchesRepository {
  Future<List<MatchesModel>> getMatches();
}
