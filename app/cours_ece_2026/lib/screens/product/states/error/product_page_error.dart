import 'package:flutter/material.dart';
import 'package:formation_flutter/api/product_api_exceptions.dart';

class ProductPageError extends StatelessWidget {
  const ProductPageError({super.key, this.error});

  final dynamic error;

  @override
  Widget build(BuildContext context) {
    final (title, message) = switch (error) {
      ProductNotFoundException(barcode: final barcode) => (
        'Produit introuvable',
        'Aucune fiche produit n\'a ete trouvee pour le code-barres $barcode.',
      ),
      _ => (
        'Erreur de chargement',
        'Impossible de recuperer les informations du produit.',
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
