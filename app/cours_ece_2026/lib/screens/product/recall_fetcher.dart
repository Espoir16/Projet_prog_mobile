import 'package:flutter/material.dart';
import '../../test_pocketbase.dart';

class RecallFetcher extends ChangeNotifier {
  RecallFetcher({required String barcode})
    : _barcode = barcode,
      _state = RecallLoading() {
    loadRecall();
  }

  final String _barcode;
  RecallState _state;

  RecallState get state => _state;

  Future<void> loadRecall() async {
    _state = RecallLoading();
    notifyListeners();

    try {
      final result = await pb
          .collection('recalls')
          .getList(
            page: 1,
            perPage: 1,
            filter: 'barcode="$_barcode"',
          );

      if (result.items.isEmpty) {
        _state = RecallNone();
      } else {
        final record = result.items.first;
        _state = RecallFound(recordId: record.id);
      }
    } catch (e) {
      _state = RecallError(e);
    }

    notifyListeners();
  }
}

sealed class RecallState {}

class RecallLoading extends RecallState {}

class RecallNone extends RecallState {}

class RecallFound extends RecallState {
  RecallFound({required this.recordId});

  final String recordId;
}

class RecallError extends RecallState {
  RecallError(this.error);

  final dynamic error;
}
