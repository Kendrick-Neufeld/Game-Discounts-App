import 'package:flutter/material.dart';
import '../Game.dart';

class WishlistItemCard extends StatelessWidget {
  final Game game;
  final VoidCallback onRemove;

  const WishlistItemCard({
    required this.game,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Image.network(game.thumb, fit: BoxFit.cover, width: 50, height: 50),
        title: Text(game.title),
        subtitle: Text(
          'Cheapest Price Ever: \$${(game.cheapestPriceEver != null ? double.tryParse(game.cheapestPriceEver.toString()) : 0.0)?.toStringAsFixed(2)}',
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}