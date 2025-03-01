import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/provider/account.dart';
import 'package:version1/widgets/custom_widgets.dart';
import 'package:version1/provider/auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AccountProvider>(context, listen: false);
    authProvider.getProfile(context, mounted);  // Fetch profile when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          CustomTextField(
            controller: authProvider.usernameController,
            label: 'User Name',
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: authProvider.websiteController,
            label: 'Website',
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: authProvider.isLoading ? 'Saving...' : 'Update',
            onPressed: authProvider.isLoading
                ? null
                : () => authProvider.updateProfile(context, mounted),
          ),
          const SizedBox(height: 18),
          CustomTextButton(
            text: 'Sign Out',
            onPressed: () => authProvider.signOut(context, mounted),
          ),
        ],
      ),
    );
  }
}
