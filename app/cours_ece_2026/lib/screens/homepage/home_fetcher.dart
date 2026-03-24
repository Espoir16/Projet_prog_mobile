import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/model/product.dart';
import '../../pocketbase_error_utils.dart';
import '../../test_pocketbase.dart';

class HomeFetcher extends ChangeNotifier {
  HomeFetcher() : _state = HomeLoading() {
    load();
  }

  HomeState _state;
  HomeState get state => _state;

  Future<void> load() async {
    try {
      if (!pb.authStore.isValid || pb.authStore.model == null) {
        // Pas d'utilisateur connecté : on garde l'état vide.
        _state = HomeEmpty();
        notifyListeners();
        return;
      }

      final userId = pb.authStore.model!.id;
      final fetchedRecords = await pb
          .collection('scan_history')
          .getFullList(sort: '-scanned_at');
      final records = fetchedRecords.where((record) {
        final relationValues = record.getListValue<String>('user');
        if (relationValues.contains(userId)) return true;

        final directValue = record.data['user']?.toString();
        return directValue == userId;
      }).toList(growable: false);

      if (records.isEmpty) {
        _state = HomeEmpty();
      } else {
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

            return HomeHistoryItem(record: record, product: product);
          }),
        );

        _state = HomeHistory(items);
      }
    } catch (e) {
      if (isMissingCollectionError(e)) {
        _state = HomeEmpty();
      } else {
        _state = HomeError(e);
      }
    }

    notifyListeners();
  }
}

sealed class HomeState {}

class HomeLoading extends HomeState {}

class HomeEmpty extends HomeState {}

class HomeHistory extends HomeState {
  HomeHistory(this.items);

  final List<HomeHistoryItem> items;
}

class HomeError extends HomeState {
  HomeError(this.error);

  final dynamic error;
}

class HomeHistoryItem {
  HomeHistoryItem({required this.record, required this.product});

  final RecordModel record;
  final Product? product;
}
