class GameDeal {
  final String title;
  final String storeID;
  final String salePrice;
  final String normalPrice;
  final String savings;
  final String? steamRatingText; // Campo opcional
  final String? thumb; // Campo opcional

  GameDeal({
    required this.title,
    required this.storeID,
    required this.salePrice,
    required this.normalPrice,
    required this.savings,
    this.steamRatingText, // Campo opcional
    this.thumb, // Campo opcional
  });

  factory GameDeal.fromJson(Map<String, dynamic> json) {
    return GameDeal(
      title: json['title'] ?? 'Unknown Title',
      storeID: json['storeID'] ?? 'Unknown Store',
      salePrice: json['salePrice'] ?? '0.00',
      normalPrice: json['normalPrice'] ?? '0.00',
      savings: json['savings'] ?? '0.00',
      steamRatingText: json['steamRatingText'], // Opcional, puede ser null
      thumb: json['thumb'], // Opcional, puede ser null
    );
  }
}
