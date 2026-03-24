import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:provider/provider.dart';

class ProductTab1 extends StatelessWidget {
  const ProductTab1({super.key});

  @override
  Widget build(BuildContext context) {
    final product = context.read<Product>();
    final ingredients = product.ingredients ?? const <String>[];
    final allergens = product.allergens ?? const <String>[];
    final additives = product.additives?.keys.toList() ?? const <String>[];

    return SingleChildScrollView(
      child: Column(
        children: [
          _Section(
            title: 'Ingredients',
            child: ingredients.isEmpty
                ? const _EmptyText()
                : Column(
                    children: ingredients
                        .map(
                          (ingredient) => _KeyValueRow(
                            label: ingredient,
                            value: '',
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
          _Section(
            title: 'Substances allergenes',
            child: allergens.isEmpty
                ? const _EmptyText()
                : Column(
                    children: allergens
                        .map(
                          (allergen) => _KeyValueRow(
                            label: allergen,
                            value: '',
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
          _Section(
            title: 'Additifs',
            child: additives.isEmpty
                ? const _EmptyText()
                : Column(
                    children: additives
                        .map(
                          (additive) => _KeyValueRow(
                            label: additive.toUpperCase(),
                            value: '',
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          color: const Color(0xFFF3F3F3),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: context.theme.title3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: child,
        ),
      ],
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Aucune',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}
