import 'dart:convert';
import 'dart:io';

import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/screens/desktop/dashboard/supermarket/sales.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart'; // For desktop window constraints

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final isPrimaryWindow = args.isEmpty || args.firstOrNull != "multi_window";
  if (isPrimaryWindow) {
    await KeyStorage.init();
  }
  runApp(MyApp(args));

  // Desktop-specific configurations for window management
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      const initialSize = Size(1200, 800);
      appWindow.size = initialSize;
      appWindow.minSize = const Size(1200, 800); // Minimum window size
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class MyApp extends StatelessWidget {
  final List<String> args;
  const MyApp(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (args.firstOrNull == "multi_window") {
        final Map<String, dynamic> argData =
            args.length > 2 ? jsonDecode(args[2]) : {};

        return SecondaryWindow(
          windowID: args.length > 1 ? int.tryParse(args[1].toString()) ?? 0 : 0,
          databaseMode: argData['databaseMode'] ?? 'local',
        );
      } else {
        return const PrimaryWindow(windowID: 0);
      }
    } else {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.initial,
        getPages: getPages,
      );
    }
  }
}

class PrimaryWindow extends StatelessWidget {
  final int windowID;
  const PrimaryWindow({super.key, required this.windowID});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.initial,
      getPages: getPages,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Enforce minimum width of 800px
            if (width < 800) {
              return Center(
                child: Container(
                  width: 800,
                  height: constraints.maxHeight,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      maxWidth: 800,
                      maxHeight: constraints.maxHeight,
                      child: child,
                    ),
                  ),
                ),
              );
            }
            return child!;
          },
        );
      },
    );
  }
}

class SecondaryWindow extends StatelessWidget {
  final int windowID;
  final String databaseMode;

  const SecondaryWindow({
    super.key,
    required this.windowID,
    required this.databaseMode,
  });

  @override
  Widget build(BuildContext context) {
    print('database mode: $databaseMode');
    print('I got here<><>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PointOfSalesScreen(
          databaseMode: databaseMode,
        ),
      ),
    );
  }
}
