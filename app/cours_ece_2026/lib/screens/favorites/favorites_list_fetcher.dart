import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/screens/product/recall_fetcher.dart';

class FavoritesListFetcher extends ChangeNotifier {
  FavoritesListFetcher() {
    load();
  }

  FavoritesListState _state = FavoritesListLoading();
  FavoritesListState get state => _state;

  Future<void> load() async {
    try {
      final records = await pb.collection('favorites').getFullList(
        filter: 'user="${pb.authStore.model.id}"',
        sort: '-created',
      );

      _state = FavoritesListSuccess(records);
    } catch (e) {
      _state = FavoritesListError(e);
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