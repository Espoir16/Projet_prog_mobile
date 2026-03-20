import 'package:flutter/material.dart';
import 'package:formation_flutter/screens/history/history_fetcher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryFetcher(),
      child: Scaffold(
        appBar: AppBar(
  title: const Text('Historique des scans'),
  actions: [
    IconButton(
      icon: const Icon(Icons.star),
      onPressed: () {
        context.push('/favorites');
      },
    ),
  ],
),
        body: Consumer<HistoryFetcher>(
          builder: (context, fetcher, _) {
            final state = fetcher.state;

            return switch (state) {
              HistoryLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              HistoryError(error: final err) => Center(
                child: Text('Erreur : $err'),
              ),
              HistorySuccess(records: final records) => ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final barcode = record.getStringValue('barcode');
                  final scannedAt = record.getStringValue('scanned_at');

                  return ListTile(
                    title: Text(barcode),
                    subtitle: Text(scannedAt),
                  );
                },
              ),
            };
          },
        ),
      ),
    );
  }
}