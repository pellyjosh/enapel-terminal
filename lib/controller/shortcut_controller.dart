import 'package:enapel/database/storage/key_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ShortcutController extends GetxController {
  // Mapping of action to LogicalKeyboardKey
  // Default values
  final RxMap<String, LogicalKeyboardKey> shortcuts = {
    'open_terminal': LogicalKeyboardKey.f5,
    'next_window': LogicalKeyboardKey.f12,
    'prev_window': LogicalKeyboardKey.f11,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _loadShortcuts();
  }

  void _loadShortcuts() {
    final Map<String, dynamic>? saved = KeyStorage.getMap('custom_shortcuts');
    if (saved != null) {
      saved.forEach((key, value) {
        final keyboardKey = _parseKey(value.toString());
        if (keyboardKey != null) {
          shortcuts[key] = keyboardKey;
        }
      });
    }
  }

  void updateShortcut(String action, LogicalKeyboardKey key) {
    shortcuts[action] = key;
    _saveShortcuts();
  }

  void _saveShortcuts() {
    final Map<String, String> toSave = {};
    shortcuts.forEach((key, value) {
      toSave[key] = value.debugName ?? value.keyLabel;
    });
    KeyStorage.saveMap('custom_shortcuts', toSave);
  }

  LogicalKeyboardKey? _parseKey(String label) {
    if (label.startsWith('F')) {
      switch (label) {
        case 'F1': return LogicalKeyboardKey.f1;
        case 'F2': return LogicalKeyboardKey.f2;
        case 'F3': return LogicalKeyboardKey.f3;
        case 'F4': return LogicalKeyboardKey.f4;
        case 'F5': return LogicalKeyboardKey.f5;
        case 'F6': return LogicalKeyboardKey.f6;
        case 'F7': return LogicalKeyboardKey.f7;
        case 'F8': return LogicalKeyboardKey.f8;
        case 'F9': return LogicalKeyboardKey.f9;
        case 'F10': return LogicalKeyboardKey.f10;
        case 'F11': return LogicalKeyboardKey.f11;
        case 'F12': return LogicalKeyboardKey.f12;
      }
    }
    return null;
  }

  String getLabel(String action) {
    final key = shortcuts[action];
    if (key == null) return 'None';
    return key.debugName ?? key.keyLabel;
  }
}
