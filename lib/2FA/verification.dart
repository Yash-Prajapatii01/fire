// import 'package:fire/dashboard.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class VerificationScreen extends StatefulWidget {
//   const VerificationScreen({super.key});

//   @override
//   State<VerificationScreen> createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   final TextEditingController _otpCtrl = TextEditingController();
//   String? challengeId;
//   String? factorId;
//   bool rememberDevice = false;

//   @override
//   void initState() {
//     super.initState();
//     _initMFA();
//   }

//   Future<void> _initMFA() async {
//     final factors = await Supabase.instance.client.auth.mfa.listFactors();
//     if (factors.all.isEmpty) return;

//     factorId = factors.all.first.id;

//     final challenge = await Supabase.instance.client.auth.mfa.challenge(
//       factorId: factorId!,
//     );

//     setState(() {
//       challengeId = challenge.id;
//     });
//   }

//   Future<void> _verifyOTP() async {
//     try {
//       await Supabase.instance.client.auth.mfa.verify(
//         factorId: factorId!,
//         challengeId: challengeId!,
//         code: _otpCtrl.text.trim(),
//       );

//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Verification Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('2FA Verification')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: _otpCtrl, decoration: const InputDecoration(labelText: 'OTP')),
//             CheckboxListTile(
//               value: rememberDevice,
//               onChanged: (val) => setState(() => rememberDevice = val!),
//               title: const Text('Remember for 30 days'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(onPressed: _verifyOTP, child: const Text('Verify')),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ---------------------------------------------------> Perfect code above

import 'package:fire/2FA/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpCtrl = TextEditingController();
  String? challengeId;
  String? factorId;
  bool rememberDevice = false;

  @override
  void initState() {
    super.initState();
    _initMFA();
  }

  Future<void> _initMFA() async {
    final factors = await Supabase.instance.client.auth.mfa.listFactors();
    if (factors.all.isEmpty) return;

    factorId = factors.all.first.id;

    final challenge = await Supabase.instance.client.auth.mfa.challenge(
      factorId: factorId!,
    );

    setState(() {
      challengeId = challenge.id;
    });
  }

  Future<void> _verifyOTP() async {
    try {
      // 1️⃣ Verify the OTP challenge
      await Supabase.instance.client.auth.mfa.verify(
        factorId: factorId!,
        challengeId: challengeId!,
        code: _otpCtrl.text.trim(),
      );

      
      if (rememberDevice) {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final skipUntil = DateTime.now().add(Duration(minutes: 10));

        await Supabase.instance.client.from('mfa_skip').upsert({
          'user_id': userId,
          'skip_until': skipUntil.toIso8601String(),
        });
      }

      // 3️⃣ Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      print('Verification Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2FA Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _otpCtrl,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            CheckboxListTile(
              value: rememberDevice,
              onChanged: (val) => setState(() => rememberDevice = val!),
              title: const Text('Remember for 10 minutes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _verifyOTP, child: const Text('Verify')),
          ],
        ),
      ),
    );
  }
}
