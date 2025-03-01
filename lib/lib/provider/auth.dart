import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

import '../main.dart';
import 'package:version1/utils/helpers.dart';
import 'package:version1/screen/account.dart';
import '/model/http_exception.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


class Auth with ChangeNotifier{
  final TextEditingController emailController= TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _redirecting = false;
  late StreamSubscription<AuthState> _authStateSubscription;

  bool get isLoading => _isLoading;

  Future<void> signInWithEmailAndPassword ( BuildContext context, bool mounted) async{
    _setLoading(true);

    try{
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if(res.session != null){
        if(mounted){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const AccountPage()));
        }
      }else{
        if(mounted) showSnackBar(context, 'Failed to sign in. Check your credentials.', isError:true);
      }
    }on AuthException catch (error){
      if(mounted) showSnackBar(context, error.message, isError: true);
    }catch(error){
      if(mounted) showSnackBar(context, 'Unexpected error occurred', isError:true);
    }finally{
      if(mounted) _setLoading(false);
    }
  }

  void initializeAuthStateListener(BuildContext context, bool mounted){
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
        (data){
          if(_redirecting || !mounted) return;
          final session = data.session;
          if (session != null){
            _redirecting= true;
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder:(context) => const AccountPage()),
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

  Future<void> signIn(String email, BuildContext context, bool mounted) async{
    try{
      _setLoading(true);
      await supabase.auth.signInWithOtp(
        email: email.trim(),
        emailRedirectTo: kIsWeb
          ?null
            : 'io.supbase.flutterquickstart://login-callback/',
      );
      if (mounted) {
        showSnackBar(context,'Check your email for a login link!');
      }
    }on AuthException catch (error){
      if (mounted) {
        showSnackBar(context, error.message,isError: true);
      }
    }catch(error){
      if(mounted) {
        showSnackBar(context, 'Unexpected error occurred', isError: true);
      }
    }finally{
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  Future<void> signUpWithEmailAndPassword(BuildContext context, bool mounted) async {
    _setLoading(true);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        if (mounted) showSnackBar(context, 'Sign-up successful!');
        // Optionally, you could navigate to the login page or another page
      } else {
        if (mounted) showSnackBar(context, 'Sign-up failed. Please try again.', isError: true);
      }
    } on AuthException catch (error) {
      if (mounted) showSnackBar(context, error.message, isError: true);
    } catch (error) {
      if (mounted) showSnackBar(context, 'Unexpected error occurred', isError: true);
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  void dispose(){
    _authStateSubscription.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

