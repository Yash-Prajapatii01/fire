import 'package:fire/2FA/verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fire/2FA/LoginPage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final client = Supabase.instance.client;

  String? qrSvgData;
  String? secret;
  String? factorId;
  bool is2FAEnabled = false;
  bool isLoading = false;
  bool isVerifying = false;
  String? errorMessage;

  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _check2FAStatus();
  }

  Future<void> _check2FAStatus() async {
    try {
      final factors = await client.auth.mfa.listFactors();

      await client.auth.mfa.getAuthenticatorAssuranceLevel;

      setState(() {
        is2FAEnabled = factors.totp.isNotEmpty;
        if (is2FAEnabled) {
          factorId = factors.totp.first.id;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error checking 2FA status: $e';
      });
    }
  }

  /// Deletes all unverified TOTP factors for the signed-in user.
  Future<void> unEnrolltheUser() async {
    final supabase = Supabase.instance.client;
    final factors = await client.auth.mfa.listFactors();

    final factorId = factors.totp.first.id;
    await supabase.auth.refreshSession();

    final aal_level = await supabase.auth.mfa.getAuthenticatorAssuranceLevel().currentLevel;
    
    print('aal_level: $aal_level.aal2');

    if (aal_level != AuthenticatorAssuranceLevels.aal2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VerificationScreen()),
      );
    }

    final resposne = await supabase.auth.mfa.unenroll(factorId);
    if (resposne != null) {
      print('Unenrolled successfully');
      setState(() {});
    } else {
      print('Failed to unenroll');
    }
    setState(() {
      is2FAEnabled = false;
      qrSvgData = null;
    });
  }

  Future<void> _enroll2FA() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await client.auth.mfa.enroll(
        factorType: FactorType.totp,
      );

      setState(() {
        qrSvgData = response.totp.qrCode;
        secret = response.totp.secret;
        factorId = response.id;
        isLoading = false;
      });

      // print('QR Code SVG: $qrSvgData');
      print('Secret: $secret');
      print('Factor ID: $factorId');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('2FA Enrollment Error: $e')));
    }
  }

  Future<void> _verify2FA(String otp) async {
    if (factorId == null || otp.isEmpty) return;

    setState(() {
      isVerifying = true;
      errorMessage = null;
    });

    try {
      final challenge = await client.auth.mfa.challenge(factorId: factorId!);
      final verifiedSession = await client.auth.mfa.verify(
        factorId: factorId!,
        challengeId: challenge.id,
        code: otp,
      );

      if (verifiedSession != null) {
        setState(() {
          is2FAEnabled = true;
          errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA setup completed successfully.')),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'OTP Verification Failed: $e';
      });
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  //
  Future<void> _logoutAfterEnrollment(SupabaseClient supabase) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 🔒 Step 1: Delete unverified TOTP factors
      // here we can call the function to delete unverified factors , as a user must logout to login for the 2FA to be effective
      // ✅ Step 2: Sign out user
      await supabase.auth.signOut();

      // 🔁 Step 3: Navigate to login
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error during logout: $e';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout Error: $errorMessage')));
      debugPrint('Logout Error: $errorMessage');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!is2FAEnabled) ...[
              if (qrSvgData == null) ...[
                const Text(
                  'You must enable 2FA to proceed.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _enroll2FA,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Enroll 2FA'),
                ),
              ],

              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              // Show QR and OTP input only when QR is available
              if (qrSvgData != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Scan this QR code with your authenticator app:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  width: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.string(
                    qrSvgData!,
                    placeholderBuilder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        'Secret: $secret',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy to clipboard',
                      onPressed: () {
                        if (secret != null) {
                          Clipboard.setData(ClipboardData(text: secret!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Secret copied to clipboard'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP from authenticator app',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      isVerifying
                          ? null
                          : () => _verify2FA(_otpController.text.trim()),
                  child:
                      isVerifying
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Verify OTP & Complete Setup'),
                ),
                const SizedBox(height: 16),
              ],
              if (is2FAEnabled) ...[
                ElevatedButton(
                  onPressed: () => _logoutAfterEnrollment(client),
                  child: const Text('Logout'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => unEnrolltheUser(),
                  child: const Text('Unenroll 2FA'),
                ),
              ],
            ] else ...[
              const Text(
                '2FA is already enabled.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _logoutAfterEnrollment(client),
                child: const Text('Logout'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => unEnrolltheUser(),
                child: const Text('Unenroll 2FA'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
