import 'package:flutter/material.dart';
import '../Game.dart';
import '../services/wishlist_service.dart';

class WishlistTab extends StatefulWidget {
  @override
  _WishlistTabState createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {
  Future<List<Game>>? wishlistGames;

  @override
  void initState() {
    super.initState();
    fetchWishlistGames();
  }

  void fetchWishlistGames() {
    setState(() {
      wishlistGames = WishlistService.getWishlistGames(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo del wishlist_tab (se mantiene como el fondo actual)
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'lib/assets/wishlist_background.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Game>>(
                future: wishlistGames,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No tienes juegos en tu wishlist.'));
                  } else {
                    // Mostrar los juegos en formato de tarjetas con 3 columnas
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Tres columnas
                        crossAxisSpacing: 12, // Espaciado horizontal entre tarjetas
                        mainAxisSpacing: 10, // Espaciado vertical entre filas
                        childAspectRatio: 0.40, // altura
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final game = snapshot.data![index];
                        return GameCard(
                          game: game,
                          onGameRemoved: () {
                            setState(() {
                              snapshot.data!.removeAt(index);  // Elimina el juego de la lista
                            });
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onGameRemoved;

  GameCard({required this.game, required this.onGameRemoved});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => _showConfirmationDialog(context),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              game.thumb,
              height: 120,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Cheapest Price: \$${game.cheapestPriceEver}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('¿Estás seguro de que deseas eliminar este juego de tu wishlist?'),
          actions: [
            TextButton(
              onPressed: () async {
                final gameId = int.tryParse(game.steamAppID ?? '0'); // Reemplaza si es necesario

                if (gameId != null) {
                  await WishlistService.removeGameFromWishlist(gameId, context);
                  onGameRemoved();
                } else {
                  print("Error: gameId no válido");
                }
                Navigator.of(context).pop();
              },
              child: Text('Sí, Eliminar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}