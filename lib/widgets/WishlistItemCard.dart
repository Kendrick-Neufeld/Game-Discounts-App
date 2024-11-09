import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Game.dart';

class WishlistItemCard extends StatelessWidget {
  final Game game;
  final VoidCallback onRemove;  // Callback para remover el juego

  WishlistItemCard({required this.game, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              game.thumb, // Usa la imagen del juego
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              game.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${game.cheapestPriceEver}', // Muestra el precio más bajo
                    style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onRemove, // Llama a onRemove para eliminar el juego
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}