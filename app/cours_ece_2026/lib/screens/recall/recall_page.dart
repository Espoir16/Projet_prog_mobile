import 'package:flutter/material.dart';
import 'package:formation_flutter/screens/recall/recall_provider.dart';
import 'package:formation_flutter/screens/recall/recall_view.dart';
import 'package:provider/provider.dart';

class RecallPage extends StatelessWidget {
  const RecallPage({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecallProvider>(
      create: (_) => RecallProvider(recordId: recordId)..load(),
      child: const RecallView(),
    );
  }
}