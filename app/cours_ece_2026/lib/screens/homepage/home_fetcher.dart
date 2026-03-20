import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/screens/product/recall_fetcher.dart';

class HomeFetcher extends ChangeNotifier {
  HomeFetcher() : _state = HomeLoading() {
    load();
  }

  HomeState _state;
  HomeState get state => _state;

  Future<void> load() async {
    try {
      final records = await pb.collection('scan_history').getFullList(
        filter: 'user="${pb.authStore.model.id}"',
        sort: '-scanned_at',
      );

      if (records.isEmpty) {
        _state = HomeEmpty();
      } else {
        _state = HomeHistory(records);
      }
    } catch (e) {
      _state = HomeError(e);
    }

    notifyListeners();
  }
}

sealed class HomeState {}

class HomeLoading extends HomeState {}

class HomeEmpty extends HomeState {}

class HomeHistory extends HomeState {
  HomeHistory(this.records);

  final List<RecordModel> records;
}

class HomeError extends HomeState {
  HomeError(this.error);

  final dynamic error;
}