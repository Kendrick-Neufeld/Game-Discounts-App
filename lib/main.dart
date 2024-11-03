import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'GameDeal.dart';
import 'Store.dart';

Future<List<GameDeal>> fetchGameDeals({int pageNumber = 0, String title = ''}) async {
  final response = await http.get(
    Uri.parse('https://www.cheapshark.com/api/1.0/deals?pageNumber=$pageNumber&title=$title'),
  );
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((deal) => GameDeal.fromJson(deal)).toList();
  } else {
    throw Exception('Failed to load game deals');
  }
}

Future<List<Store>> fetchStores() async {
  final response = await http.get(Uri.parse('https://www.cheapshark.com/api/1.0/stores'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Store.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load stores');
  }
}

List<Store> storeList = [];

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
    return FutureBuilder<List<Store>>(
      future: fetchStores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          storeList = snapshot.data!;

          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                leading: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image.asset('lib/assets/logo.png'),
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
        } else {
          return Scaffold(
            body: Center(child: Text('No stores found')),
          );
        }
      },
    );
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
      pageNumber = 0;  // Reinicia a la primera página al hacer una búsqueda
      fetchDeals();
    });
  }

  void resetSearch() {
    setState(() {
      searchQuery = '';
      pageNumber = 0;  // Reinicia a la primera página
      fetchDeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Column(
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