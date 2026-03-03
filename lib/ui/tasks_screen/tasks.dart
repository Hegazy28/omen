import 'package:flutter/material.dart';
import 'package:omen/component/tasks/tasks_widget.dart';

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 28,
              ),
              SizedBox(
                  height: 450, width: double.infinity, child: TasksWidget()),
            ],
          ),
        ),
      ),
    );
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
}
