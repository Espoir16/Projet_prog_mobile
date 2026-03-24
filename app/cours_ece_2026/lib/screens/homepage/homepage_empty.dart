import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';

class HomePageEmpty extends StatelessWidget {
  const HomePageEmpty({super.key, this.onScan});

  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final desc =
        localizations?.my_scans_screen_description ??
        'Aucun scan pour le moment. Effectuez votre premier scan !';
    final buttonText = localizations?.my_scans_screen_button ?? 'Scanner';

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Spacer(flex: 20),
          SvgPicture.asset(AppVectorialImages.illEmpty),
          Spacer(flex: 10),
          Expanded(
            flex: 20,
            child: Column(
              children: <Widget>[
                Text(desc, textAlign: TextAlign.center),
                Spacer(flex: 5),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: TextButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blue,
                      backgroundColor: AppColors.yellow,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
                      ),
                    ),
                    onPressed: onScan,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(buttonText.toUpperCase())),
                        const SizedBox(width: 10.0),
                        Icon(Icons.arrow_forward_outlined),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 20),
        ],
      ),
    );
  }
}
