// import 'package:enapel/screens/desktop/desktop_dashboard_screen.dart';
// import 'package:enapel/utils/app_color.dart';
// import 'package:enapel/widget/custom_button.dart';
// import 'package:enapel/widget/custom_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';

// class DesktopLoginScreen extends StatefulWidget {
//   const DesktopLoginScreen({super.key});

//   @override
//   State<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
// }

// class _DesktopLoginScreenState extends State<DesktopLoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(
//                 "assets/images/desktop/signin/bg.png"), // Background image path
//             fit: BoxFit.fill, // Cover the whole screen
//           ),
//         ),
//         child: Center(
//           child: Container(
//             width: Get.size.width * 0.35, // Responsive width
//             padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
//             decoration: BoxDecoration(
//               color: AppColor.white, // Set background color to white
//               borderRadius: BorderRadius.circular(30),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Title
//                 Text(
//                   'Log In',
//                   style: TextStyle(
//                     color: AppColor.black,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Subtitle
//                 Text(
//                   'Quick & Simple way to Automate your sales',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: AppColor.black.withOpacity(0.6),
//                     fontSize: 14,
//                   ),
//                 ),
//                 SizedBox(height: Get.size.height * 0.04),

//                 // Email Text Field
//                 CustomTextField(
//                   labelText: "EMAIL ADDRESS",
//                   hintText: "johndoe@example.com",
//                   labelTextColor: AppColor.black,
//                 ),
//                 SizedBox(height: Get.size.height * 0.04),

//                 // Password Text Field
//                 CustomTextField(
//                   labelText: "PASSWORD",
//                   hintText: "********",
//                   labelTextColor: AppColor.black,
//                   obscureText: true,
//                 ),
//                 SizedBox(height: Get.size.height * 0.04),

//                 // Remember Me Checkbox
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: true, // Set initial value or make it dynamic
//                       onChanged: (bool? newValue) {
//                         // Handle checkbox change
//                       },
//                     ),
//                     Text(
//                       'Remember Me',
//                       style: TextStyle(
//                         color: AppColor.black.withOpacity(0.7),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Proceed Button
//                 CustomButton(
//                   text: 'PROCEED',
//                   onPressed: () {
//                     Get.to(() => const DesktopDashboardScreen());
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
