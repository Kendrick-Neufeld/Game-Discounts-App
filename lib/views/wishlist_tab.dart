import 'package:flutter/material.dart';
import '../Game.dart';
import '../GameDeal.dart';
import '../main.dart';
import '../services/DatabaseHelper.dart';
import '../services/preference_service.dart';
import '../widgets/WishlistItemCard.dart';

class WishlistTab extends StatefulWidget {
  @override
  _WishlistTabState createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {
  List<Game> wishlist = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    int? userId = await PreferencesService().getUserId();
    if (userId != null) {
      List<Map<String, dynamic>> wishlistData = await DatabaseHelper().getWishlist(userId);

      List<Game> loadedGames = [];
      for (var item in wishlistData) {
        String gameID = item['juego_id'].toString();
        final game = await fetchGameDetails(gameID);
        if (game != null) {
          loadedGames.add(game);
        }
      }

      setState(() {
        wishlist = loadedGames;
      });
    }
  }

  void _removeGameFromWishlist(String gameID) async {
    int? userId = await PreferencesService().getUserId();
    if (userId != null) {
      await DatabaseHelper().removeGameFromWishlist(int.parse(gameID), userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Juego eliminado de tu wishlist.')),
      );
      _loadWishlist(); // Recargar la wishlist después de eliminar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'lib/assets/wishlist_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: wishlist.isEmpty
              ? Center(child: Text("No hay juegos en tu wishlist."))
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final game = wishlist[index];
              return WishlistItemCard(
                game: game,
                onRemove: () => _removeGameFromWishlist(game.steamAppID!), // Define el onRemove aquí
              );
            },
          ),
        ),
      ],
    );
  }
}