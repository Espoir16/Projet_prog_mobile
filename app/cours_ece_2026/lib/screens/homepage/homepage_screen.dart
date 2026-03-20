import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:go_router/go_router.dart';
import 'package:formation_flutter/screens/homepage/home_fetcher.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
  title: Text(localizations.my_scans_screen_title),
  centerTitle: false,
  actions: <Widget>[
    IconButton(
      icon: const Icon(Icons.star),
      onPressed: () {
        context.push('/favorites');
      },
    ),
    IconButton(
      onPressed: () => _onScanButtonPressed(context),
      icon: Padding(
        padding: const EdgeInsetsDirectional.only(end: 8.0),
        child: Icon(AppIcons.barcode),
      ),
    ),
  ],
),
      body: ChangeNotifierProvider(
  create: (_) => HomeFetcher(),
  child: Consumer<HomeFetcher>(
    builder: (context, fetcher, _) {
      final state = fetcher.state;

      return switch (state) {

        HomeLoading() => const Center(
          child: CircularProgressIndicator(),
        ),

        HomeEmpty() => HomePageEmpty(
          onScan: () => _onScanButtonPressed(context),
        ),

        HomeHistory(records: final records) => ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            final barcode = record.getStringValue('barcode');

            return ListTile(
              title: Text(barcode),
              leading: const Icon(Icons.qr_code),
              onTap: () {
                context.push('/product', extra: barcode);
              },
            );
          },
        ),

        HomeError(error: final e) => Center(
          child: Text('Erreur : $e'),
        ),
      };
    },
  ),
),
    );
  }

  void _onScanButtonPressed(BuildContext context) {
    context.push('/product', extra: '5000159484695');
  }
}