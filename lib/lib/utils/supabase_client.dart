import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientInstance {
  static const String supabaseUrl = 'https://viofzvwtfpbxwkicmemx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZpb2Z6dnd0ZnBieHdraWNtZW14Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk1NzEzMDgsImV4cCI6MjA0NTE0NzMwOH0.Z1BYEKU4JOq7LiL7-tYWF7-6VUhr3bnA7oC_HAWGt2o';

  static final SupabaseClient supabaseClient = SupabaseClient(supabaseUrl, supabaseAnonKey);
}
