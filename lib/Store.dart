class Store {
  final String storeID;
  final String storeName;
  final String iconUrl;
  final String logoUrl; // Nuevo atributo para el logotipo

  Store({
    required this.storeID,
    required this.storeName,
    required this.iconUrl,
    required this.logoUrl,
  });

  // Método de fábrica para crear una instancia de Store a partir de un mapa JSON
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeID: json['storeID'],
      storeName: json['storeName'],
      iconUrl: 'https://www.cheapshark.com${json['images']['icon']}',
      logoUrl: 'https://www.cheapshark.com${json['images']['logo']}', // URL del logotipo
    );
  }
}

