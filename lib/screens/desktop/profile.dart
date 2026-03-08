import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';


class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
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
                        "You can change your personal information settings here."),
                     CustomTextField(
                      labelText: "Full Name",
                       labelTextColor: AppColor.white,
                      hintText: "Azusa Nakano",
                    ),
                    const SizedBox(height: 18),
                     CustomTextField(
                      labelText: "Email Address",
                      labelTextColor:AppColor.white,
                      hintText: "elementary221b@gmail.com",
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(height: 18),
                     CustomTextField(
                      labelText: "Phone Number",
                       labelTextColor: AppColor.white,
                      hintText: "+44 (123) 456-9878",
                      prefixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      labelText: "Account Type",
                     labelTextColor: AppColor.white,
                      hintText: "Regular",
                      dropdownItems: ["Regular", "Premium"],
                      selectedDropdownValue: "Regular",
                      onDropdownChanged: (value) {},
                    ),
                    const SizedBox(height: 30),
                    avatarUpload(),
                    const SizedBox(height: 30),
                    sectionTitle("Payments",
                        "You can change your payment credentials here."),
                    toggleSwitch("Enable Auto Payout", true),
                    toggleSwitch("Notify New Payments", false),
                     CustomTextField(
                      labelText: "Credit Card",
                       labelTextColor: AppColor.white,
                      hintText: "9978 1128 1558 1978",
                      prefixIcon: Icons.credit_card,
                    ),
                     CustomTextField(
                      labelText: "Card Holder Name",
                       labelTextColor: AppColor.white,
                      hintText: "Azusa Nakano",
                      prefixIcon: Icons.person,
                    ),
                    CustomTextField(
                      labelText: "Country",
                       labelTextColor: AppColor.white,
                      hintText: "United Kingdom",
                      dropdownItems: const [
                        "United Kingdom",
                        "United States",
                        "Canada"
                      ],
                      selectedDropdownValue: "United Kingdom",
                      onDropdownChanged: (value) {},
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
              style:  TextStyle(
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

 

  Widget avatarUpload() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColor.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const CircleAvatar(
              radius: 40,
              backgroundImage:
                  AssetImage("assets/avatar.jpg")), // Replace with NetworkImage
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {},
            child:  Text("Click here to upload your file or drag",
                style: TextStyle(color: AppColor.primary)),
          ),
           Text("Supported Format: SVG, JPG, PNG (10MB each)",
              style: TextStyle(color: AppColor.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget toggleSwitch(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:  TextStyle(color: AppColor.white, fontSize: 16)),
          Switch(
            value: isActive,
            onChanged: (value) {},
            activeColor: AppColor.primary,
          ),
        ],
      ),
    );
  }



  Widget actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: AppColor.danger),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          ),
          child: const Text("Save", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
