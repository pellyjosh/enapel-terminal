import 'dart:convert';

import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/services/license_service.dart';
import 'package:enapel/utils/notification.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService {
  late String baseUrl;
  final TerminalLicenseService _licenseService = TerminalLicenseService();

  ApiService() {
    _initializeBaseUrl();
  }
  Future<String?> _getToken() async {
    return KeyStorage.getString('userToken');
  }

  Future<void> _initializeBaseUrl() async {
    String? serverIp =
        KeyStorage.getString('serverIp') ?? KeyStorage.getString('server_ip');
    if (serverIp == null || serverIp.isEmpty) {
      NotificationService.showError(
        title: "Error",
        message: "No configuration found. Please configure the server IP.",
      );
      Get.offAllNamed(Routes.config);
      return;
    }

    baseUrl = 'http://$serverIp/api/v1';
    print("Base URL initialized: $baseUrl");
  }

  Future<void> reinitialize() async {
    await _initializeBaseUrl();
  }

  Future<void> initialize() async {
    try {
      for (int i = 0; i < 3; i++) {
        try {
          final response = await http.get(Uri.parse(baseUrl));
          if (response.statusCode == 200) {
            NotificationService.showSuccess(
              title: "Success",
              message: "Server connected successfully.",
            );
            return;
          }
        } catch (_) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      throw Exception("Failed to connect to server after multiple attempts.");
    } catch (e) {
      throw Exception("Error initializing API service: $e");
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final payload = _decodeBody(response.body);

    if (response.statusCode == 403 && payload.containsKey('license')) {
      final licensePayload = payload['license'] is Map<String, dynamic>
          ? payload['license'] as Map<String, dynamic>
          : payload['license'] is Map
              ? Map<String, dynamic>.from(payload['license'] as Map)
              : payload;

      _licenseService.enforcePayload(licensePayload);
      return payload;
    }

    if (response.statusCode >= 400 && !payload.containsKey('message')) {
      return {
        'message': 'Request failed with status ${response.statusCode}.',
      };
    }

    return payload;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return {};
    }

    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return {'message': body};
    }

    return {'message': body};
  }
}
