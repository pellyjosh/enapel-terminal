import 'package:enapel/screens/config/configurations_screen.dart';
import 'package:enapel/screens/desktop/desktop_dashboard_screen.dart';
import 'package:enapel/screens/desktop/login_screen.dart';
import 'package:enapel/screens/license/license_required_screen.dart';
import 'package:enapel/screens/mobile/dashboard_screen.dart';
import 'package:enapel/screens/mobile/login_screen.dart';
import 'package:enapel/screens/mobile/mobile_splash_screen.dart';
import 'package:enapel/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/route_manager.dart';

class Routes {
  static String initial = "/";
  static String login = "/login";
  static String dashboard = "/dashboard";
  static String sales = "/sales";
  static const counter = '/counter';
  static const settings = '/settings';
  static const config = '/config';
  static const licenseRequired = '/license-required';
}

// Helper function to determine if the app is running on a mobile platform
bool isMobilePlatform() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
}

// Helper function to determine if the app is running on a desktop platform
bool isDesktopPlatform() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);
}

final getPages = [
  GetPage(
    name: Routes.config,
    page: () => const InitialSetupScreen(),
  ),
  GetPage(
    name: Routes.initial,
    page: () =>
        isMobilePlatform() ? const MobileSplashScreen() : const SplashScreen(),
  ),
  GetPage(
    name: Routes.login,
    page: () => isMobilePlatform()
        ? const LoginScreen()
        : const DesktopLoginScreen(), // Conditionally load the correct login screen based on platform
  ),
  GetPage(
    name: Routes.dashboard,
    page: () => isMobilePlatform()
        ? const DashboardScreen()
        : const DesktopDashboardScreen(), // Conditionally load the correct login screen based on platform
  ),
  GetPage(
    name: Routes.licenseRequired,
    page: () => const LicenseRequiredScreen(),
  ),
  // GetPage(
  //   name: Routes.sales,
  //   page: () => isMobilePlatform()
  //       ? const MobileSales()
  //       : const PointOfSaleApp(), // Conditionally load the correct login screen based on platform
  // ),

  // GetPage(name: PosRoute.initial, page: () => const PointOfSales()),
  // GetPage(name: Routes.counter, page: () => const CounterScreen()),
  // GetPage(name: Routes.settings, page: () => const SettingsScreen()),
];
