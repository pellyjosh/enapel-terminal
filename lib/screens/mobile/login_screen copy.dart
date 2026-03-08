// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:enapel/screens/mobile/dashboard_screen.dart';
// import 'package:enapel/utils/app_color.dart';
// import 'package:enapel/widget/custom_button.dart';
// import 'package:enapel/widget/custom_text_field.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/bg2.png"), // Background image path
//             fit: BoxFit.fill, // Cover the whole screen
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Log-In',
//                   style: TextStyle(
//                     color: AppColor.white,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: Get.size.height * 0.08),

//                 // Email Text Field
//                 const CustomTextField(
//                   labelText: "Email Address",
//                   hintText: "ABC23654",
//                 ),
//                 const SizedBox(height: 24),

//                 // Password Text Field
//                 const CustomTextField(
//                   labelText: "Password",
//                   hintText: "8 characters minimum",
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 30),

//                 // Proceed Button
//                 CustomButton(
//                   text: 'Proceed',
//                   onPressed: () {
//                     Get.to(() => const DashboardScreen());
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
