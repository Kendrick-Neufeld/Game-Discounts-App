import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/DatabaseHelper.dart';
import '../services/preference_service.dart';
import '/GameDeal.dart';
import '/Store.dart';
import '/main.dart';

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
                        child: Row(
                          children: [
                            getStoreIcon(deal.storeID),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '\$${deal.price} (${double.parse(deal.savings).round()}% off)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
                onPressed: () async {
                  try {
                    // Asegúrate de que `game.id` es el ID del juego y `userId` es el ID del usuario actual.
                    int gameId = game.steamAppID != null ? int.parse(game.steamAppID!) : 0;
                    int? userId = await PreferencesService().getUserId();

                    print('User ID: $userId');
                    print('Game ID: $gameId');

                    // Agrega el juego a la wishlist para el usuario actual en la base de datos
                    await DatabaseHelper().addGameToWishlist(gameId, userId!);

                    // Muestra un mensaje de confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Se ha agregado correctamente a tu wishlist.'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Cierra el diálogo
                    Navigator.of(context).pop();
                  } catch (error) {
                    // Muestra un mensaje de error si ocurre algún problema al agregar
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('No se pudo agregar a la wishlist.'),
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
                                        orElse: () => Store(storeID: '', storeName: 'Unknown', iconUrl: ''),
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
      orElse: () => Store(storeID: '', storeName: '', iconUrl: ''),
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