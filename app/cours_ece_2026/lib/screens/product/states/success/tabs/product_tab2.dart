import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:provider/provider.dart';

class ProductTab2 extends StatelessWidget {
  const ProductTab2({super.key});

  @override
  Widget build(BuildContext context) {
    final product = context.read<Product>();
    final facts = product.nutritionFacts;

    final cards = <_NutritionCardData>[
      _NutritionCardData(
        title: 'Matieres grasses / lipides',
        nutriment: facts?.fat,
        level: _resolveLevel(product.nutrientLevels?.fat, facts?.fat?.per100g),
      ),
      _NutritionCardData(
        title: 'Acides gras satures',
        nutriment: facts?.saturatedFat,
        level: _resolveLevel(
          product.nutrientLevels?.saturatedFat,
          facts?.saturatedFat?.per100g,
        ),
      ),
      _NutritionCardData(
        title: 'Sucres',
        nutriment: facts?.sugar,
        level: _resolveLevel(
          product.nutrientLevels?.sugars,
          facts?.sugar?.per100g,
        ),
      ),
      _NutritionCardData(
        title: 'Sel',
        nutriment: facts?.salt,
        level: _resolveLevel(product.nutrientLevels?.salt, facts?.salt?.per100g),
      ),
    ].where((card) => card.nutriment != null).toList(growable: false);

    if (cards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Informations nutritionnelles indisponibles.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            _NutritionCard(card: cards[i]),
            if (i < cards.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  _NutrientLevel _resolveLevel(String? rawLevel, dynamic per100g) {
    final level = rawLevel?.toLowerCase();
    if (level == 'low') return _NutrientLevel.low;
    if (level == 'moderate') return _NutrientLevel.moderate;
    if (level == 'high') return _NutrientLevel.high;

    final value = per100g is num ? per100g.toDouble() : double.tryParse('$per100g');
    if (value == null) return _NutrientLevel.unknown;

    if (value < 3) return _NutrientLevel.low;
    if (value < 17.5) return _NutrientLevel.moderate;
    return _NutrientLevel.high;
  }
}

class _NutritionCardData {
  const _NutritionCardData({
    required this.title,
    required this.nutriment,
    required this.level,
  });

  final String title;
  final Nutriment? nutriment;
  final _NutrientLevel level;
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.card});

  final _NutritionCardData card;

  @override
  Widget build(BuildContext context) {
    final nutriment = card.nutriment!;
    final color = switch (card.level) {
      _NutrientLevel.low => AppColors.nutrientLevelLow,
      _NutrientLevel.moderate => AppColors.nutrientLevelModerate,
      _NutrientLevel.high => AppColors.nutrientLevelHigh,
      _NutrientLevel.unknown => AppColors.grey2,
    };
    final label = switch (card.level) {
      _NutrientLevel.low => 'Faible quantite',
      _NutrientLevel.moderate => 'Quantite moderee',
      _NutrientLevel.high => 'Quantite elevee',
      _NutrientLevel.unknown => 'Niveau inconnu',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: context.theme.title3),
                const SizedBox(height: 8),
                Text(
                  _formatNutriment(nutriment.per100g, nutriment.unit),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Repere nutritionnel pour 100 g',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNutriment(dynamic value, String unit) {
    if (value == null) return '-';
    if (value is num) return '${value.toStringAsFixed(1)} $unit';
    return '$value $unit';
  }
}

enum _NutrientLevel { low, moderate, high, unknown }
