import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_text.dart';
import 'core/network/network_info.dart';
import 'core/theme/app_theme.dart';
import 'features/feed/presentation/bindings/feed_binding.dart';
import 'features/feed/presentation/pages/feed_page.dart';
import 'features/feed/presentation/pages/splash_page.dart';

/// Application entry point.
///
/// Initializes global services before launching the app:
/// 1. SharedPreferences (persistent storage)
/// 2. NetworkInfo (connectivity monitoring)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Initialize Global Services ──
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs);

  final networkInfo = NetworkInfo();
  Get.put<NetworkInfo>(networkInfo);

  runApp(const FeedFusionApp());
}

class FeedFusionApp extends StatelessWidget {
  const FeedFusionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppText.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // ── Smooth Scrolling Physics ──
      scrollBehavior: const CustomScrollBehavior(),

      // ── Routes ──
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(
          name: '/feed',
          page: () => const FeedPage(),
          binding: FeedBinding(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}

/// Custom Scroll Behavior for ultra-smooth physics across platforms.
class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
