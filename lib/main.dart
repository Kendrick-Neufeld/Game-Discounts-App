import 'package:flutter/material.dart';
import 'package:game_discounts_app/views/login_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'Game.dart';
import 'GameDeal.dart';
import 'Store.dart';
import 'controllers/choose_picture_controller.dart';
import 'views/discounts_tab.dart';
import 'views/storefonts_tab.dart';
import 'views/wishlist_tab.dart';
import 'package:flutter/services.dart';
import '/services/DatabaseHelper.dart';
import 'models/user.dart';

Future<Game?> fetchGameDetails(String gameID) async {
  final url = 'https://www.cheapshark.com/api/1.0/games?id=$gameID';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Game.fromJson(jsonResponse);
  } else {
    print('Failed to load game details');
    return null;
  }
}

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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImagePickerController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? loggedUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discounts App',
      theme: ThemeData.dark(),
      home: loggedUser == null ? LoginView(onLoginSuccess: _onLoginSuccess) : HomeScreen(user: loggedUser!),
    );
  }

  // Actualiza el usuario autenticado al iniciar sesión exitosamente
  void _onLoginSuccess(User user) {
    setState(() {
      loggedUser = user;
    });
  }
}

class HomeScreen extends StatelessWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: fetchStores(),
      builder: (context, snapshot) {
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
                  icon: user.profilePicture != null
                      ? CircleAvatar(backgroundImage: MemoryImage(user.profilePicture!))
                      : Icon(Icons.person),
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
      },
    );
  }
}
