import 'dart:async';
import 'package:flutter/material.dart';
import 'package:version1/screen/home.dart';

import 'package:version1/screen/signUp.dart';
import '../main.dart';
import 'package:version1/utils/helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screen/board.dart';


class Auth with ChangeNotifier{
  final TextEditingController emailController= TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool _isLoading = false;
  bool _redirecting = false;
  late StreamSubscription<AuthState> _authStateSubscription;

  bool get isLoading => _isLoading;

  void initializeAuthStateListener(BuildContext context, bool mounted){
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
        (data){
          if(_redirecting || !mounted) return;
          final session = data.session;
          if (session != null){
            _redirecting= true;
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder:(context) => const HomeScreen()),
              );
            }
          }
        },
      onError: (error){
          if(!mounted) return;
          if(error is AuthException || mounted){
            showSnackBar(context, error.message,isError: true);
          }else{
            showSnackBar(context,'Unexpected error occurred', isError: true);
          }
      }
    );
  }

  Future<void> signIn(BuildContext context, bool mounted) async{
    _isLoading = false;
    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final User? user= res.user;

      if (res.user != null) {
        if (mounted) showSnackBar(context, 'Sign-In successful!');
        if(mounted){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BoardScreen()));}
      } else {
        if (mounted) showSnackBar(context, 'Sign-In failed. Please try again.', isError: true);
      }

    } on AuthException catch (error) {
      if(mounted) context.showSnackBar('$error');
    } catch (error) {
      if(mounted) context.showSnackBar('$error');
    }

  }

  Future<void> signUp(BuildContext context, bool mounted) async{
    _isLoading = false;
    try {
      final _em= emailController.text.trim();
      final _pw= passwordController.text.trim();
      final _un = usernameController.text.trim();
      final _res = await supabase.auth.signUp(
        email: _em,
        password: _pw,
        data: {'Display name': _un},
      );

      if (_res.user != null) {
        if (mounted) showSnackBar(context, 'Sign-up successful!');
        if(mounted){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BoardScreen()));}
        // Optionally, you could navigate to the login page or another page
      } else {
        if (mounted) showSnackBar(context, 'Sign-up failed. Please try again.', isError: true);
      }

    } on AuthException catch (error) {
      if(mounted) context.showSnackBar('$error');
    } catch (error) {
      if(mounted) context.showSnackBar('$error');
      print(error);
    }

  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose(){
    _authStateSubscription.cancel();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}

