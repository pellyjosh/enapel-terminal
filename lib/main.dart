import 'dart:convert';
import 'dart:io';

import 'package:enapel/controller/connectivity_controller.dart';
import 'package:enapel/controller/pos_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/screens/desktop/dashboard/supermarket/sales.dart';
import 'package:enapel/services/window_protocol.dart';
import 'package:enapel/controller/shortcut_controller.dart';
import 'package:enapel/widget/settings/shortcut_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  bool windowManagerInitialized = false;
  try {
    await windowManager.ensureInitialized();
    windowManagerInitialized = true;
  } catch (e) {
    print("Window manager initialization failed: $e");
  }
  
  final isPrimaryWindow = args.isEmpty || args.firstOrNull != "multi_window";

  if (isPrimaryWindow) {
    await KeyStorage.init(); // Initialize storage only for primary window
    Get.put(ConnectivityController()); // Initialize connectivity for primary
    
    // 🚀 Master Window Initialization
    final databaseMode = KeyStorage.getString('database_mode') ?? 'local';
    Get.put(PosController(databaseMode));
    WindowProtocol.initializeMaster();
  } else {
    // 🚀 Mirror Window Initialization
    if (args.length > 2) {
      try {
        final Map<String, dynamic> argData = jsonDecode(args[2]);
        if (argData.containsKey('storage')) {
          KeyStorage.initMirror(Map<String, dynamic>.from(argData['storage']));
        }
      } catch (e) {
        print("Error initializing KeyStorage Mirror: $e");
      }
    }
  }
  
  runApp(MyApp(args));

  // Desktop-specific configurations for window management
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    if (windowManagerInitialized) {
      WindowOptions windowOptions = WindowOptions(
        size: isPrimaryWindow ? const Size(1200, 800) : null,
        minimumSize: isPrimaryWindow ? const Size(1200, 800) : null,
        center: true,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        if (!isPrimaryWindow) {
          await windowManager.maximize();
          try {
            await windowManager.setFullScreen(true);
          } catch (e) {
            print("Failed to set full screen: $e");
          }
        } else {
          await windowManager.setPreventClose(false);
        }
        await windowManager.show();
        await windowManager.focus();
      });

      if (isPrimaryWindow) {
        windowManager.addListener(PrimaryWindowListener());
      }
    }
  }
}

class PrimaryWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    print("Primary window closing. Exiting entire application...");
    exit(0);
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
          serverIp: argData['serverIp'],
          userToken: argData['userToken'],
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
    final sc = Get.put(ShortcutController());

    return Obx(() {
      final Map<ShortcutActivator, VoidCallback> bindings = {};
      sc.shortcuts.forEach((key, value) {
        if (key == 'next_window') {
          bindings[SingleActivator(value)] = () => WindowProtocol.invokeMaster('nextWindow', null);
        } else if (key == 'prev_window') {
          bindings[SingleActivator(value)] = () => WindowProtocol.invokeMaster('prevWindow', null);
        } else if (key == 'open_terminal') {
          bindings[SingleActivator(value)] = () => WindowProtocol.invokeMaster('openNewTerminal', null);
        }
      });

      return CallbackShortcuts(
        bindings: bindings,
        child: PlatformMenuBar(
          menus: [
            PlatformMenu(
              label: 'enapel',
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'About Enapel',
                      onSelected: () {},
                    ),
                  ],
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Configure Shortcuts...',
                      onSelected: () => Get.dialog(const ShortcutConfigDialog()),
                    ),
                  ],
                ),
              ],
            ),
            PlatformMenu(
              label: 'Terminal',
              menus: [
                PlatformMenuItem(
                  label: 'Open New Terminal (${sc.getLabel('open_terminal')})',
                  onSelected: () => WindowProtocol.invokeMaster('openNewTerminal', null),
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Next Terminal',
                      onSelected: () => WindowProtocol.invokeMaster('nextWindow', null),
                    ),
                    PlatformMenuItem(
                      label: 'Previous Terminal',
                      onSelected: () => WindowProtocol.invokeMaster('prevWindow', null),
                    ),
                  ],
                ),
              ],
            ),
          ],
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.initial,
            getPages: getPages,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
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
          ),
        ),
      );
    });
  }
}

class SecondaryWindow extends StatefulWidget {
  final int windowID;
  final String databaseMode;
  final String? serverIp;
  final String? userToken;

  const SecondaryWindow({
    super.key,
    required this.windowID,
    required this.databaseMode,
    this.serverIp,
    this.userToken,
  });

  @override
  State<SecondaryWindow> createState() => _SecondaryWindowState();
}

class _SecondaryWindowState extends State<SecondaryWindow> {
  @override
  void initState() {
    super.initState();
    WindowProtocol.setWindowId(widget.windowID);
  }

  @override
  void dispose() {
    // Notify master that this window is closing to clean up tracking
    WindowProtocol.invokeMaster('removeWindowId', widget.windowID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('database mode: ${widget.databaseMode}');
    
    // Inject server details since SharedPreferences doesn't work in multi-window
    Get.put(ConnectivityController(injectedServerIp: widget.serverIp));

    final sc = Get.put(ShortcutController());

    return Obx(() {
      final Map<ShortcutActivator, VoidCallback> bindings = {};
      sc.shortcuts.forEach((key, value) {
        if (key == 'next_window') {
          bindings[SingleActivator(value)] = () => WindowProtocol.invokeMaster('nextWindow', null);
        } else if (key == 'prev_window') {
          bindings[SingleActivator(value)] = () => WindowProtocol.invokeMaster('prevWindow', null);
        } else if (key == 'open_terminal') {
          bindings[SingleActivator(value)] = () => WindowProtocol.invokeMaster('openNewTerminal', null);
        }
      });

      return CallbackShortcuts(
        bindings: bindings,
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PointOfSalesScreen(
              databaseMode: widget.databaseMode,
              serverIp: widget.serverIp,
              userToken: widget.userToken,
              windowId: widget.windowID,
            ),
          ),
        ),
      );
    });
  }
}
