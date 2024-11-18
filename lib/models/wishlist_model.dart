class WishlistItem {
  final int idWishlist;
  final int userId;
  final String gameId;

  WishlistItem({required this.idWishlist, required this.userId, required this.gameId});

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      idWishlist: map['id_wishlist'],
      userId: map['user_id'],
      gameId: map['game_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_wishlist': idWishlist,
      'user_id': userId,
      'game_id': gameId,
    };
  }
}