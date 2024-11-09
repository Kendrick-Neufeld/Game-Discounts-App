import 'package:flutter/material.dart';
import '../GameDeal.dart';
import '../services/DatabaseHelper.dart';

class WishlistTab extends StatefulWidget {
  @override
  _WishlistTabState createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {
  List<GameDeal> wishlist = [];
  int? get userId => 1; // Asegúrate de establecer el ID del usuario actual aquí

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  // Cargar los juegos de la wishlist desde la base de datos
  Future<void> _loadWishlist() async {
    if (userId != null) {
      final wishlistItems = await DatabaseHelper().getWishlist(userId!);
      setState(() {
        wishlist = wishlistItems.map((item) => GameDeal.fromJson(item)).toList(); // Convierte a GameDeal
      });
    }
  }

  // Agregar un juego a la wishlist
  Future<void> _addGameToWishlist(GameDeal gameDeal) async {
    if (userId != null) {
      await DatabaseHelper().addGameToWishlist(gameDeal.gameID as int, userId!);
      _loadWishlist(); // Actualizar la lista de la wishlist
      _showConfirmationDialog('Added', 'Game has been added to your wishlist.');
    }
  }

  // Eliminar un juego de la wishlist
  Future<void> _removeGameFromWishlist(int gameId) async {
    if (userId != null) {
      await DatabaseHelper().removeGameFromWishlist(gameId, userId!);
      _loadWishlist(); // Actualizar la lista después de eliminar
      _showConfirmationDialog('Removed', 'Game has been removed from your wishlist.');
    }
  }

  // Mostrar cuadro de diálogo de confirmación
  void _showConfirmationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo con opacidad del 15%
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'lib/assets/wishlist_background.jpeg', // Ruta de la imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Contenido principal de la pestaña Wishlist
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Tres columnas
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final game = wishlist[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Imagen del juego
                        Image.network(
                          game.thumb ?? '',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        // Precio y tienda
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Price: \$${game.salePrice}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.store, size: 20),
                          ],
                        ),
                      ],
                    ),
                    // Icono de eliminación en la esquina superior derecha
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Removal'),
                                content: Text(
                                    'Are you sure you want to remove this game from your wishlist?'),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: Text('Confirm'),
                                    onPressed: () {
                                      _removeGameFromWishlist(game.gameID as int);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}