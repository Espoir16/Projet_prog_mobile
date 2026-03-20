import 'package:flutter/material.dart';
import 'package:formation_flutter/screens/product/recall_fetcher.dart';
import 'package:go_router/go_router.dart';

class RecallBanner extends StatelessWidget {
  const RecallBanner({super.key, required this.state});

  final RecallState state;

  @override
  Widget build(BuildContext context) {
    if (state is! RecallFound) return const SizedBox.shrink();
    final found = state as RecallFound;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/recall', extra: found.recordId),
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF0000).withOpacity(0.36),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Expanded(
              child: Text(
                "Ce produit fait l’objet d’un rappel produit",
                style: TextStyle(
                  color: Color(0xFFA60000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, color: Color(0xFFA60000)),
          ],
        ),
      ),
    );
  }
}