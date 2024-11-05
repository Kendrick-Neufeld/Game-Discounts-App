import 'package:flutter/material.dart';

class StorefrontsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo para el tab Storefronts
        Positioned.fill(
          child: Opacity(
            opacity: 0.15, // Configura la opacidad al 5%
            child: Image.asset(
              'lib/assets/storefront_background.jpeg', // Ruta de la imagen de fondo para Storefronts
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Contenido de la pestaña Storefronts
        Center(
          child: Text('Storefronts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

