import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:version1/provider/auth.dart';
import 'package:version1/screen/board.dart';
import 'package:version1/screen/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
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

  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);

    return  Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          children: [
            TextFormField(
              controller: authProvider.emailController,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
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
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : () => authProvider.signIn(context, true),
              child: const Text('SignIn'),
            ),
            const SizedBox(height: 18),
            TextButton(
                onPressed: () {
                  if(mounted){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));}
                },
                child: const Text('Create a new account'))
          ],
        ),
      ),
    );
  }
}
