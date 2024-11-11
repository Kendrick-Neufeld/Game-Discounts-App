import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:game_discounts_app/services/preference_service.dart';
import '../Game.dart';
import 'DatabaseHelper.dart';

class WishlistService {
  // Agregar juego a la wishlist
  static Future<void> addGameToWishlist(int gameId,
      BuildContext context) async {
    final prefs = PreferencesService();
    final userId = await prefs
        .getUserId(); // Obtener el userId almacenado en SharedPreferences

    if (userId != null) {
      // Agregar el juego
      await DatabaseHelper().addGameToWishlist(gameId, userId);

      // Mostrar un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se ha agregado a tu wishlist')),
      );
    } else {
      // Mostrar error si no se encuentra un userId
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No se pudo agregar el juego.')),
      );
    }
  }


  // Obtener los juegos de la wishlist del usuario
  static Future<List<Game>> getWishlistGames(BuildContext context) async {
    final prefs = PreferencesService();
    final userId = await prefs
        .getUserId(); // Obtener el userId almacenado en SharedPreferences

    if (userId != null) {
      List<int> gameIds = await DatabaseHelper().getWishlistGameIds(userId);

      if (gameIds.isNotEmpty) {
        List<Game> games = [];
        for (int gameId in gameIds) {
          // Ahora pasamos gameId como un int
          Game game = await fetchGameDetails(gameId);
          if (game != null) {
            games.add(game);
          }
        }
        return games;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  // Fetch game details from API
  static Future<Game> fetchGameDetails(int gameId) async {
    final url = 'https://www.cheapshark.com/api/1.0/games?id=$gameId'; // API correcta

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Imprimir datos para verificar la estructura
        print('Response data for game ID $gameId: $data');

        // Verificar si la respuesta contiene datos y es un mapa con la estructura esperada
        if (data != null && data.isNotEmpty) {
          return Game.fromJson(
              data);
        } else {
          throw Exception('Game data not found');
        }
      } else {
        print(
            'Failed to load game details. Status code: ${response.statusCode}');
        throw Exception('Failed to load game details');
      }
    } catch (e) {
      print('Error fetching game details for game ID $gameId: $e');
      throw Exception('Error fetching game details');
    }
  }


  // Eliminar juego de la wishlist
  static Future<void> removeGameFromWishlist(int gameId, BuildContext context) async {
    final prefs = PreferencesService();
    final userId = await prefs.getUserId(); // Obtener el userId almacenado en SharedPreferences
    print("Intentando eliminar gameId: $gameId para userId: $userId");
    if (userId != null) {
      // Eliminar el juego de la base de datos
      await DatabaseHelper().removeGameFromWishlist(gameId, userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se ha eliminado de tu wishlist')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No se pudo eliminar el juego.')),
      );
    }
  }
}