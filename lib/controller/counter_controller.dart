import 'package:get/get.dart';

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
