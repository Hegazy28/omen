import 'package:dio/dio.dart';
import 'package:omen/component/matches/data/ApiException.dart';
import 'package:omen/component/matches/data/matches_model.dart';

class MatchesRemoteDataSource {
  final Dio dio;

  MatchesRemoteDataSource(this.dio);

  Future<List<List<MatchesModel>>> getMatches() async {
    try {
      final response = await dio.get('/matches');

      return (response.data as List)
          .map((json) => MatchesModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException(e.message ?? "Unknown error");
    }
  }
}
