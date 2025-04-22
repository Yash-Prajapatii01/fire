import 'package:fire/VerifyScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _checkUserExists(String email) async {
    final supabase = Supabase.instance.client;
    try {
      final res = await supabase.functions.invoke(
        'check-user-exists',
        body: {"email": email},
      );
      if (res.status == 200) {
        final data = res.data;
        if (data['exists'] == true) {
          final resolvedEmail = data['email'];
          print("✅ User exists. Email resolved: $resolvedEmail");
          _sendOtpToEmail(resolvedEmail); // use resolved email
        }
      } else {
        print("Error Message: ${res.data}");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  

  Future<void> _sendOtpToEmail(String email) async {
    await Supabase.instance.client.auth.signInWithOtp(email: email);
    print("OTP sent to $email");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VerifyOTPScreen(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enter your email to reset your password",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _checkUserExists(_emailController.text.trim());
                  // _customFun(_emailController.text.trim());
                },
                child: const Text('Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
