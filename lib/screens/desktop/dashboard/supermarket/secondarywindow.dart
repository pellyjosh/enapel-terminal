import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enapel/controller/counter_controller.dart';
import 'package:window_manager/window_manager.dart';

class SecondaryWindow extends StatelessWidget {
  SecondaryWindow({super.key});
  final arguments = Get.arguments;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secondary Window')),
      body: Center(
        child: WindowCounter(), // Independent state for this window
      ),
    );
  }
}

class WindowCounter extends StatelessWidget {
  // Each window gets its own controller for state
  final CounterController counterController = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(
          () => Text(
            "${counterController.count}",
            style: const TextStyle(fontSize: 40),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: counterController.decrement,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: counterController.increment,
            ),
          ],
        ),
      ],
    );
  }
}

class CounterController extends GetxController {
  // Using GetX to manage the counter state independently
  var count = 0.obs;

  void increment() {
    count++;
  }

  void decrement() {
    count--;
  }
}
