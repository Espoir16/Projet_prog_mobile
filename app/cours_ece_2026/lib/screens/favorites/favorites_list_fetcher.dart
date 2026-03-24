import 'package:flutter/material.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../pocketbase_error_utils.dart';
import '../../test_pocketbase.dart';

class FavoritesListFetcher extends ChangeNotifier {
  FavoritesListFetcher() {
    load();
  }

  FavoritesListState _state = FavoritesListLoading();
  FavoritesListState get state => _state;

  Future<void> load() async {
    try {
      if (!pb.authStore.isValid || pb.authStore.model == null) {
        _state = FavoritesListSuccess([]);
        notifyListeners();
        return;
      }
      final fetchedRecords = await pb
          .collection('favorites')
          .getFullList(sort: '-created');
      final userId = pb.authStore.model!.id;
      final records = fetchedRecords.where((record) {
        final relationValues = record.getListValue<String>('user');
        if (relationValues.contains(userId)) return true;

        final directValue = record.data['user']?.toString();
        return directValue == userId;
      }).toList(growable: false);

      final items = await Future.wait(
        records.map((record) async {
          final barcode = record.getStringValue('barcode');
          Product? product;

          if (barcode.trim().isNotEmpty) {
            try {
              product = await OpenFoodFactsAPI().getProduct(barcode);
            } catch (_) {
              product = null;
            }
          }

          return FavoriteListItem(record: record, product: product);
        }),
      );

      _state = FavoritesListSuccess(items);
    } catch (e) {
      if (isMissingCollectionError(e)) {
        _state = FavoritesListSuccess([]);
      } else {
        _state = FavoritesListError(e);
      }
    }

    notifyListeners();
  }
}

sealed class FavoritesListState {}

class FavoritesListLoading extends FavoritesListState {}

class FavoritesListSuccess extends FavoritesListState {
  FavoritesListSuccess(this.items);

  final List<FavoriteListItem> items;
}

class FavoritesListError extends FavoritesListState {
  FavoritesListError(this.error);

  final dynamic error;
}

class FavoriteListItem {
  FavoriteListItem({required this.record, required this.product});

  final RecordModel record;
  final Product? product;
}
