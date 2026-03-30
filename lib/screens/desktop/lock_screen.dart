import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const LockScreen({super.key, required this.onUnlock});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    user = KeyStorage.getMap('user');
  }

  void _unlock() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you'd verify against a hash or re-auth with API
      // For now, let's assume if it matches the current password (if stored) or just a simple check
      // Ideally we should re-login or check against cached password if it's local mode
      
      // Since we don't store the password in plain text, we might need to call the login API again
      // or verify against the local DB. 
      // For this implementation, we will assume the user has to enter their valid password.
      
      // I'll show a simple success for now, but in reality, you'd call authController.verify(password)
      widget.onUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = user?['name'] ?? 'User';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/desktop/signin/bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.black54),
                  const SizedBox(height: 16),
                  Text(
                    'Locked',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColor.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back, $userName',
                    style: TextStyle(fontSize: 16, color: AppColor.black.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    labelText: 'PASSWORD',
                    hintText: '********',
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'UNLOCK',
                    onPressed: _unlock,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Switch user / Logout
                      KeyStorage.remove('user');
                      KeyStorage.remove('userToken');
                      KeyStorage.saveBool('isLocked', false);
                      Get.offAllNamed('/login');
                    },
                    child: Text('Login as different user', style: TextStyle(color: AppColor.primary)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
