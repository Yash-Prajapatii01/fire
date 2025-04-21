import 'package:fire/2FA/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveNewPassword extends StatefulWidget {
  const SaveNewPassword({super.key});

  @override
  State<SaveNewPassword> createState() => _SaveNewPasswordState();
}

class _SaveNewPasswordState extends State<SaveNewPassword> {

  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> _saveNewPassword() async {
  final newPassword = _newPasswordController.text.trim();

  if (newPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password cannot be empty')),
    );
    return;
  }

  try {
    final supabase = Supabase.instance.client;
    final res = await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.message}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An unexpected error occurred')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save New Password')),
      body: Column(
        children: [
          const Text('Enter your new password'),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _saveNewPassword();
            },
            child: const Text('Save Password'),
          ),
        ],
      )
    );
  }
}
