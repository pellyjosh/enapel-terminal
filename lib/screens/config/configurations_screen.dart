import 'dart:convert';

import 'package:enapel/api/config.dart';
import 'package:enapel/controller/users_controller.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/database/storage/config_storage.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/services/license_service.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/utils/notification.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({Key? key}) : super(key: key);

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedDatabase = 'local';
  final TextEditingController _serverIpController = TextEditingController();
  final TextEditingController _licenseKeyController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  bool _isTestingConnection = false;
  bool _isSettingUpDatabase = false;
  String? _connectionStatus;
  String? _setupStatus;
  final TerminalLicenseService _licenseService = TerminalLicenseService();

  // GetX Controller
  late UserController userController;

  @override
  void initState() {
    super.initState();
    final database = EnapelDatabase(openLocalConnection());
    userController = UserController(database);
    _selectedDatabase = KeyStorage.getString('database_mode') ?? 'local';
    _serverIpController.text = KeyStorage.getString('serverIp') ??
        KeyStorage.getString('server_ip') ??
        '';
    _licenseKeyController.text = KeyStorage.getString('licenseKey') ?? '';
  }

  Future<void> _setupLocalDatabase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSettingUpDatabase = true;
    });

    try {
      final licenseKey = _licenseKeyController.text.trim().toUpperCase();
      final licensePayload =
          await _licenseService.validateLocalLicenseKey(licenseKey);

      if (licensePayload['valid'] != true) {
        setState(() {
          _setupStatus = licensePayload['message']?.toString() ??
              'License validation failed.';
        });
        NotificationService.showError(
          title: "License Error",
          message: _setupStatus!,
        );
        return;
      }

      await KeyStorage.saveString('licenseKey', licenseKey);
      await _licenseService.cacheStatus(licensePayload);

      final adminName = _adminNameController.text.trim();
      final adminEmail = _adminEmailController.text.trim();
      final adminPassword = _adminPasswordController.text.trim();

      await userController.createSuperUser(
        adminName,
        adminEmail,
        adminPassword,
      );

      await _saveConfiguration();
      setState(() {
        _setupStatus = "Setup Successful!";
      });
    } catch (e) {
      setState(() {
        _setupStatus = "Setup Failed: $e";
      });
      NotificationService.showError(
        title: "Error",
        message: e.toString(),
      );
    } finally {
      setState(() {
        _isSettingUpDatabase = false;
      });
    }
  }

  Future<void> _testServerConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
    });

    try {
      final serverIp = _serverIpController.text.trim();
      final response = await http.get(
        Uri.parse(
            'http://$serverIp/api/${Config.version}/license/status?refresh=1'),
        headers: {'accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      final payload = Map<String, dynamic>.from(jsonDecode(response.body));

      if (response.statusCode == 200 && payload['valid'] == true) {
        await KeyStorage.saveString('serverIp', serverIp);
        await KeyStorage.saveString('server_ip', serverIp);
        await _licenseService.cacheStatus(payload);
        await _saveConfiguration();
        setState(() {
          _connectionStatus = "Connection Successful!";
        });
      } else {
        setState(() {
          _connectionStatus = payload['message']?.toString() ??
              "Connection Failed: the server license is invalid.";
        });
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      setState(() {
        _connectionStatus = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      await ConfigStorage.setConfigured(true, _selectedDatabase);
    } catch (e) {
      print("Error saving configuration: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/desktop/signin/bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Container(
            width: Get.size.width * 0.60,
            height: Get.size.height * 0.80,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Database Source:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      title: const Text('Local Database'),
                      leading: Radio<String>(
                        value: 'local',
                        groupValue: _selectedDatabase,
                        onChanged: (value) {
                          setState(() {
                            _selectedDatabase = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Server Database'),
                      leading: Radio<String>(
                        value: 'server',
                        groupValue: _selectedDatabase,
                        onChanged: (value) {
                          setState(() {
                            _selectedDatabase = value!;
                          });
                        },
                      ),
                    ),
                    if (_selectedDatabase == 'server') ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Enter Server IP Address',
                        hintText: 'e.g., 192.168.1.100',
                        labelTextColor: AppColor.black,
                        controller: _serverIpController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Server IP is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isTestingConnection
                            ? null
                            : () async {
                                await _testServerConnection();
                                if (_connectionStatus ==
                                    "Connection Successful!") {
                                  Get.offNamed(Routes.initial);
                                }
                              },
                        child: _isTestingConnection
                            ? const CircularProgressIndicator()
                            : const Text('Test Connection'),
                      ),
                      if (_connectionStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _connectionStatus!,
                            style: TextStyle(
                              color:
                                  _connectionStatus == "Connection Successful!"
                                      ? Colors.green
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ] else if (_selectedDatabase == 'local') ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Enter License Key',
                        hintText: 'e.g., ABCD-1234-EFGH-5678',
                        labelTextColor: AppColor.black,
                        controller: _licenseKeyController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lincense key is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Super Admin Name',
                        hintText: 'e.g., John Doe',
                        labelTextColor: AppColor.black,
                        controller: _adminNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Admin name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Super Admin Email',
                        hintText: 'e.g., admin@example.com',
                        labelTextColor: AppColor.black,
                        controller: _adminEmailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Admin email is required.';
                          }
                          // else if (!RegExp(
                          //         r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
                          //     .hasMatch(value)) {
                          //   return 'Enter a valid email address.';
                          // }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Super Admin Password',
                        hintText: 'Enter a strong password',
                        labelTextColor: AppColor.black,
                        controller: _adminPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Admin password is required.';
                          }
                          // else if (value.length < 8) {
                          //   return 'Password must be at least 8 characters long.';
                          // }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isSettingUpDatabase
                            ? null
                            : () async {
                                await _setupLocalDatabase();
                                if (_setupStatus == "Setup Successful!") {
                                  Get.offNamed(Routes.initial);
                                }
                              },
                        child: _isSettingUpDatabase
                            ? const CircularProgressIndicator()
                            : const Text('Setup Local Database'),
                      ),
                      if (_setupStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _setupStatus!,
                            style: TextStyle(
                              color: _setupStatus == "Setup Successful!"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
