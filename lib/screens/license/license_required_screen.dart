import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/services/license_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LicenseRequiredScreen extends StatefulWidget {
  const LicenseRequiredScreen({super.key});

  @override
  State<LicenseRequiredScreen> createState() => _LicenseRequiredScreenState();
}

class _LicenseRequiredScreenState extends State<LicenseRequiredScreen> {
  final TerminalLicenseService _licenseService = TerminalLicenseService();
  bool _isRefreshing = false;
  Map<String, dynamic> _payload = {};

  @override
  void initState() {
    super.initState();
    _payload = _initialPayload();
  }

  Map<String, dynamic> _initialPayload() {
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      return args;
    }

    if (args is Map) {
      return Map<String, dynamic>.from(args);
    }

    return _licenseService.getCachedStatus() ??
        {
          'message': 'License validation failed.',
          'reason': 'license_invalid',
          'valid': false,
        };
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    final isValid = await _licenseService.ensureValid(
      refresh: true,
      redirect: false,
    );
    final updatedPayload = _licenseService.getCachedStatus() ?? _payload;

    if (!mounted) {
      return;
    }

    if (isValid) {
      Get.offAllNamed(Routes.initial);
      return;
    }

    setState(() {
      _payload = updatedPayload;
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final message =
        _payload['message']?.toString() ?? 'License validation failed.';
    final reason = _payload['reason']?.toString() ?? 'license_invalid';
    final expiryDate = _payload['expiry_date']?.toString();
    final cloudApiBaseUrl = _payload['cloud_api_base_url']?.toString();
    final serverIp =
        KeyStorage.getString('serverIp') ?? KeyStorage.getString('server_ip');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFFDECEC),
                      child: Icon(
                        Icons.lock_outline,
                        color: Color(0xFFCC3344),
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Valid License Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475467),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(label: 'Reason', value: reason),
                  if (expiryDate != null && expiryDate.isNotEmpty)
                    _InfoRow(label: 'Expiry', value: expiryDate),
                  if (cloudApiBaseUrl != null && cloudApiBaseUrl.isNotEmpty)
                    _InfoRow(label: 'Cloud URL', value: cloudApiBaseUrl),
                  if (serverIp != null && serverIp.isNotEmpty)
                    _InfoRow(label: 'Server IP', value: serverIp),
                  FutureBuilder<bool>(
                    future: ConnectionHelper.isServerConnection(),
                    builder: (context, snapshot) {
                      final isServerMode = snapshot.data ?? false;
                      final helpText = isServerMode
                          ? 'Activate or renew the license on the local enapel-server, then refresh this screen.'
                          : 'Update the configured license key, then refresh this screen.';

                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          helpText,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            height: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRefreshing ? null : _refreshStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isRefreshing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Refresh License Status'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.offAllNamed(Routes.config),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Open Configuration'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
          ),
        ],
      ),
    );
  }
}
