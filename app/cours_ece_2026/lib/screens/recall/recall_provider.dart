import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/screens/product/recall_fetcher.dart';
import '../../test_pocketbase.dart';

sealed class RecallUiState {}

class RecallUiLoading extends RecallUiState {}

class RecallUiError extends RecallUiState {
  RecallUiError(this.error);

  final dynamic error;
}

class RecallUiData extends RecallUiState {
  RecallUiData({required this.record});

  final RecordModel record;
}

class RecallProvider extends ChangeNotifier {
  RecallProvider({required this.recordId});

  final String recordId;

  RecallUiState _state = RecallUiLoading();

  RecallUiState get state => _state;

  Future<void> load() async {
    _state = RecallUiLoading();
    notifyListeners();

    try {
      final record = await pb.collection('recalls').getOne(recordId);
      _state = RecallUiData(record: record);
    } catch (e) {
      _state = RecallUiError(e);
    }

    notifyListeners();
  }
}
