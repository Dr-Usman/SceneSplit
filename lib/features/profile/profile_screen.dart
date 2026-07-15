import 'package:flutter/material.dart';

import 'widgets/profile_app_section.dart';
import 'widgets/profile_appearance_section.dart';
import 'widgets/profile_currency_section.dart';
import 'widgets/profile_manage_section.dart';
import 'widgets/profile_name_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          ProfileNameSection(),
          SizedBox(height: 24),
          ProfileAppearanceSection(),
          SizedBox(height: 24),
          ProfileCurrencySection(),
          SizedBox(height: 32),
          ProfileManageSection(),
          SizedBox(height: 32),
          ProfileAppSection(),
        ],
      ),
    );
  }
}
