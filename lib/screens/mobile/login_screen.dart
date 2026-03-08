import 'package:enapel/controller/auth_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthController? authController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  Future<void> initializeController() async {
    final databaseMode = KeyStorage.getString('database_mode') ?? 'local';

    if (Get.isRegistered<AuthController>()) {
      authController = Get.find<AuthController>();
    } else {
      authController = Get.put(AuthController(databaseMode));
    }

    setState(() {
      isLoading = false;
    });
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Log-In',
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Get.size.height * 0.08),
                  CustomTextField(
                    labelText: "Email Address",
                    hintText: "johndoe@example.com",
                    hintTextColor: AppColor.black.withOpacity(0.7),
                    controller: emailController,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    labelText: "Password",
                    hintText: "8 characters minimum",
                    obscureText: true,
                    controller: passwordController,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'Proceed',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await authController?.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
