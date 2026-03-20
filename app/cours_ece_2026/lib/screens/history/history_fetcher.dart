import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/screens/product/recall_fetcher.dart';

class HistoryFetcher extends ChangeNotifier {
  HistoryFetcher() : _state = HistoryLoading() {
    loadHistory();
  }

  HistoryState _state;
  HistoryState get state => _state;

  Future<void> loadHistory() async {
    _state = HistoryLoading();
    notifyListeners();

    try {
      final records = await pb.collection('scan_history').getFullList(
        sort: '-scanned_at',
        filter: 'user="${pb.authStore.model.id}"',
      );

      _state = HistorySuccess(records);
    } catch (e) {
      _state = HistoryError(e);
    }

    notifyListeners();
  }
}

sealed class HistoryState {}

class HistoryLoading extends HistoryState {}

class HistorySuccess extends HistoryState {
  HistorySuccess(this.records);

  final List<RecordModel> records;
}

class HistoryError extends HistoryState {
  HistoryError(this.error);

  final dynamic error;
}