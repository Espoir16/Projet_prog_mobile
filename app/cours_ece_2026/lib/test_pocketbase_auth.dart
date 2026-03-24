import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090');

Future<void> testPocketBaseAuth() async {
  try {
    print('=== Testing PocketBase Connection ===');

    // Test connection
    final health = await pb.health.check();
    print('PocketBase health: ${health.code}');

    // Get collections
    final collections = await pb.collections.getFullList();
    print('Collections found: ${collections.length}');
    for (var collection in collections) {
      print('- ${collection.name}');
    }

    // Check if users collection exists
    final usersCollection = collections
        .where((c) => c.name == 'users')
        .toList();
    if (usersCollection.isNotEmpty) {
      print('✅ Users collection exists');
    } else {
      print('❌ Users collection missing - need to create it');
    }

    // Check if recalls collection exists
    final recallsCollection = collections
        .where((c) => c.name == 'recalls')
        .toList();
    if (recallsCollection.isNotEmpty) {
      print('✅ Recalls collection exists');
    } else {
      print('❌ Recalls collection missing');
    }
  } catch (e) {
    print('❌ Error testing PocketBase: $e');
  }
}
