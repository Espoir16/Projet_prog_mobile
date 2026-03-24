import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/screens/homepage/homepage_screen.dart';
import 'package:formation_flutter/screens/product/product_page.dart';
import 'package:formation_flutter/screens/scan/scan_page.dart';
import 'package:go_router/go_router.dart';
import 'test_pocketbase.dart';
import 'package:formation_flutter/screens/recall/recall_page.dart';
import 'package:formation_flutter/screens/auth/login_page.dart';
import 'package:formation_flutter/screens/history/history_page.dart';
import 'package:formation_flutter/screens/favorites/favorites_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Test auth flow (optionnel - commente pour la prod)
  // await testAuthFlow();

  runApp(const MyApp());
}

GoRouter _router = GoRouter(
  initialLocation: pb.authStore.isValid
      ? '/home'
      : '/', // Redirection selon état auth
  routes: [
    GoRoute(path: '/', builder: (_, _) => const LoginPage()),
    GoRoute(path: '/home', builder: (_, _) => HomePage()),
    GoRoute(path: '/scan', builder: (_, __) => const ScanPage()),
    GoRoute(
      path: '/product',
      builder: (_, GoRouterState state) =>
          ProductPage(barcode: state.extra as String),
    ),
    GoRoute(
      path: '/recall',
      builder: (_, state) => RecallPage(recordId: state.extra as String),
    ),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesPage()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
  ],
  redirect: (context, state) {
    // Si pas connecté et pas sur la page de login, rediriger vers login
    final isLoggedIn = pb.authStore.isValid;
    final isOnLoginPage = state.matchedLocation == '/';

    if (!isLoggedIn && !isOnLoginPage) {
      return '/';
    }

    // Si connecté et sur la page de login, rediriger vers home
    if (isLoggedIn && isOnLoginPage) {
      return '/home';
    }

    return null; // Pas de redirection
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Open Food Facts',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        extensions: [OffThemeExtension.defaultValues()],
        fontFamily: 'Avenir',
        dividerTheme: DividerThemeData(color: AppColors.grey2, space: 1.0),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: AppColors.grey2,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: AppColors.blue,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
