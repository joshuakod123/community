import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/provider/auth.dart';
import 'package:version1/screen/account.dart';
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
          CustomTextField(
            controller: authProvider.emailController,
            label: 'Email',
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: authProvider.passwordController,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: authProvider.isLoading ? 'Signing Up...' : 'Sign Up',
            onPressed: authProvider.isLoading
                ? null
                : () => authProvider.signUpWithEmailAndPassword(context, true),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BoardScreen())); // Navigate back to login if needed
            },
            child: const Text('Already have an account? Sign In'),
          ),
        ],
      ),
    );
  }
}
