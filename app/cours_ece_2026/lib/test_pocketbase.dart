import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090');

Future<void> testPocketBase() async {
  try {
    // Mets ici un vrai id qui existe dans ta base
    final record = await pb.collection('rappels').getOne('aghx7480z81e6k8');

    final gtin = record.getStringValue('gtin');
    final numeroFiche = record.getStringValue('numero_fiche');

    print('GTIN : $gtin');
    print('Numero fiche : $numeroFiche');

  } catch (e) {
    print('Erreur PocketBase : $e');
  }
}