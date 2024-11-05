import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                                                IconButton(
                                                  icon: Icon(Icons.share, size: 18),
                                                  onPressed: () {
                                                    final message =
                                                        "Hola, el juego '${deal.title}' está en oferta!!! está ${double.parse(deal.savings).round()}% menos en ${storeName}";
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