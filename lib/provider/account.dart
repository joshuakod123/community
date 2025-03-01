import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:version1/utils/helpers.dart';
import 'package:version1/main.dart';

import '../screen/login_page.dart';

class AccountProvider extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  String? avatarUrl;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> getProfile(BuildContext context, bool mounted) async {
    WidgetsBinding.instance.addPostFrameCallback((_) => _setLoading(true)); // Ensure the loading state is set after the frame.

    try {
      final userId = supabase.auth.currentSession?.user.id;
      if (userId != null) {
        final data = await supabase.from('profiles').select().eq('id', userId).single();
        usernameController.text = (data['username'] ?? '') as String;
        websiteController.text = (data['website'] ?? '') as String;
        avatarUrl = (data['avatar_url'] ?? '') as String;

      }
    } on PostgrestException catch (error) {
      if (mounted) {
        showSnackBar(context, error.message, isError: true);
      }
    } catch (error) {
      if (mounted) {
        showSnackBar(context, 'Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _setLoading(false)); // Ensure loading is turned off after the frame.
      }
    }
  }

  Future<void> updateProfile(BuildContext context, bool mounted) async {
    WidgetsBinding.instance.addPostFrameCallback((_) => _setLoading(true));

    final userName = usernameController.text.trim();
    final website = websiteController.text.trim();
    final user = supabase.auth.currentUser;

    if (user != null) {
      final updates = {
        'id': user.id,
        'username': userName,
        'website': website,
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        await supabase.from('profiles').upsert(updates);
        if (mounted) {
          showSnackBar(context, 'Successfully updated profile!', isError: false);
        }
      } on PostgrestException catch (error) {
        if (mounted) {
          showSnackBar(context, error.message, isError: true);
        }
      } catch (error) {
        if (mounted) {
          showSnackBar(context, 'Unexpected error occurred', isError: true);
        }
      } finally {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _setLoading(false));
        }
      }
    }
  }

  Future<void> signOut(BuildContext context, bool mounted) async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } on AuthException catch (error) {
      if (mounted) showSnackBar(context, error.message, isError: true);
    } catch (error) {
      if (mounted) showSnackBar(context, 'Unexpected error occurred', isError: true);
    } finally {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        });
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    websiteController.dispose();
    super.dispose();
  }
}
