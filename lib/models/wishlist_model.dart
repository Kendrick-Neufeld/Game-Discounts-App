class WishlistItem {
  final int id_wishlist;
  final int userId;
  final String gameId;

  WishlistItem({required this.id_wishlist, required this.userId, required this.gameId});

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id_wishlist: map['id_wishlist'],
      userId: map['user_id'],
      gameId: map['game_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_wishlist': id_wishlist,
      'user_id': userId,
      'game_id': gameId,
    };
  }
}