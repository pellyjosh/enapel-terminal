import 'package:enapel/controller/shortcut_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ShortcutConfigDialog extends StatelessWidget {
  const ShortcutConfigDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortcutController>();
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF1E1E1E),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Configure Shortcuts',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Assign Function keys (F1-F12) to manage terminal windows.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildShortcutItem('Open New Terminal', 'open_terminal', controller),
                    const Divider(color: Colors.white10, height: 24),
                    _buildShortcutItem('Next Terminal', 'next_window', controller),
                    const Divider(color: Colors.white10, height: 24),
                    _buildShortcutItem('Previous Terminal', 'prev_window', controller),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save & Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutItem(String label, String action, ShortcutController controller) {
    return Obx(() {
      final currentKey = controller.shortcuts[action]!;
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          DropdownButton<LogicalKeyboardKey>(
            dropdownColor: const Color(0xFF2D2D2D),
            value: currentKey,
            underline: const SizedBox(),
            items: _availableKeys.map((key) {
              return DropdownMenuItem(
                value: key,
                child: Text(
                  key.debugName ?? key.keyLabel,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (newKey) {
              if (newKey != null) {
                controller.updateShortcut(action, newKey);
              }
            },
          ),
        ],
      );
    });
  }

  static const List<LogicalKeyboardKey> _availableKeys = [
    LogicalKeyboardKey.f1,
    LogicalKeyboardKey.f2,
    LogicalKeyboardKey.f3,
    LogicalKeyboardKey.f4,
    LogicalKeyboardKey.f5,
    LogicalKeyboardKey.f6,
    LogicalKeyboardKey.f7,
    LogicalKeyboardKey.f8,
    LogicalKeyboardKey.f9,
    LogicalKeyboardKey.f10,
    LogicalKeyboardKey.f11,
    LogicalKeyboardKey.f12,
  ];
}
