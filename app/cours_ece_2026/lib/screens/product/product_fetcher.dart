import 'package:flutter/material.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/model/product.dart';
import '../../pocketbase_error_utils.dart';
import '../../test_pocketbase.dart';

class ProductFetcher extends ChangeNotifier {
  ProductFetcher({required String barcode})
    : _barcode = barcode,
      _state = ProductFetcherLoading() {
    loadProduct();
  }

  final String _barcode;
  ProductFetcherState _state;

  Future<void> loadProduct() async {
    _state = ProductFetcherLoading();
    notifyListeners();

    try {
      Product product = await OpenFoodFactsAPI().getProduct(_barcode);

      _state = ProductFetcherSuccess(product);
      notifyListeners();

      if (pb.authStore.isValid && pb.authStore.model != null) {
        try {
          await pb
              .collection('scan_history')
              .create(
                body: {
                  'user': pb.authStore.model!.id,
                  'barcode': _barcode,
                  'scanned_at': DateTime.now().toIso8601String(),
                },
              );
        } catch (e) {
          if (!isMissingCollectionError(e)) {
            print('Erreur scan_history: $e');
          }
        }
      }
    } catch (error) {
      _state = ProductFetcherError(error);
      notifyListeners();
    }
  }

  ProductFetcherState get state => _state;
}

sealed class ProductFetcherState {}

class ProductFetcherLoading extends ProductFetcherState {}

class ProductFetcherSuccess extends ProductFetcherState {
  ProductFetcherSuccess(this.product);

  final Product product;
}

class ProductFetcherError extends ProductFetcherState {
  ProductFetcherError(this.error);

  final dynamic error;
}
