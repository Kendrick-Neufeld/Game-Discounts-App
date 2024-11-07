import 'dart:convert';
import 'package:http/http.dart' as http;

class GameDeal {
  final String gameID;         // Agrega gameID aquí
  final String title;
  final String storeID;
  final String salePrice;
  final String normalPrice;
  final String savings;
  final String? steamRatingText; // Campo opcional
  final String? thumb;           // Campo opcional
  final String? cheapestPriceEver;
  final String? cheapestPriceDate;

  GameDeal({
    required this.gameID,       // Asegúrate de que gameID es obligatorio
    required this.title,
    required this.storeID,
    required this.salePrice,
    required this.normalPrice,
    required this.savings,
    this.steamRatingText,       // Campo opcional
    this.thumb,                 // Campo opcional
    this.cheapestPriceEver,
    this.cheapestPriceDate,
  });

  factory GameDeal.fromJson(Map<String, dynamic> json) {
    return GameDeal(
      gameID: json['gameID'],             // Asigna el gameID desde el JSON
      title: json['title'] ?? 'Unknown Title',
      storeID: json['storeID'] ?? 'Unknown Store',
      salePrice: json['salePrice'] ?? '0.00',
      normalPrice: json['normalPrice'] ?? '0.00',
      savings: json['savings'] ?? '0.00',
      steamRatingText: json['steamRatingText'], // Campo opcional
      thumb: json['thumb'],                      // Campo opcional
      cheapestPriceEver: json['cheapestPriceEver'],
      cheapestPriceDate: json['cheapestPriceDate'],
    );
  }

  // Metodo para obtener el "cheapest price ever" y la fecha
  static Future<Map<String, String>?> fetchCheapestPrice(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.cheapshark.com/api/1.0/games?id=$gameId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cheapestPrice = data['cheapestPriceEver']['price']?.toString() ?? 'N/A';

        // Convierte el timestamp a una fecha legible
        final timestamp = data['cheapestPriceEver']['date'];
        String date = 'N/A';
        if (timestamp != null) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          date = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
        }

        return {
          'cheapestPriceEver': cheapestPrice,
          'cheapestPriceDate': date,
        };
      } else {
        print('Failed to load cheapest price');
        return null;
      }
    } catch (e) {
      print('Error fetching cheapest price: $e');
      return null;
    }
  }
}
