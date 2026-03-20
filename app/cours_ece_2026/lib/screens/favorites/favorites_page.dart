import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/favorites/favorites_list_fetcher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);

    return ChangeNotifierProvider(
      create: (_) => FavoritesListFetcher(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Consumer<FavoritesListFetcher>(
              builder: (context, fav, _) {
                final state = fav.state;

                return switch (state) {
                  FavoritesListLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  FavoritesListError(error: final err) => Center(
                    child: Text("Erreur : $err"),
                  ),
                  FavoritesListSuccess(records: final records) =>
                    records.isEmpty
                        ? const Center(
                            child: Text("Aucun favori pour le moment"),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 80),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              final barcode = record.getStringValue('barcode');

                              return ListTile(
                                leading: const Icon(Icons.star),
                                title: Text(barcode),
                                onTap: () {
                                  context.push('/product', extra: barcode);
                                },
                              );
                            },
                          ),
                };
              },
            ),
            PositionedDirectional(
              top: 0.0,
              start: 0.0,
              child: _HeaderIcon(
                icon: AppIcons.close,
                tooltip: materialLocalizations.closeButtonTooltip,
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onPressed ?? () {},
              customBorder: const CircleBorder(),
              child: Ink(
                padding: const EdgeInsetsDirectional.all(12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.0),
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 0.0),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}