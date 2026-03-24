import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/favorites/favorites_list_fetcher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoritesListFetcher _fetcher;

  @override
  void initState() {
    super.initState();
    _fetcher = FavoritesListFetcher();
  }

  @override
  void dispose() {
    _fetcher.dispose();
    super.dispose();
  }

  Future<void> _openProduct(BuildContext context, String barcode) async {
    await context.push('/product', extra: barcode);
    if (!context.mounted) return;
    await _fetcher.load();
  }

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);

    return ChangeNotifierProvider.value(
      value: _fetcher,
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
                  FavoritesListSuccess(items: final items) =>
                    items.isEmpty
                        ? const Center(
                            child: Text("Aucun favori pour le moment"),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 88, 16, 16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return _FavoriteCard(
                                item: item,
                                onTap: () => _openProduct(
                                  context,
                                  item.record.getStringValue('barcode'),
                                ),
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

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item, required this.onTap});

  final FavoriteListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final barcode = item.record.getStringValue('barcode');
    final title = product?.name?.trim().isNotEmpty == true ? product!.name! : barcode;
    final brand = product?.brands?.isNotEmpty == true ? product!.brands!.first : barcode;
    final picture = product?.picture;
    final nutriScore = product?.nutriScore ?? ProductNutriScore.unknown;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: picture != null && picture.isNotEmpty
                      ? Image.network(
                          picture,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _ImageFallback(),
                        )
                      : const _ImageFallback(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blueDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.grey2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _nutriScoreColor(nutriScore),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nutriscore : ${_nutriScoreLabel(nutriScore)}',
                            style: const TextStyle(
                              color: AppColors.grey3,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _nutriScoreColor(ProductNutriScore score) {
    return switch (score) {
      ProductNutriScore.A => AppColors.nutriscoreA,
      ProductNutriScore.B => AppColors.nutriscoreB,
      ProductNutriScore.C => AppColors.nutriscoreC,
      ProductNutriScore.D => AppColors.nutriscoreD,
      ProductNutriScore.E => AppColors.nutriscoreE,
      ProductNutriScore.unknown => AppColors.grey2,
    };
  }

  String _nutriScoreLabel(ProductNutriScore score) {
    return switch (score) {
      ProductNutriScore.A => 'A',
      ProductNutriScore.B => 'B',
      ProductNutriScore.C => 'C',
      ProductNutriScore.D => 'D',
      ProductNutriScore.E => 'E',
      ProductNutriScore.unknown => '-',
    };
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.grey1,
      child: Center(
        child: Icon(Icons.fastfood, color: AppColors.grey2, size: 28),
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
