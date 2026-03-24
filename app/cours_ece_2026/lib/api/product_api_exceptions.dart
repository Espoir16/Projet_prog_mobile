class ProductNotFoundException implements Exception {
  ProductNotFoundException(this.barcode);

  final String barcode;

  @override
  String toString() => 'Produit introuvable pour le code-barres $barcode.';
}
