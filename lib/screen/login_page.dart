import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/provider/auth.dart';
import 'package:version1/screen/account.dart';
import 'package:version1/screen/signUp.dart';
import 'package:version1/widgets/custom_widgets.dart';
import 'package:version1/screen/board.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize auth listener with the mounted check
    Provider.of<Auth>(context, listen: false).initializeAuthStateListener(context, mounted);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Create an account with your email and password'),
          const SizedBox(height: 18),
          TextFormField(
            controller: authProvider.emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Required';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: authProvider.passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              label: Text('Password'),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Required';
              }
              if (val.length < 8) {
                return '8 characters minimum';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: authProvider.usernameController,
            decoration: const InputDecoration(
              label: Text('Username'),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Required';
              }
              final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
              if (!isValid) {
                return '3-24 long with alphanumeric or underscore';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: authProvider.isLoading ? 'Signing Up...' : 'Sign Up',
            onPressed: authProvider.isLoading
                ? null
                : () => authProvider.signUp(context, true),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RegisterPage())); // Navigate back to login if needed
            },
            child: const Text('Already have an account? Sign In'),
          ),
        ],
      ),
    );
  }
}
