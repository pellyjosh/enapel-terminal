import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:enapel/api/config.dart';
import 'package:enapel/controller/pos_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WindowProtocol {
  static VoidCallback? onOpenTerminalRequest;

  static PosController get posController => Get.find<PosController>();

  static int _currentWindowId = -1;
  static DateTime _lastNavigationTime = DateTime.fromMillisecondsSinceEpoch(0);

  static void setWindowId(int id) {
    _currentWindowId = id;
  }

  static void initializeMaster() {
    _currentWindowId = 0;
    DesktopMultiWindow.setMethodHandler((MethodCall call, int fromWindowId) async {
      return await _handleMethodCall(call, fromWindowId);
    });
  }

  static Future<dynamic> _handleMethodCall(MethodCall call, int fromWindowId) async {
    print("MASTER: Handling method '${call.method}' from window $fromWindowId");
    
    switch (call.method) {
      case 'searchProducts':
        final String query = call.arguments.toString();
        await posController.products(query);
        final data = posController.productData.map((p) => p.toJson()).toList();
        return data; // Return raw List<Map> instead of json String

      case 'generatePosCode':
        posController.generatePosCode(); 
        await Future.delayed(const Duration(milliseconds: 100));
        return posController.posCode.value;

      case 'checkout':
        final Map<String, dynamic> orderData = Map<String, dynamic>.from(call.arguments);
        final response = await posController.apiService.post(Config.checkOut, orderData);
        return response; // Return raw Map

      case 'savePendingReceipt':
        final Map<String, dynamic> payload = Map<String, dynamic>.from(call.arguments);
        final response = await posController.apiService.post(Config.checkOut, payload);
        return response;

      case 'getReceiptDetails':
        final String receiptNumber = call.arguments.toString();
        final response = await posController.apiService.get('receipts/$receiptNumber');
        return response;

      case 'focusWindow':
        final int targetId = int.tryParse(call.arguments.toString()) ?? 0;
        try {
          WindowController.fromWindowId(targetId).show();
          return true;
        } catch (e) {
          print("Error switching to window $targetId: $e");
          return false;
        }

      case 'nextWindow':
        try {
          final now = DateTime.now();
          if (now.difference(_lastNavigationTime).inMilliseconds < 500) {
            return false;
          }
          _lastNavigationTime = now;

          final List<int> ids = List<int>.from(posController.activeWindowIds);
          if (ids.isEmpty) return false;
          ids.sort();
          
          final int currentIndex = ids.indexOf(fromWindowId);
          if (currentIndex == -1) {
            print("MASTER: Window $fromWindowId not found in active list $ids");
            return false;
          }
          
          final int nextIndex = (currentIndex + 1) % ids.length;
          print("MASTER: Switching from $fromWindowId to ${ids[nextIndex]}");
          WindowController.fromWindowId(ids[nextIndex]).show();
          return true;
        } catch (e) {
          print("Error switching to next window: $e");
          return false;
        }

      case 'prevWindow':
        try {
          final now = DateTime.now();
          if (now.difference(_lastNavigationTime).inMilliseconds < 500) {
            return false;
          }
          _lastNavigationTime = now;

          final List<int> ids = List<int>.from(posController.activeWindowIds);
          if (ids.isEmpty) return false;
          ids.sort();
          
          final int currentIndex = ids.indexOf(fromWindowId);
          if (currentIndex == -1) return false;
          
          final int prevIndex = (currentIndex - 1 + ids.length) % ids.length;
          print("MASTER: Switching from $fromWindowId to ${ids[prevIndex]}");
          WindowController.fromWindowId(ids[prevIndex]).show();
          return true;
        } catch (e) {
          print("Error switching to prev window: $e");
          return false;
        }

      case 'removeWindowId':
        final int id = int.tryParse(call.arguments.toString()) ?? -1;
        if (id != -1) {
          posController.removeWindowId(id);
        }
        return true;

      case 'openNewTerminal':
        onOpenTerminalRequest?.call();
        return true;
      
      case 'ping':
        return "pong from master";

      default:
        return "Method not implemented";
    }
  }

  static Future<dynamic> invokeMaster(String method, dynamic arguments) async {
    try {
      if (_currentWindowId == 0) {
        // Avoid self-invocation crash on macOS (single process)
        return await _handleMethodCall(MethodCall(method, arguments), 0);
      }
      
      print("MIRROR: Invoking master method '$method' with args: $arguments");
      final result = await DesktopMultiWindow.invokeMethod(0, method, arguments);
      return result;
    } catch (e) {
      print("MIRROR ERROR: Failed to invoke master: $e");
      return null;
    }
  }
}
