import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../services/DatabaseHelper.dart';
import '../services/preference_service.dart';
import '../services/wishlist_service.dart';
import '/GameDeal.dart';
import '/Store.dart';
import '/main.dart';
import 'package:url_launcher/url_launcher.dart';

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

class DiscountsTab extends StatefulWidget {
  @override
  _DiscountsTabState createState() => _DiscountsTabState();
}

class _DiscountsTabState extends State<DiscountsTab> {
  Future<List<GameDeal>>? futureGameDeals;
  int pageNumber = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchDeals();
  }

  void fetchDeals() {
    setState(() {
      futureGameDeals = fetchGameDeals(pageNumber: pageNumber, title: searchQuery);
    });
  }

  void nextPage() {
    setState(() {
      pageNumber++;
      fetchDeals();
    });
  }

  void showGameDetailsDialog(BuildContext context, String gameID) async {
    final game = await fetchGameDetails(gameID);
    if (game != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  '\$${game.deals.first.price}',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(game.thumb, height: 100),
                  SizedBox(height: 10),
                  Text(
                    'Cheapest Price Ever: \$${game.cheapestPriceEver} on ${DateFormat.yMMMd().format(game.cheapestPriceDate)}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text('All deals:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            // Usamos un Row para distribuir los elementos
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre los elementos
                              children: [
                                getStoreIcon(deal.storeID),
                                SizedBox(width: 10),
                                // Texto con precio que es el enlace
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      final url = 'https://www.cheapshark.com/redirect?dealID=${deal.dealID}';
                                      _launchURLs(url);
                                    },
                                    child: Text(
                                      '\$${deal.price} (${double.parse(deal.savings).round()}% off)', // Texto del precio como enlace
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue, // Color azul para indicar enlace
                                        decoration: TextDecoration.underline, // Subrayado para el enlace
                                      ),
                                      overflow: TextOverflow.ellipsis, // Evita que se corte el texto
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
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Agregar el juego a la wishlist
                  WishlistService.addGameToWishlist(int.parse(gameID), context);
                  Navigator.of(context).pop();
                },
                child: Text('Agregar a Wishlist'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } else {
      // Alerta en caso de error al cargar datos
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo cargar la información del juego.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

// Método para abrir URLs en el navegador predeterminado
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se puede abrir el enlace $url';
    }
  }

  void previousPage() {
    if (pageNumber > 0) {
      setState(() {
        pageNumber--;
        fetchDeals();
      });
    }
  }

  void searchDeals(String query) {
    setState(() {
      searchQuery = query;
      pageNumber = 0;
      fetchDeals();
    });
  }

  void resetSearch() {
    setState(() {
      searchQuery = '';
      pageNumber = 0;
      fetchDeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'lib/assets/discounts_background.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a game...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      onSubmitted: (query) {
                        searchDeals(query);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searchDeals(searchController.text);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: resetSearch,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<GameDeal>>(
                future: futureGameDeals,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No deals found'));
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                                  child: DataTable(
                                    horizontalMargin: 10,
                                    columnSpacing: 10,
                                    columns: const [
                                      DataColumn(label: Text('Store', style: TextStyle(fontSize: 15))),
                                      DataColumn(label: Text('Savings', style: TextStyle(fontSize: 15))),
                                      DataColumn(label: Text('Price', style: TextStyle(fontSize: 15))),
                                      DataColumn(label: Text('Title', style: TextStyle(fontSize: 15))),
                                    ],
                                    rows: snapshot.data!.map((deal) {
                                      final storeName = storeList.firstWhere(
                                            (store) => store.storeID == deal.storeID,
                                        orElse: () => Store(storeID: '', storeName: 'Unknown', iconUrl: '', logoUrl: ''),
                                      ).storeName;

                                      return DataRow(cells: [
                                        DataCell(
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            child: getStoreIcon(deal.storeID),
                                          ),
                                        ),
                                        DataCell(
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            child: Text('${double.parse(deal.savings).round()}%', style: TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                        DataCell(
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '\$${deal.normalPrice}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  '\$${deal.salePrice}',
                                                  style: TextStyle(fontSize: 12, color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            child: GestureDetector(
                                              onTap: () {
                                                showGameDetailsDialog(context, deal.gameID);
                                              },
                                              child: Row(
                                                children: [
                                                  deal.thumb != null
                                                      ? Image.network(
                                                    deal.thumb!,
                                                    width: 60,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  )
                                                      : SizedBox(
                                                    width: 60,
                                                    height: 40,
                                                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      deal.title,
                                                      style: TextStyle(fontSize: 12),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.share, size: 18),
                                                    onPressed: () {
                                                      final message =
                                                          "Hola, el juego '${deal.title}' está en oferta!!! está ${double.parse(deal.savings).round()}% menos en $storeName";
                                                      Clipboard.setData(ClipboardData(text: message));
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Mensaje copiado al portapapeles")),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: Icon(Icons.arrow_back),
                              label: Text('Back'),
                              onPressed: previousPage,
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.arrow_forward),
                              label: Text('Next'),
                              onPressed: nextPage,
                            ),
                          ],
                        ),
                      ],
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
}
