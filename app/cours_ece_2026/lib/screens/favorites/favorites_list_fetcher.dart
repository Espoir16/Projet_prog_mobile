import 'package:flutter/material.dart';
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
      final records = await pb
          .collection('favorites')
          .getFullList(
            filter: 'user="${pb.authStore.model!.id}"',
            sort: '-created',
          );

      _state = FavoritesListSuccess(records);
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
  FavoritesListSuccess(this.records);

  final List<RecordModel> records;
}

class FavoritesListError extends FavoritesListState {
  FavoritesListError(this.error);

  final dynamic error;
}
