class Store {
  final String storeID;
  final String storeName;
  final String iconUrl;

  Store({
    required this.storeID,
    required this.storeName,
    required this.iconUrl,
  });

  // Método de fábrica para crear una instancia de Store a partir de un mapa JSON
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeID: json['storeID'],
      storeName: json['storeName'],
      iconUrl: 'https://www.cheapshark.com${json['images']['icon']}',
    );
  }
}
