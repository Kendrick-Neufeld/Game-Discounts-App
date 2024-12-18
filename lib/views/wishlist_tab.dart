import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Game.dart';
import '../Store.dart';
import '../main.dart';
import '../services/wishlist_service.dart';
import 'discounts_tab.dart';

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

  // Función para obtener los juegos de la wishlist
  void fetchWishlistGames() {
    setState(() {
      wishlistGames = WishlistService.getWishlistGames(context);
    });
  }

  // Mostrar cuadro de diálogo con información detallada
  void _showGameDetails(Game game) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            game.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del juego
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      game.thumb,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Información del precio más bajo con fecha
                Text(
                  'Cheapest Price Ever: \$${game.cheapestPriceEver} on ${DateFormat.yMMMd().format(game.cheapestPriceDate)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                // Ofertas disponibles
                if (game.deals.isNotEmpty) ...[
                  Text(
                    'Available Deals:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: game.deals.map((deal) {
                      return Container(
                        width: (MediaQuery.of(context).size.width / 2) - 32, // Divide en dos columnas
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre elementos
                              children: [
                                // Icono de la tienda
                                getStoreIcon(deal.storeID),
                                SizedBox(width: 10),
                                // Precio como enlace
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      final url = 'https://www.cheapshark.com/redirect?dealID=${deal.dealID}';
                                      _launchURLs(url);
                                    },
                                    child: Text(
                                      '\$${deal.price} (${double.parse(deal.savings).round()}% off)', // Precio y ahorro
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue, // Color azul para indicar enlace
                                        decoration: TextDecoration.underline, // Subrayado para el enlace
                                      ),
                                      overflow: TextOverflow.ellipsis, // Evita desbordamiento
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
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
        // Fondo del wishlist_tab
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
                        childAspectRatio: 0.42, // altura
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final game = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            _showGameDetails(game); // Mostrar detalles
                          },
                          child: WishlistItemCard(
                            game: game,
                            onRemove: () async {
                              final gameId = int.tryParse(game.steamAppID ?? '0');
                              if (gameId != null) {
                                // Elimina el juego de la lista local primero
                                setState(() {
                                  wishlistGames = wishlistGames?.then(
                                        (games) => games.where((g) => g.steamAppID != game.steamAppID).toList(),
                                  );
                                });
                                // Luego elimina de la base de datos
                                try {
                                  await WishlistService.removeGameFromWishlist(gameId, context);
                                } catch (e) {
                                  print("Error eliminando juego de la wishlist: $e");
                                }
                              } else {
                                print("Error: gameId no válido");
                              }
                            },
                          ),
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

class WishlistItemCard extends StatelessWidget {
  final Game game;
  final VoidCallback onRemove;

  const WishlistItemCard({
    required this.game,
    required this.onRemove,
  });

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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
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
                      'Cheapest Price: \$${game.deals.first.price}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8), // Espacio entre el precio y el icono
                    getStoreIcon(game.deals.first.storeID),
                  ],
                ),
              ),
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
                final gameId = game.GameID;

                if (gameId != null) {
                  await WishlistService.removeGameFromWishlist(gameId, context);
                  onRemove();  // Eliminar el juego de la lista
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
Widget getStoreIcon(String storeID) {
  final store = storeList.firstWhere(
        (store) => store.storeID == storeID,
    orElse: () => Store(storeID: '', storeName: '', iconUrl: '', logoUrl: ''),
  );

  if (store.storeID.isNotEmpty) {
    return Image.network(
      store.iconUrl,
      width: 27,
      height: 27,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.store),
    );
  } else {
    return Icon(Icons.store);
  }
}
Future<void> _launchURLs(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Asegura abrir en un navegador externo
    );
    if (!launched) throw 'No se pudo abrir el enlace';
  } catch (e) {
    print('Error al intentar abrir el enlace: $e');
  }
}