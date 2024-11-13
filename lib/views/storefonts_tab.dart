import 'package:flutter/material.dart';
import 'package:game_discounts_app/main.dart';
import '/Store.dart';

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
        // Contenido principal
        storeList.isEmpty
            ? Center(
          child: Text(
            'No stores available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: storeList.length,
          itemBuilder: (context, index) {
            final store = storeList[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    store.logoUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.store, size: 50, color: Colors.grey),
                  ),
                ),
                title: Text(
                  store.storeName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Image.network(
                  store.iconUrl,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.store, size: 30, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}