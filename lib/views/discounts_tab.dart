import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  void showGameDetailsDialog(GameDeal deal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 400, // Ancho del cuadro de diálogo
            padding: EdgeInsets.all(16),
            child: FutureBuilder<Map<String, String>?>(
              future: GameDeal.fetchCheapestPrice(deal.storeID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No data available'));
                } else {
                  final cheapestPrice = snapshot.data!['cheapestPriceEver'] ?? 'N/A';
                  final cheapestDate = snapshot.data!['cheapestPriceDate'] ?? 'N/A';

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Tooltip(
                              message: deal.title,
                              child: Text(
                                deal.title,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Text(
                                '\$${deal.salePrice}',
                                style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              getStoreIcon(deal.storeID),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 20),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Precios:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '\$${deal.salePrice} (Venta)',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '\$${deal.normalPrice} (Normal)',
                                  style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                deal.thumb != null
                                    ? Image.network(
                                  deal.thumb!,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                    : Icon(Icons.image_not_supported, size: 100),
                                SizedBox(height: 8),
                                Text(
                                  'Cheapest Price Ever:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                Text('\$$cheapestPrice', style: TextStyle(fontSize: 12)),
                                Text('Date: $cheapestDate', style: TextStyle(fontSize: 12)),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Add to Wishlist', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
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

    return Column(
      children: [
        // Campo de búsqueda
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
                                  return DataRow(
                                    cells: [
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
                                              showGameDetailsDialog(deal);
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
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