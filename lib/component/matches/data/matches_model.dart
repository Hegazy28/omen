class MatchesModel {
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final String location;
  final String matchType;
  final String teamA;
  final String teamB;
  final String score;
  final String status;
  final String referee;
  final String stadium;
  final String league;
  final String season;

  final String time;

  MatchesModel(
      {required this.title,
      required this.description,
      required this.imageUrl,
      required this.date,
      required this.location,
      required this.matchType,
      required this.teamA,
      required this.teamB,
      required this.score,
      required this.status,
      required this.referee,
      required this.stadium,
      required this.league,
      required this.season,
      required this.time});

    static List<MatchesModel> fromJson(json) {
      
        return [
          MatchesModel(
            title: json['title'] ?? '',
            description: json['description'] ?? '',
            imageUrl: json['imageUrl'] ?? '',
            date: json['date'] ?? '',
            location: json['location'] ?? '',
            matchType: json['matchType'] ?? '',
            teamA: json['teamA'] ?? '',
            teamB: json['teamB'] ?? '',
            score: json['score'] ?? '',
            status: json['status'] ?? '',
            referee: json['referee'] ?? '',
            stadium: json['stadium'] ?? '',
            league: json['league'] ?? '',
            season: json['season'] ?? '',
            time: json['time'] ?? '',
          )
        ];
    }
  }

