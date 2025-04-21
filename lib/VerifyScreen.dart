import 'package:fire/2FA/LoginPage.dart';
import 'package:fire/save_new_password.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;
  const VerifyOTPScreen({super.key, required this.email});

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _otpController = TextEditingController();

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    final res = await Supabase.instance.client.auth.verifyOTP(
      email: widget.email,
      token: otp,
      type: OtpType.email,
    );

    if (res.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Verified! Now log in.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SaveNewPassword()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Enter OTP sent to ${widget.email}'),
            TextField(controller: _otpController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _verifyOtp, child: const Text('Verify')),
          ],
        ),
      ),
    );
  }
}
