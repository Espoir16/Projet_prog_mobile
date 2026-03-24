import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090');

Future<void> testPocketBase() async {
  try {
    // Mets ici un vrai id qui existe dans ta base
    final record = await pb.collection('recalls').getOne('aghx7480z81e6k8');

    final barcode = record.getStringValue('barcode');
    final productName = record.getStringValue('product_name');

    print('Barcode : $barcode');
    print('Product name : $productName');

  } catch (e) {
    print('Erreur PocketBase : $e');
  }
}
