import 'package:flutter/material.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import '../../pocketbase_error_utils.dart';
import '../../test_pocketbase.dart';

class FavoritesFetcher extends ChangeNotifier {
  FavoritesFetcher({required this.barcode}) {
    load();
  }

  final String barcode;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  String? _recordId;

  Future<void> load() async {
    if (!pb.authStore.isValid || pb.authStore.model == null) return;
    try {
      final records = await pb
          .collection('favorites')
          .getFullList(
            filter: 'user="${pb.authStore.model!.id}" && barcode="$barcode"',
          );

      if (records.isNotEmpty) {
        _isFavorite = true;
        _recordId = records.first.id;
      }
    } catch (e) {
      if (!isMissingCollectionError(e)) rethrow;
    }

    notifyListeners();
  }

  Future<void> toggle() async {
    if (!pb.authStore.isValid || pb.authStore.model == null) return;
    try {
      if (_isFavorite) {
        await pb.collection('favorites').delete(_recordId!);
        _isFavorite = false;
      } else {
        final record = await pb
            .collection('favorites')
            .create(body: {'user': pb.authStore.model!.id, 'barcode': barcode});

        _recordId = record.id;
        _isFavorite = true;
      }
    } catch (e) {
      if (!isMissingCollectionError(e)) rethrow;
    }

    notifyListeners();
  }
}
