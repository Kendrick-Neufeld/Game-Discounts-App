import 'package:intl/intl.dart';

class Game {
  final String title;
  final String? steamAppID;
  final String thumb;
  final String cheapestPriceEver;
  final DateTime cheapestPriceDate;
  final List<GameDealDetail> deals;

  Game({
    required this.title,
    this.steamAppID,
    required this.thumb,
    required this.cheapestPriceEver,
    required this.cheapestPriceDate,
    required this.deals,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      title: json['info']['title'],
      steamAppID: json['info']['steamAppID'],
      thumb: json['info']['thumb'],
      cheapestPriceEver: json['cheapestPriceEver']['price'],
      cheapestPriceDate: DateTime.fromMillisecondsSinceEpoch(json['cheapestPriceEver']['date'] * 1000),
      deals: (json['deals'] as List).map((deal) => GameDealDetail.fromJson(deal)).toList(),
    );
  }
}

class GameDealDetail {
  final String storeID;
  final String dealID;
  final String price;
  final String retailPrice;
  final String savings;

  GameDealDetail({
    required this.storeID,
    required this.dealID,
    required this.price,
    required this.retailPrice,
    required this.savings,
  });

  factory GameDealDetail.fromJson(Map<String, dynamic> json) {
    return GameDealDetail(
      storeID: json['storeID'],
      dealID: json['dealID'],
      price: json['price'],
      retailPrice: json['retailPrice'],
      savings: json['savings'],
    );
  }
}
