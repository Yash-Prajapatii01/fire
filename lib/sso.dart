// import 'package:flutter/material.dart';
// import 'package:http/http.dart';

// class Sso extends StatelessWidget {
//   const Sso({super.key});

//   @override
//   Widget build(BuildContext context) {

//     Future<void> _ssoLogin(String accountID) async {
//       final res = await post(
//         Uri.parse('https://test.eresourcescheduler.cloud/login/saml/${accountID}'),
//       );
//       print(res.body);
//     }

//     final TextEditingController _ssocontroller = TextEditingController();
//     return Scaffold(
//       appBar: AppBar(title: const Text('SSO')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _ssocontroller,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _ssoLogin(_ssocontroller.text.trim()),
//               child: const Text('Login with SSO'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SsoScreen extends StatefulWidget {
  const SsoScreen({super.key});

  @override
  State<SsoScreen> createState() => _SsoScreenState();
}

class _SsoScreenState extends State<SsoScreen> {
  final TextEditingController _ssocontroller = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _ssocontroller.dispose();
    super.dispose();
  }

  Future<void> _launchSsoUrl(String accountID) async {
    final Uri uri = Uri.parse('https://test.eresourcescheduler.cloud/login/saml/$accountID');

    try {
      final bool canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        setState(() {
          _errorMessage = 'Could not launch browser. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSO Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ssocontroller,
              decoration: const InputDecoration(
                labelText: 'Account ID or Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final id = _ssocontroller.text.trim();
                if (id.isNotEmpty) {
                  _launchSsoUrl(id);
                } else {
                  setState(() {
                    _errorMessage = 'Please enter your Account ID.';
                  });
                }
              },
              child: const Text('Login with SSO'),
            ),
          ],
        ),
      ),
    );
  }
}
