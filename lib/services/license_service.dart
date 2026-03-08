import 'dart:async';
import 'dart:convert';

import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/route/route.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TerminalLicenseService {
  static const String defaultCloudApiBaseUrl =
      'https://cloud.enapel.com/api/v1';
  static const String _cachedStatusKey = 'license_status';
  static const String _localLicenseKeyStorage = 'licenseKey';
  static const Duration _requestTimeout = Duration(seconds: 10);

  Future<bool> ensureValid({
    bool refresh = false,
    bool redirect = true,
  }) async {
    final payload = await checkCurrentLicense(refresh: refresh);
    final normalized = _normalizePayload(payload);

    await cacheStatus(normalized);

    if (normalized['valid'] == true) {
      return true;
    }

    if (redirect) {
      redirectToLicenseRequired(normalized);
    }

    return false;
  }

  Future<Map<String, dynamic>> checkCurrentLicense({
    bool refresh = false,
  }) async {
    final isServerMode = await ConnectionHelper.isServerConnection();

    if (isServerMode) {
      return checkServerLicense(refresh: refresh);
    }

    final licenseKey = KeyStorage.getString(_localLicenseKeyStorage);
    if (licenseKey == null || licenseKey.isEmpty) {
      return _invalidPayload(
        reason: 'license_missing',
        message: 'No local license key has been configured.',
        configured: false,
      );
    }

    return validateLocalLicenseKey(licenseKey);
  }

  Future<Map<String, dynamic>> checkServerLicense({
    bool refresh = false,
  }) async {
    final serverIp = _serverIp();

    if (serverIp == null || serverIp.isEmpty) {
      return _invalidPayload(
        reason: 'server_not_configured',
        message: 'Server IP is not configured.',
        configured: false,
      );
    }

    final refreshQuery = refresh ? '?refresh=1' : '';
    final uri =
        Uri.parse('http://$serverIp/api/v1/license/status$refreshQuery');

    try {
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      ).timeout(_requestTimeout);

      final payload = _decodeResponse(response.body);
      payload['server_ip'] = serverIp;

      if (response.statusCode == 200) {
        return _normalizePayload(payload);
      }

      return _normalizePayload({
        ...payload,
        'valid': false,
        'configured': payload['configured'] ?? true,
        'reason': payload['reason'] ?? 'license_status_unavailable',
        'message': payload['message'] ??
            'Could not determine the local server license status.',
      });
    } on TimeoutException {
      return _invalidPayload(
        reason: 'server_timeout',
        message: 'The local server took too long to respond.',
        configured: true,
        extras: {'server_ip': serverIp},
      );
    } catch (_) {
      return _invalidPayload(
        reason: 'server_unreachable',
        message: 'Could not reach the local server license service.',
        configured: true,
        extras: {'server_ip': serverIp},
      );
    }
  }

  Future<Map<String, dynamic>> validateLocalLicenseKey(
      String licenseKey) async {
    final normalizedKey = licenseKey.trim().toUpperCase();
    final cloudApiBaseUrl = currentCloudApiBaseUrl();

    if (normalizedKey.isEmpty) {
      return _invalidPayload(
        reason: 'license_missing',
        message: 'License key is required.',
        configured: false,
      );
    }

    final uri = Uri.parse('$cloudApiBaseUrl/license/status/$normalizedKey');

    try {
      final response = await http.get(
        uri,
        headers: {'accept': 'application/json'},
      ).timeout(_requestTimeout);

      final payload = _decodeResponse(response.body);
      payload['configured'] = true;
      payload['license_key'] = normalizedKey;
      payload['source'] = 'cloud';
      payload['cloud_api_base_url'] = cloudApiBaseUrl;

      final isExpired = payload['is_expired'] == true || _isExpired(payload);
      final isActive = payload['status'] == 'active';
      final isValid = payload['valid'] == true && isActive && !isExpired;

      return _normalizePayload({
        ...payload,
        'valid': isValid,
        'reason': isValid
            ? 'ok'
            : isExpired
                ? 'license_expired'
                : isActive
                    ? payload['reason'] ?? 'license_invalid'
                    : 'license_inactive',
        'message': isValid
            ? payload['message'] ?? 'License is valid.'
            : isExpired
                ? 'This license has expired.'
                : payload['message'] ?? 'This license is not active.',
      });
    } on TimeoutException {
      return _invalidPayload(
        reason: 'cloud_timeout',
        message: 'The licensing server took too long to respond.',
        configured: true,
        extras: {
          'license_key': normalizedKey,
          'source': 'cloud',
          'cloud_api_base_url': cloudApiBaseUrl,
        },
      );
    } catch (_) {
      return _invalidPayload(
        reason: 'cloud_unreachable',
        message: 'Could not reach the licensing server.',
        configured: true,
        extras: {
          'license_key': normalizedKey,
          'source': 'cloud',
          'cloud_api_base_url': cloudApiBaseUrl,
        },
      );
    }
  }

  Future<void> cacheStatus(Map<String, dynamic> payload) async {
    await KeyStorage.saveMap(_cachedStatusKey, _normalizePayload(payload));
  }

  Map<String, dynamic>? getCachedStatus() {
    return KeyStorage.getMap(_cachedStatusKey);
  }

  String currentCloudApiBaseUrl() {
    return normalizeCloudApiBaseUrl(
      // Packaged into the app build. Example:
      // flutter build apk --dart-define=ENAPEL_CLOUD_URL=https://cloud.example.com
      const String.fromEnvironment(
        'ENAPEL_CLOUD_URL',
        defaultValue: defaultCloudApiBaseUrl,
      ),
    );
  }

  void enforcePayload(Map<String, dynamic> payload) {
    final normalized = _normalizePayload(payload);
    unawaited(cacheStatus(normalized));
    redirectToLicenseRequired(normalized);
  }

  void redirectToLicenseRequired(Map<String, dynamic> payload) {
    if (Get.currentRoute == Routes.licenseRequired) {
      return;
    }

    Get.offAllNamed(Routes.licenseRequired, arguments: payload);
  }

  Map<String, dynamic> _normalizePayload(Map<String, dynamic> payload) {
    final normalized = Map<String, dynamic>.from(payload);
    final expired = normalized['is_expired'] == true || _isExpired(normalized);

    if (expired) {
      normalized['valid'] = false;
      normalized['reason'] = normalized['reason'] ?? 'license_expired';
      normalized['message'] =
          normalized['message'] ?? 'This license has expired.';
    }

    normalized['valid'] = normalized['valid'] == true;
    normalized['configured'] =
        normalized['configured'] ?? normalized['license_configured'] ?? false;
    normalized['reason'] = normalized['reason'] ??
        (normalized['valid'] == true ? 'ok' : 'license_invalid');
    normalized['message'] = normalized['message'] ??
        (normalized['valid'] == true
            ? 'License is valid.'
            : 'License validation failed.');

    return normalized;
  }

  bool _isExpired(Map<String, dynamic> payload) {
    final expiryDate = payload['expiry_date'];
    if (expiryDate is! String || expiryDate.isEmpty) {
      return false;
    }

    try {
      final expiry = DateTime.parse(expiryDate).toUtc();
      return !DateTime.now().toUtc().isBefore(expiry);
    } catch (_) {
      return false;
    }
  }

  String? _serverIp() {
    return KeyStorage.getString('serverIp') ??
        KeyStorage.getString('server_ip');
  }

  String normalizeCloudApiBaseUrl(String baseUrl) {
    var normalized = baseUrl.trim();

    if (normalized.isEmpty) {
      normalized = defaultCloudApiBaseUrl;
    }

    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }

    normalized = normalized.replaceAll(RegExp(r'/+$'), '');

    if (normalized.endsWith('/api/v1')) {
      return normalized;
    }

    if (normalized.endsWith('/api')) {
      return '$normalized/v1';
    }

    return '$normalized/api/v1';
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);
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

  Map<String, dynamic> _invalidPayload({
    required String reason,
    required String message,
    required bool configured,
    Map<String, dynamic> extras = const {},
  }) {
    return {
      'valid': false,
      'configured': configured,
      'reason': reason,
      'message': message,
      ...extras,
    };
  }
}
