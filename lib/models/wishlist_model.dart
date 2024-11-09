class WishlistItem {
  final int id;
  final int userId;
  final String gameId;

  WishlistItem({required this.id, required this.userId, required this.gameId});

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'],
      userId: map['user_id'],
      gameId: map['game_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'game_id': gameId,
    };
  }
}