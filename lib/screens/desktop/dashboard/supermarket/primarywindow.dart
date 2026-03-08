import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class PrimaryWindow extends StatelessWidget {
  const PrimaryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primary Window')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Open a new window independently when button is pressed
            DesktopMultiWindow.createWindow(
                jsonEncode({'args': 'open_secondary'})).then((value) {
              value
                ..setFrame(const Offset(0, 0) & const Size(1280, 720))
                ..center()
                ..setTitle("Secondary Window")
                ..show();
            });
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
