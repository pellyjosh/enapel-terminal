import 'package:enapel/controller/auth_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopLoginScreen extends StatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  State<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends State<DesktopLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late final String databaseMode;
  AuthController? authController;
  bool isLoading = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  Future<void> initializeController() async {
    databaseMode = KeyStorage.getString('database_mode') ?? 'local';
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
    // if (value.length < 6) {
    //   return 'Password must be at least 6 characters';
    // }
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
            image: AssetImage("assets/images/desktop/signin/bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Container(
            width: Get.size.width * 0.35, // Responsive width
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
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
              key: _formKey, // Form key for validation
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Log In',
                    style: TextStyle(
                      color: AppColor.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Quick & Simple way to Automate your sales',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.black.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: Get.size.height * 0.04),

                  // Email Text Field with Validation
                  CustomTextField(
                    labelText: "EMAIL ADDRESS",
                    hintText: "johndoe@example.com",
                    labelTextColor: AppColor.black,
                    controller: emailController,
                    validator: _emailValidator, // Add the email validator
                  ),
                  SizedBox(height: Get.size.height * 0.04),

                  // Password Text Field with Validation
                  CustomTextField(
                    labelText: "PASSWORD",
                    hintText: "********",
                    labelTextColor: AppColor.black,
                    obscureText: true,
                    controller: passwordController,
                    validator: _passwordValidator,
                  ),
                  SizedBox(height: Get.size.height * 0.04),

                  // Remember Me Checkbox
                  // Row(
                  //   children: [
                  //     Checkbox(
                  //       value: true, // Set initial value or make it dynamic
                  //       onChanged: (bool? newValue) {
                  //         // Handle checkbox change
                  //       },
                  //     ),
                  //     Text(
                  //       'Remember Me',
                  //       style: TextStyle(
                  //         color: AppColor.black.withOpacity(0.7),
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20),

                  // Proceed Button
                  CustomButton(
                    label: 'PROCEED',
                    onPressed: () {
                      // Check if the form is valid
                      if (_formKey.currentState?.validate() ?? false) {
                        // Ensure authController is not null before calling login
                        authController?.login(
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
