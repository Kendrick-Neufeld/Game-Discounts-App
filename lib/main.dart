import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'GameDeal.dart';
import 'Store.dart';
import 'views/discounts_tab.dart';
import 'views/storefonts_tab.dart';
import 'views/wishlist_tab.dart';

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

