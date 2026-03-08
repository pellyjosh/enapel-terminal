import 'package:enapel/controller/auth_controller.dart';
import 'package:enapel/database/storage/config_storage.dart';
import 'package:enapel/helper/db_connection_helper.dart'; // Assuming you have this helper
import 'package:enapel/route/route.dart';
import 'package:enapel/services/license_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileSplashScreen extends StatefulWidget {
  const MobileSplashScreen({super.key});

  @override
  State<MobileSplashScreen> createState() => _MobileSplashScreenState();
}

class _MobileSplashScreenState extends State<MobileSplashScreen> {
  late final AuthController authController;
  final TerminalLicenseService _licenseService = TerminalLicenseService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    String isServerMode =
        await ConnectionHelper.isServerConnection() ? 'server' : 'local';

    if (Get.isRegistered<AuthController>()) {
      Get.delete<AuthController>(force: true);
    }
    authController = Get.put(AuthController(isServerMode));

    _checkUserLoginStatus();
  }

  // Function to check if the user is logged in
  Future<void> _checkUserLoginStatus() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Short delay for splash screen

    if (ConfigStorage.isConfigured()) {
      final hasValidLicense = await _licenseService.ensureValid(refresh: true);
      if (!hasValidLicense) {
        return;
      }

      bool isLoggedIn = await authController.isUserLoggedIn();
      if (isLoggedIn) {
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } else {
      // If not configured, redirect to Configuration screen
      Get.offAllNamed(Routes.config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/MobileSplashScreen/bg.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/MobileSplashScreen/logo.png',
                  width: Get.size.width,
                  height: Get.size.height,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
