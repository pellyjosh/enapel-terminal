import 'package:enapel/controller/connectivity_controller.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServerDownScreen extends StatelessWidget {
  const ServerDownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnectivityController connectivityController = Get.find<ConnectivityController>();

    return Scaffold(
      backgroundColor: AppColor.black.withOpacity(0.9),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColor.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.danger.withOpacity(0.5)),
          ),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 80,
                color: AppColor.danger,
              ),
              const SizedBox(height: 24),
              Text(
                "Central Server Offline",
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "The terminal cannot reach the central server. Please check your network connection or ensure the server is running.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                onPressed: connectivityController.isChecking.value 
                  ? null 
                  : () async {
                      bool success = await connectivityController.checkConnection();
                      if (success) {
                        Get.snackbar(
                          "Restored", 
                          "Connection to central server restored.",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          "Failed", 
                          "Server is still unreachable.",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: connectivityController.isChecking.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Retry Connection",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Option to go back to config or login if needed
                  Get.offAllNamed('/config'); // Assuming /config exists
                },
                child: Text(
                  "Change Server Settings",
                  style: TextStyle(color: AppColor.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
