import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:enapel/api/api_service.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openLocalConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'enapel.sqlite');
    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      print('✅ Database exists at: $dbPath');
    } else {
      print('❌ Database does not exist, creating a new one at: $dbPath');
    }

    return NativeDatabase(dbFile);
  });
}

Future<dynamic> openServerConnection() async {
  String? serverIp =
      KeyStorage.getString('server_ip') ?? KeyStorage.getString('serverIp');

  if (serverIp == null) {
    throw Exception("Server IP is not configured.");
  }

  ApiService apiService = ApiService();

  await apiService.initialize();
  print("Connected to server at: $serverIp");

  return apiService;
}
