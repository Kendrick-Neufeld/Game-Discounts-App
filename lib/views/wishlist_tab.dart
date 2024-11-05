import 'package:flutter/material.dart';

class WishlistTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo para el tab Wishlist
        Positioned.fill(
          child: Opacity(
            opacity: 0.15, // Configura la opacidad al 5%
            child: Image.asset(
              'lib/assets/wishlist_background.jpeg', // Ruta de la imagen de fondo para Wishlist
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Contenido de la pestaña Wishlist
        Center(
          child: Text('Wishlist', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
