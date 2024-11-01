import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'GameDeal.dart';

Future<List<GameDeal>> fetchGameDeals() async {
  final response = await http.get(
    Uri.parse('https://www.cheapshark.com/api/1.0/deals'),
  );
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((deal) => GameDeal.fromJson(deal)).toList();
  } else {
    throw Exception('Failed to load game deals');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discounts App',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png'),
          ),
          title: Text('Discounts'),
          actions: [
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Acción para acceder al perfil
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Discounts'),
              Tab(text: 'Storefronts'),
              Tab(text: 'Wishlist'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DiscountsTab(),
            StorefrontsTab(),
            WishlistTab(),
          ],
        ),
      ),
    );
  }
}
class DiscountsTab extends StatelessWidget {
  Future<List<GameDeal>> futureGameDeals = fetchGameDeals();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameDeal>>(
      future: futureGameDeals,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No deals found'));
        } else {
          return LayoutBuilder(
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
                              ],
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }




  // Función para obtener el ícono de la tienda según el storeID
  Widget getStoreIcon(String storeID) {
    return Icon(Icons.store);
    /*switch (storeID) {
      case '1':
        return Image.asset('assets/steam_icon.png', width: 40);
      case '2':
        return Image.asset('assets/gog_icon.png', width: 40);
      case '3':
        return Image.asset('assets/epic_icon.png', width: 40);
      default:
        return Icon(Icons.store);
    }*/
  }
}

class StorefrontsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Storefronts'),
    );
  }
}

class WishlistTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Wishlist'),
    );
  }
}
