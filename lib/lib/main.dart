import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:version1/screen/login_page.dart';
import 'package:version1/screen/account.dart';
import 'package:version1/provider/account.dart';
import 'package:version1/provider/auth.dart';
import 'package:provider/provider.dart';
import 'package:version1/provider/board.dart';
import 'package:version1/screen/add_post.dart';
import 'package:version1/provider/post_provider.dart';

Future<void> main() async{
  await Supabase.initialize(
    url: 'https://viofzvwtfpbxwkicmemx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZpb2Z6dnd0ZnBieHdraWNtZW14Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk1NzEzMDgsImV4cCI6MjA0NTE0NzMwOH0.Z1BYEKU4JOq7LiL7-tYWF7-6VUhr3bnA7oC_HAWGt2o',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create : (_)=>Auth()),
        ChangeNotifierProvider(create: (_)=> AccountProvider()),
        ChangeNotifierProvider(create: (_)=> PostList(Supabase.instance.client)),
        ChangeNotifierProvider(create: (_)=> Posts(Supabase.instance.client))
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'Supabase Flutter',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
      home: supabase.auth.currentSession == null
          ?const LoginPage()
          :const AccountPage(),

    );
  }
}
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
