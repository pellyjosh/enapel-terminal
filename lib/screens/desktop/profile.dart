import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    user = KeyStorage.getMap('user');
    if (user != null) {
      _nameController.text = user!['name'] ?? '';
      _emailController.text = user!['email'] ?? '';
      _phoneController.text = user!['phone'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = constraints.maxWidth > 600 ? 40.0 : 20.0;

        return Container(
          color: AppColor.black.withOpacity(0.6), // Background color
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 30),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Personal Info",
                        "You can see your personal information settings here."),
                    CustomTextField(
                      labelText: "Full Name",
                      labelTextColor: AppColor.white,
                      controller: _nameController,
                      hintText: "Full name",
                      readOnly: true, // Typically name is read-only in terminal
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      labelText: "Email Address",
                      labelTextColor: AppColor.white,
                      controller: _emailController,
                      hintText: "Email address",
                      prefixIcon: Icons.email,
                      readOnly: true,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      labelText: "Phone Number",
                      labelTextColor: AppColor.white,
                      controller: _phoneController,
                      hintText: "Phone number",
                      prefixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 30),
                    sectionTitle("Change Password",
                        "Update your password to keep your account secure."),
                    CustomTextField(
                      labelText: "Current Password",
                      labelTextColor: AppColor.white,
                      hintText: "Enter current password",
                      obscureText: true,
                      controller: _currentPasswordController,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      labelText: "New Password",
                      labelTextColor: AppColor.white,
                      hintText: "Enter new password",
                      obscureText: true,
                      controller: _newPasswordController,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      labelText: "Confirm New Password",
                      labelTextColor: AppColor.white,
                      hintText: "Confirm new password",
                      obscureText: true,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 30),
                    actionButtons(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: AppColor.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle,
              style: TextStyle(color: AppColor.grey, fontSize: 14)),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          },
          style: TextButton.styleFrom(foregroundColor: AppColor.danger),
          child: const Text("Clear Fields"),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle Save logic
            _saveProfile();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          ),
          child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _saveProfile() {
    // Check if password change is attempted
    if (_newPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        Get.snackbar("Error", "New passwords do not match",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (_currentPasswordController.text.isEmpty) {
        Get.snackbar("Error", "Please enter current password to verify",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    // Logic for updating profile/password would go here
    Get.snackbar("Success", "Profile updated successfully (Mock)",
        backgroundColor: Colors.green, colorText: Colors.white);
  }
}
