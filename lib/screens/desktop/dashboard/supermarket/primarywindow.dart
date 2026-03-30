import 'dart:convert';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class PrimaryWindow extends StatelessWidget {
  const PrimaryWindow({super.key, required int windowID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primary Window')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final databaseMode = KeyStorage.getString('database_mode') ?? 'local';
            final serverIp = KeyStorage.getString('serverIp') ?? 
                             KeyStorage.getString('server_ip') ?? 
                             '127.0.0.1:8001';
            final userToken = KeyStorage.getString('userToken') ?? '';

            // Open a new window with full state injection
            final window = await DesktopMultiWindow.createWindow(jsonEncode({
              'args1': 'Sub window',
              'databaseMode': databaseMode,
              'serverIp': serverIp,
              'userToken': userToken,
              'storage': {
                'database_mode': databaseMode,
                'serverIp': serverIp,
                'server_ip': serverIp,
                'userToken': userToken,
                'license_status': KeyStorage.getMap('license_status'),
                'active_module': KeyStorage.getString('active_module'),
                'isLocked': KeyStorage.getBool('isLocked'),
              }
            }));

            window
              ..setFrame(const Offset(0, 0) & const Size(1200, 800))
              ..center()
              ..setTitle("Enapel POS - Terminal ${window.windowId}")
              ..show();
          },
          child: const Text(
            "Open Secondary Window",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
