import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:go_router/go_router.dart';
import '../../test_pocketbase.dart';
import 'package:formation_flutter/screens/homepage/home_fetcher.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeFetcher _fetcher;

  @override
  void initState() {
    super.initState();
    _fetcher = HomeFetcher();
  }

  @override
  void dispose() {
    _fetcher.dispose();
    super.dispose();
  }

  Future<void> _openScan(BuildContext context) async {
    await context.push('/scan');
    if (!context.mounted) return;
    await _fetcher.load();
  }

  Future<void> _openProduct(BuildContext context, String barcode) async {
    await context.push('/product', extra: barcode);
    if (!context.mounted) return;
    await _fetcher.load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _fetcher,
      child: Builder(
        builder: (context) {
          if (!pb.authStore.isValid) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ModalRoute.of(context)?.settings.name != '/') {
                context.go('/');
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          const titleText = 'Mes scans';

          return Scaffold(
            appBar: AppBar(
              title: Text(titleText),
              centerTitle: false,
              actions: <Widget>[
                IconButton(
                  onPressed: () => _openScan(context),
                  icon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 2.0),
                    child: Icon(AppIcons.barcode),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () {
                    context.push('/favorites');
                  },
                ),
                IconButton(
                  onPressed: () {
                    pb.authStore.clear();
                    context.go('/');
                  },
                  icon: const Padding(
                    padding: EdgeInsetsDirectional.only(end: 8.0),
                    child: Icon(Icons.logout),
                  ),
                ),
              ],
            ),
            body: Consumer<HomeFetcher>(
              builder: (context, fetcher, _) {
                final state = fetcher.state;

                return switch (state) {
                  HomeLoading() =>
                    const Center(child: CircularProgressIndicator()),

                  HomeEmpty() => HomePageEmpty(
                    onScan: () => _openScan(context),
                  ),

                  HomeHistory(items: final items) => ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return _HomeHistoryCard(
                        item: item,
                        onTap: () => _openProduct(
                          context,
                          item.record.getStringValue('barcode'),
                        ),
                      );
                    },
                  ),

                  HomeError(error: final e) =>
                    Center(child: Text('Erreur : $e')),
                };
              },
            ),
          );
        },
      ),
    );
  }
}

class _HomeHistoryCard extends StatelessWidget {
  const _HomeHistoryCard({required this.item, required this.onTap});

  final HomeHistoryItem item;
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
