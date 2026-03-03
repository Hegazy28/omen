import 'package:dio/dio.dart';
import 'package:omen/component/matches/data/app_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl:
                "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=${DateTime.now().toIso8601String().split('T')[0]}",
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(AppInterceptor());
  }
}


// Future<List> getTodaysMatches() async {
  //   try {
  //     final today =
  //         DateTime.now().toIso8601String().split('T')[0]; // "2025-02-25"

  //     final response = await http.get(
  //       Uri.parse(
  //           'https://api-football-v1.p.rapidapi.com/v3/fixtures?date=$today'),
  //       headers: {
  //         'X-RapidAPI-Key':
  //             '75546d1733msh278fb5578f3e2b7p1e7022jsn07eb1e89ca7b',
  //         'X-RapidAPI-Host': 'api-football-v1.p.rapidapi.com',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['response'] ?? [];
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching today\'s matches: $e');
  //     return [];
  //   }
  // }