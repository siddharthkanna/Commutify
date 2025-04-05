import 'package:supabase_flutter/supabase_flutter.dart';

/// Class to access the Supabase client instance
class SupabaseClientSingleton {
  static final SupabaseClientSingleton _instance = SupabaseClientSingleton._internal();
  
  factory SupabaseClientSingleton() {
    return _instance;
  }
  
  SupabaseClientSingleton._internal();
  
  // Get the Supabase client instance
  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      print("Error accessing Supabase client: $e");
      rethrow;
    }
  }
  
  // Access auth directly
  GoTrueClient get auth {
    try {
      return Supabase.instance.client.auth;
    } catch (e) {
      print("Error accessing Supabase auth: $e");
      rethrow;
    }
  }
}

// Easy access to the singleton instance
final supabaseClient = SupabaseClientSingleton(); 