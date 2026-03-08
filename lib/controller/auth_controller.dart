import 'package:drift/drift.dart';
import 'package:enapel/api/api_service.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/helper/password_helper.dart';
import 'package:enapel/models/database/user_model.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/services/license_service.dart';
import 'package:enapel/utils/notification.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  late final EnapelDatabase database;
  late final ApiService apiService;
  final TerminalLicenseService _licenseService = TerminalLicenseService();

  AuthController(String databaseMode) {
    if (databaseMode == 'local') {
      database = Get.put(EnapelDatabase(openLocalConnection()));
    } else {
      apiService = Get.put(ApiService());
    }
  }

  Future<bool> isUserLoggedIn() async {
    final isServerMode = await ConnectionHelper.isServerConnection();

    if (isServerMode) {
      final token = KeyStorage.getString('userToken');
      final user = KeyStorage.getMap('user');
      return token != null && token.isNotEmpty && user != null;
    } else {
      final user = KeyStorage.getMap('user');
      return user != null && user.isNotEmpty;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final hasValidLicense = await _licenseService.ensureValid(refresh: true);
      if (!hasValidLicense) {
        return;
      }

      final isServerMode = await ConnectionHelper.isServerConnection();

      if (isServerMode) {
        try {
          final response = await apiService.post('login', {
            'email': email,
            'password': password,
          });

          if (response.containsKey('token') && response.containsKey('user')) {
            final String token = response['token'];
            final Map<String, dynamic> user = response['user'];

            await KeyStorage.saveString('userToken', token);
            await KeyStorage.saveMap('user', user);

            final storedUser = KeyStorage.getMap('user');
            final storedToken = KeyStorage.getString('userToken');

            if (storedUser != null &&
                storedUser.isNotEmpty &&
                storedToken == token) {
              print('User saved successfully: ${storedUser['name']}');

              NotificationService.showSuccess(
                title: 'Success',
                message: response['message'] ?? "Login successful!",
              );

              Get.offAllNamed(Routes.dashboard);
            } else {
              print("Error: User data not saved properly!");
              NotificationService.showError(
                title: 'Storage Error',
                message: "Failed to save user data. Please try again.",
              );
            }
          } else {
            NotificationService.showError(
              title: 'Error',
              message: response['message'] ?? "Invalid email or password!",
            );
          }
        } catch (e, stackTrace) {
          print("Login Error: $e");
          print("StackTrace: $stackTrace");

          NotificationService.showError(
            title: 'Login Failed',
            message: e.toString(),
          );
        }
      } else {
        final hashedPassword = PasswordHelper.hashPassword(password);

        final user = await (database.select(database.users)
              ..where((row) =>
                  row.email.equals(email) &
                  row.password.equals(hashedPassword)))
            .getSingleOrNull();

        if (user != null) {
          Map<String, dynamic> userMap = userToMap(user);
          print('LoggedIn User: $userMap');
          await KeyStorage.saveMap('user', userMap);
          NotificationService.showSuccess(
            title: 'Success',
            message: "Login successful!",
          );
          Get.offAllNamed(Routes.dashboard);
        } else {
          NotificationService.showError(
            title: 'Error',
            message: "Invalid email or password.",
          );
        }
      }
    } catch (e) {
      NotificationService.showError(
        title: 'Login Failed',
        message: e.toString(),
      );
    }
  }
}

Future<void> logout() async {
  try {
    await KeyStorage.remove('userToken');
    await KeyStorage.remove('user');

    Get.offAllNamed('/login');

    NotificationService.showSuccess(
      title: 'Logged Out',
      message: "You have been successfully logged out.",
    );
  } catch (e) {
    NotificationService.showError(
      title: 'Logout Failed',
      message: e.toString(),
    );
  }
}
