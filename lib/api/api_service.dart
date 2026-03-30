import 'dart:convert';
import 'dart:io';

import 'package:enapel/controller/connectivity_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/services/license_service.dart';
import 'package:enapel/utils/notification.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService {
  late String baseUrl;
  final String? injectedServerIp;
  final String? injectedUserToken;
  final TerminalLicenseService _licenseService = TerminalLicenseService();
  final ConnectivityController _connectivityController = Get.find<ConnectivityController>();

  ApiService({this.injectedServerIp, this.injectedUserToken}) {
    _initializeBaseUrl();
  }
  String? _getToken() {
    return injectedUserToken ?? KeyStorage.getString('userToken');
  }

  void _initializeBaseUrl() {
    String? serverIp = injectedServerIp ??
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
    _initializeBaseUrl();
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
            _connectivityController.setServerUp();
            return;
          }
        } catch (_) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      throw Exception("Failed to connect to server after multiple attempts.");
    } catch (e) {
      _connectivityController.setServerDown();
      throw Exception("Error initializing API service: $e");
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      _connectivityController.setServerUp();
      return _handleResponse(response);
    } catch (e) {
      _handleConnectionError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));
      _connectivityController.setServerUp();
      return _handleResponse(response);
    } catch (e) {
      _handleConnectionError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      _connectivityController.setServerUp();
      return _handleResponse(response);
    } catch (e) {
      _handleConnectionError(e);
      rethrow;
    }
  }

  void _handleConnectionError(dynamic e) {
    if (e is SocketException || e is http.ClientException || e is HttpException) {
      _connectivityController.setServerDown();
    }
    print("API Connection Error: $e");
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

    if (response.statusCode >= 500) {
      // Internal server error, maybe server is up but broken?
      // We could also trigger server down here if desired.
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

