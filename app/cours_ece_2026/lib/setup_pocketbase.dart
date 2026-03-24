import 'package:pocketbase/pocketbase.dart';
import 'test_pocketbase.dart';

Future<void> setupPocketBaseCollections() async {
  try {
    print('=== Setting up PocketBase Collections ===');

    // Get existing collections
    final collections = await pb.collections.getFullList();
    print('Found ${collections.length} collections');

    // Check users collection
    final usersCollection = collections
        .where((c) => c.name == 'users')
        .toList();
    if (usersCollection.isEmpty) {
      print('❌ Users collection missing - creating it...');

      // Create users collection (PocketBase should have created this automatically)
      // If not, we need to create it manually
      print('⚠️  Please create users collection manually in PocketBase Admin');
      print('   Go to http://127.0.0.1:8090/_/ and create collection "users"');
    } else {
      print('✅ Users collection exists');
    }

    // Check recalls collection
    final recallsCollection = collections
        .where((c) => c.name == 'recalls')
        .toList();
    if (recallsCollection.isEmpty) {
      print('❌ Recalls collection missing');
      print('   Import it from server/recalls_collections.json');
    } else {
      print('✅ Recalls collection exists');
    }

    // Check scan_history collection
    final scanHistoryCollection = collections
        .where((c) => c.name == 'scan_history')
        .toList();
    if (scanHistoryCollection.isEmpty) {
      print('âš ï¸  scan_history collection missing');
      print('   Home/history pages will stay empty until it is created');
    } else {
      print('âœ… scan_history collection exists');
    }

    // Check favorites collection
    final favoritesCollection = collections
        .where((c) => c.name == 'favorites')
        .toList();
    if (favoritesCollection.isEmpty) {
      print('âš ï¸  favorites collection missing');
      print('   Favorites features will stay empty until it is created');
    } else {
      print('âœ… favorites collection exists');
    }

    print('=== Setup Complete ===');
  } catch (e) {
    print('❌ Error setting up collections: $e');
  }
}

Future<void> testAuthFlow() async {
  try {
    print('=== Testing Auth Flow ===');

    // Test signup
    print('Testing signup...');
    final testEmail = 'test@example.com';
    final testPassword = 'test123456';

    try {
      await pb
          .collection('users')
          .create(
            body: {
              'email': testEmail,
              'password': testPassword,
              'passwordConfirm': testPassword,
            },
          );
      print('✅ Signup successful');
    } catch (e) {
      if (e.toString().contains('already exists')) {
        print('⚠️  User already exists, continuing...');
      } else {
        print('❌ Signup failed: $e');
        return;
      }
    }

    // Test login
    print('Testing login...');
    await pb.collection('users').authWithPassword(testEmail, testPassword);
    print('✅ Login successful');
    print('User ID: ${pb.authStore.model?.id}');
    print('Is valid: ${pb.authStore.isValid}');

    // Test logout
    pb.authStore.clear();
    print('✅ Logout successful');
  } catch (e) {
    print('❌ Auth test failed: $e');
  }
}
