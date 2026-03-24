import 'package:dio/dio.dart';
import 'package:formation_flutter/model/product.dart';
import 'product_api_exceptions.dart';

class OpenFoodFactsAPI {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  // Singleton
  static final OpenFoodFactsAPI _instance = OpenFoodFactsAPI._internal();

  factory OpenFoodFactsAPI() => _instance;

  final Dio _dio;

  OpenFoodFactsAPI._internal() : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  Future<Product> getProduct(String barcode) async {
    try {
      final response = await _dio.get('/product/$barcode.json');

      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 1 || data['product'] is! Map<String, dynamic>) {
        throw ProductNotFoundException(barcode);
      }

      final productData = data['product'] as Map<String, dynamic>;
      return _mapOfficialProduct(productData, barcode);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw ProductNotFoundException(barcode);
      }
      rethrow;
    }
  }

  Product _mapOfficialProduct(Map<String, dynamic> json, String barcode) {
    return Product(
      barcode: json['code'] as String? ?? barcode,
      name: _firstString(json, ['product_name_fr', 'product_name', 'product_name_en']),
      altName: _firstString(json, ['generic_name_fr', 'generic_name', 'generic_name_en']),
      picture: _firstString(json, ['image_front_url', 'image_url']),
      quantity: json['quantity'] as String?,
      brands: _splitCsv(json['brands'] as String?),
      manufacturingCountries: _splitCsv(
        _firstString(json, ['manufacturing_places', 'countries']),
      ),
      nutriScore: _parseNutriScore(json['nutriscore_grade']),
      novaScore: _parseNovaScore(json['nova_group']),
      greenScore: _parseGreenScore(json['ecoscore_grade']),
      ingredients: _mapIngredients(json['ingredients']),
      ingredientsWithAllergens: _firstString(json, [
        'ingredients_text_with_allergens',
        'ingredients_text',
      ]),
      traces: _splitCsv(json['traces'] as String?),
      allergens: _splitCsv(json['allergens'] as String?),
      additives: _mapAdditives(json['additives_tags']),
      nutrientLevels: _mapNutrientLevels(json['nutrient_levels']),
      nutritionFacts: _mapNutritionFacts(json),
      ingredientsFromPalmOil: (json['ingredients_from_palm_oil_n'] as num? ?? 0) > 0,
      containsPalmOil: _containsPalmOil(json),
      isVegan: _analysisFromTags(
        tags: (json['ingredients_analysis_tags'] as List<dynamic>?)?.cast<String>(),
        positiveTag: 'en:vegan',
        negativeTag: 'en:non-vegan',
      ),
      isVegetarian: _analysisFromTags(
        tags: (json['ingredients_analysis_tags'] as List<dynamic>?)?.cast<String>(),
        positiveTag: 'en:vegetarian',
        negativeTag: 'en:non-vegetarian',
      ),
    );
  }

  String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  List<String>? _splitCsv(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final items = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('en:'))
        .toList();
    return items.isEmpty ? null : items;
  }

  List<String>? _mapIngredients(dynamic value) {
    final items = (value as List<dynamic>?)
        ?.map((item) => item is Map<String, dynamic> ? item['text'] as String? : null)
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return items == null || items.isEmpty ? null : items;
  }

  Map<String, String>? _mapAdditives(dynamic value) {
    final tags = (value as List<dynamic>?)?.cast<String>();
    if (tags == null || tags.isEmpty) return null;
    return {for (final tag in tags) tag: tag};
  }

  NutrientLevels? _mapNutrientLevels(dynamic value) {
    final levels = value as Map<String, dynamic>?;
    if (levels == null || levels.isEmpty) return null;
    return NutrientLevels(
      salt: levels['salt'] as String?,
      saturatedFat: levels['saturated-fat'] as String?,
      sugars: levels['sugars'] as String?,
      fat: levels['fat'] as String?,
    );
  }

  NutritionFacts? _mapNutritionFacts(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>?;
    if (nutriments == null || nutriments.isEmpty) return null;

    Nutriment? read(String key, String unitKey) {
      final per100g = nutriments['${key}_100g'];
      final perServing = nutriments['${key}_serving'];
      final unit = nutriments[unitKey] as String?;
      if (per100g == null && perServing == null && (unit == null || unit.isEmpty)) {
        return null;
      }
      return Nutriment(unit: unit ?? '', perServing: perServing, per100g: per100g);
    }

    final facts = NutritionFacts(
      servingSize: json['serving_size'] as String? ?? '',
      calories: read('energy-kcal', 'energy-kcal_unit'),
      fat: read('fat', 'fat_unit'),
      saturatedFat: read('saturated-fat', 'saturated-fat_unit'),
      carbohydrate: read('carbohydrates', 'carbohydrates_unit'),
      sugar: read('sugars', 'sugars_unit'),
      fiber: read('fiber', 'fiber_unit'),
      proteins: read('proteins', 'proteins_unit'),
      sodium: read('sodium', 'sodium_unit'),
      salt: read('salt', 'salt_unit'),
      energy: read('energy-kj', 'energy-kj_unit') ?? read('energy', 'energy_unit'),
    );

    final hasAnyValue = [
      facts.calories,
      facts.fat,
      facts.saturatedFat,
      facts.carbohydrate,
      facts.sugar,
      facts.fiber,
      facts.proteins,
      facts.sodium,
      facts.salt,
      facts.energy,
    ].any((e) => e != null);

    return hasAnyValue || facts.servingSize.isNotEmpty ? facts : null;
  }

  ProductAnalysis _containsPalmOil(Map<String, dynamic> json) {
    final count = json['ingredients_from_palm_oil_n'] as num? ?? 0;
    return count > 0 ? ProductAnalysis.yes : ProductAnalysis.no;
  }

  ProductAnalysis _analysisFromTags({
    required List<String>? tags,
    required String positiveTag,
    required String negativeTag,
  }) {
    if (tags == null) return ProductAnalysis.maybe;
    if (tags.contains(negativeTag)) return ProductAnalysis.no;
    if (tags.contains(positiveTag)) return ProductAnalysis.yes;
    return ProductAnalysis.maybe;
  }

  ProductNutriScore _parseNutriScore(dynamic value) {
    return switch (value?.toString().toUpperCase()) {
      'A' => ProductNutriScore.A,
      'B' => ProductNutriScore.B,
      'C' => ProductNutriScore.C,
      'D' => ProductNutriScore.D,
      'E' => ProductNutriScore.E,
      _ => ProductNutriScore.unknown,
    };
  }

  ProductNovaScore _parseNovaScore(dynamic value) {
    return switch (value) {
      1 => ProductNovaScore.group1,
      2 => ProductNovaScore.group2,
      3 => ProductNovaScore.group3,
      4 => ProductNovaScore.group4,
      _ => ProductNovaScore.unknown,
    };
  }

  ProductGreenScore _parseGreenScore(dynamic value) {
    return switch (value?.toString().toLowerCase()) {
      'a+' => ProductGreenScore.APlus,
      'a' => ProductGreenScore.A,
      'b' => ProductGreenScore.B,
      'c' => ProductGreenScore.C,
      'd' => ProductGreenScore.D,
      'e' => ProductGreenScore.E,
      'f' => ProductGreenScore.F,
      _ => ProductGreenScore.unknown,
    };
  }
}
