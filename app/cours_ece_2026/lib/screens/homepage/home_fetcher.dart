import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/screens/product/recall_fetcher.dart';
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
      final records = await pb
          .collection('scan_history')
          .getFullList(filter: 'user="$userId"', sort: '-scanned_at');

      if (records.isEmpty) {
        _state = HomeEmpty();
      } else {
        _state = HomeHistory(records);
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
  HomeHistory(this.records);

  final List<RecordModel> records;
}

class HomeError extends HomeState {
  HomeError(this.error);

  final dynamic error;
}
