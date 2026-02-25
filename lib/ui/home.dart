import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:omen/component/myButton.dart';
import 'package:omen/core/myAssets.dart';
import 'package:omen/core/myColors.dart';
import 'package:omen/core/myFonts.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(Myassets.AppLogo, height: 26, width: 50),
                SizedBox(width: 12),
                Text("ForstFlow", style: Myfonts.labelLarge),
                Spacer(),
                Text("Dashboard", style: Myfonts.labelSmall),
                SizedBox(width: 12),
                Text("Analytics", style: Myfonts.labelSmall),
                SizedBox(width: 12),
                Text("Settings", style: Myfonts.labelSmall),
                Spacer(),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Mycolors.aurora1,
                  child: Text("JD", style: Myfonts.labelMedium),
                ),
              ],
            ),
          ),
          Divider(
            color: Mycolors.textMuted,
            thickness: 1,
            height: 32,
            endIndent: 36,
            indent: 36,
          ),
          Row(
            children: [
              Container(
                height: 560,
                margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: Mycolors.skyGradient,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(Myassets.AppLogo, height: 36, width: 36),
                        SizedBox(
                          width: 12,
                        ),
                        Text("Ayman", style: Myfonts.headlineMedium),
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Mybutton(
                      onPressed: () {},
                      text: "Home",
                      imageString: Myassets.Home,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Mybutton(
                      onPressed: () {},
                      text: "Tasks",
                      imageString: Myassets.AppTasks,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Mybutton(
                      onPressed: () {},
                      text: "Calender",
                      imageString: Myassets.AppCalender,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Mybutton(
                      onPressed: () {
                        getTodaysMatches().then((matches) {
                          print(matches);
                        });
                      },
                      text: "Profile",
                      imageString: Myassets.AppProfile,
                    ),
                    Text("data")
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<List> getTodaysMatches() async {
    try {
      final today =
          DateTime.now().toIso8601String().split('T')[0]; // "2025-02-25"

      final response = await http.get(
        Uri.parse(
            'https://api-football-v1.p.rapidapi.com/v3/fixtures?date=$today'),
        headers: {
          'X-RapidAPI-Key':
              '75546d1733msh278fb5578f3e2b7p1e7022jsn07eb1e89ca7b',
          'X-RapidAPI-Host': 'api-football-v1.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching today\'s matches: $e');
      return [];
    }
  }
}
