

import 'package:fire/2FA/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jyqqaymjgytkralrxcey.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5cXFheW1qZ3l0a3JhbHJ4Y2V5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ2MjEyNTgsImV4cCI6MjA2MDE5NzI1OH0.nOX7d3aJY_zLiuNkIAi3YKjNboAFIVSrHJtzRWHEc2s',
  );
  runApp(MyApp());
}
        
        

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire',
      home: LoginPage(),
    );
  }
}
