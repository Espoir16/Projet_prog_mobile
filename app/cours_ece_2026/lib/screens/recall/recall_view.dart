import 'package:flutter/material.dart';
import 'package:formation_flutter/screens/recall/recall_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecallView extends StatelessWidget {
  const RecallView({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d’ouvrir: $url');
    }
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'N/A';

    final d = DateTime.tryParse(iso);
    if (d == null) return iso;

    String two(int v) => v.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecallProvider>().state;

    return switch (state) {
      RecallUiLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      RecallUiError(error: final e) => Scaffold(
        appBar: AppBar(title: const Text("Rappel produit")),
        body: Center(child: Text("Erreur: $e")),
      ),
      RecallUiData(record: final r) => _RecallContent(
        record: r,
        openUrl: _openUrl,
        fmtDate: _fmtDate,
      ),
    };
  }
}

class _RecallContent extends StatelessWidget {
  const _RecallContent({
    required this.record,
    required this.openUrl,
    required this.fmtDate,
  });

  final dynamic record;
  final Future<void> Function(String url) openUrl;
  final String Function(String? iso) fmtDate;

  @override
  Widget build(BuildContext context) {
    final imgUrl = record.getStringValue('liens_vers_les_images');
    final dateDebut = record.getStringValue('date_debut_commercialisation');
    final dateFin = record.getStringValue('date_date_fin_commercialisation');
    final distributeurs = record.getStringValue('distributeurs');
    final zone = record.getStringValue('zone_geographique_de_vente');
    final motif = record.getStringValue('motif_rappel');
    final risques = record.getStringValue('risques_encourus');
    final infos = record.getStringValue('informations_complementaires');
    final conduite =
        record.getStringValue('conduites_a_tenir_par_le_consommateur');
    final pdfUrl = record.getStringValue('lien_vers_affichette_pdf');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rappel produit"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: pdfUrl.trim().isEmpty ? null : () => openUrl(pdfUrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (imgUrl.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    height: 260,
                    child: Image.network(imgUrl, fit: BoxFit.contain),
                  ),
                ),
              ),

            _Section(
              title: "Dates de commercialisation",
              child: Text(
                "Du ${fmtDate(dateDebut)} au ${fmtDate(dateFin)}",
                textAlign: TextAlign.center,
              ),
            ),

            _Section(
              title: "Distributeurs",
              child: Text(
                distributeurs.isEmpty ? "N/A" : distributeurs,
                textAlign: TextAlign.center,
              ),
            ),

            _Section(
              title: "Zone géographique",
              child: Text(
                zone.isEmpty ? "N/A" : zone,
                textAlign: TextAlign.center,
              ),
            ),

            _Section(
              title: "Motif du rappel",
              child: Text(
                motif.isEmpty ? "N/A" : motif,
                textAlign: TextAlign.center,
              ),
            ),

            _Section(
              title: "Risques encourus",
              child: Text(
                risques.isEmpty ? "N/A" : risques,
                textAlign: TextAlign.center,
              ),
            ),

            if (infos.trim().isNotEmpty)
              _Section(
                title: "Informations complémentaires",
                child: Text(infos, textAlign: TextAlign.center),
              ),

            if (conduite.trim().isNotEmpty)
              _Section(
                title: "Conduite à tenir",
                child: Text(
                  conduite.replaceAll('|', '\n• '),
                  textAlign: TextAlign.center,
                ),
              ),

              if (pdfUrl.trim().isNotEmpty)
  _Section(
    title: "Lien vers affichette",
    child: TextButton(
      onPressed: () => openUrl(pdfUrl),
      child: Text(
        pdfUrl,
        textAlign: TextAlign.center,
      ),
    ),
  ),

            const SizedBox(height: 20),
          ],
        ),
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black54,
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}