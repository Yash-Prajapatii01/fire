// import 'dart:async';
// import 'dart:convert';

// import 'package:fire/dashboard.dart';
// import 'package:fire/forgot_password_screen.dart';
// import 'package:fire/verification.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   Future<void> deleteUnverifiedTotpFactors() async {
//     final supabase = Supabase.instance.client;
//     final session = supabase.auth.currentSession;
//     final token = session?.accessToken;

//     if (token == null) {
//       throw Exception('User is not authenticated.');
//     }

//     final url = Uri.parse(
//       'https://jyqqaymjgytkralrxcey.supabase.co/functions/v1/delete-unverified-factors',
//     );

//     final res = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     final body = jsonDecode(res.body);
//     if (res.statusCode == 200) {
//       print('[✅] Deleted ${body['deletedCount']} unverified factors.');
//     } else {
//       print('[❌] Status ${res.statusCode}: ${body}');
//       throw Exception('Failed to delete unverified TOTP factors.');
//     }
//   }

//   Future<void> _login() async {
//     //  deleteUnverifiedTotpFactors();
//     final email = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     try {
//       final res = await Supabase.instance.client.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );

//       if (res.user == null) throw Exception('Login failed');
//       await deleteUnverifiedTotpFactors();

//       final factors = await Supabase.instance.client.auth.mfa.listFactors();

//       // final verifiedFactors = [
//       //   ...factors.totp.where((f) => f.status == 'verified'),
//       // ];

//       if (factors.all.isNotEmpty) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const VerificationScreen()),
//         );
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const DashboardScreen()),
//         );
//       }
//     } on AuthException catch (e) {
//       print('Auth Error: ${e.message}');
//     } catch (e) {
//       print('Unexpected Error: $e');
//     }
//   }

//   Future<void> _signUp() async {
//     final email = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     try {
//       final res = await Supabase.instance.client.auth.signUp(
//         email: email,
//         password: password,
//         data: {"username": "2noob2play"},
//       );
//       if (res.user != null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('SignUp Successful')));
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('SignUp failed')));
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(
//                 labelText: 'Username',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _login,
//                 child: const Text('Login'),
//               ),
//             ),
//             SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _signUp,
//                 child: const Text('SignUp'),
//               ),
//             ),
//             SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed:
//                     () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
//                     ),
//                 child: const Text('Forogt Password'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:fire/2FA/dashboard.dart';
import 'package:fire/forgot_password_screen.dart';
import 'package:fire/2FA/verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  Future<void> deleteUnverifiedTotpFactors() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    final token = session?.accessToken;
    final userId = session?.user?.id;

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final url = Uri.parse(
      'https://jyqqaymjgytkralrxcey.supabase.co/functions/v1/delete-unverified-factors',
    );

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      print('[✅] Deleted ${body['deletedCount']} unverified factors.');
    } else {
      print('[❌] Status ${res.statusCode}: ${body}');
      throw Exception('Failed to delete unverified TOTP factors.');
    }
  }
  // Future<void> deleteUnverifiedTotpFactors() async {
  //   final supabase = Supabase.instance.client;
  //   final session = supabase.auth.currentSession;
  //   final token = session?.accessToken;

  //   if (token == null) {
  //     throw Exception('User is not authenticated.');
  //   }

  //   try {
  //     final res = await supabase.functions.invoke(
  //       'delete-unverified-factors',
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         // 'Content-Type': 'application/json',
  //       },
  //     );

  //     if (res.status == 200) {
  //       final body = res.data;
  //       print('[✅] Deleted ${body['deletedCount']} unverified factors.');
  //     } else {
  //       print('[❌] Status ${res.status}: ${res.data}');
  //       throw Exception('Failed to delete unverified TOTP factors.');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<void> _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // 1️⃣ Sign in and obtain user ID
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) throw Exception('Login failed');
      final userId = user.id;

      // 2️⃣ Check per‑user MFA skip flag
      final skipKey = 'mfa_skip_until_$userId';
      final skipIso = await _secureStorage.read(key: skipKey);
      if (skipIso != null) {
        final skipUntil = DateTime.parse(skipIso);
        if (skipUntil.isAfter(DateTime.now())) {
          // Still within 30‑day window → skip MFA
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
          return;
        }
        // delete if the skip date is in the past
        await _secureStorage.delete(key: skipKey);
      }

      // 3️⃣ Clean up any unverified factors, then list factors
      await deleteUnverifiedTotpFactors();
      final factors = await Supabase.instance.client.auth.mfa.listFactors();

      // 4️⃣ Route based on whether MFA is required
      if (factors.all.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VerificationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on AuthException catch (e) {
      print('Auth Error: ${e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Error: ${e.message}')));
    } catch (e) {
      print('Unexpected Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected Error: $e')));
    }
  }

  Future<void> _signUp() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {"username": "2noob2play"},
      );
      if (res.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('SignUp Successful')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('SignUp failed')));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signUp,
                child: const Text('SignUp'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    ),
                child: const Text('Forogt Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
