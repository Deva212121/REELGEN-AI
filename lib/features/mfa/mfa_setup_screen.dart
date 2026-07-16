import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/mfa_service.dart';

class MFASetupScreen extends StatefulWidget {
  const MFASetupScreen({super.key});

  @override
  State<MFASetupScreen> createState() => _MFASetupScreenState();
}

class _MFASetupScreenState extends State<MFASetupScreen> {
  final MFAService _mfaService = MFAService();
  bool _isLoading = false;
  bool _mfaEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadMFAStatus();
  }

  Future<void> _loadMFAStatus() async {
    final enabled = await _mfaService.isMFAEnabled();
    setState(() => _mfaEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security, color: Color(0xFFC4FF62)),
                        SizedBox(width: 12),
                        Text(
                          'Multi-Factor Authentication',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _mfaEnabled
                          ? '✅ MFA is enabled'
                          : '⚠️ MFA is not enabled',
                      style: TextStyle(
                        color: _mfaEnabled ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _toggleMFA,
                      icon: Icon(_mfaEnabled ? Icons.lock_open : Icons.lock),
                      label: Text(_mfaEnabled ? 'Disable MFA' : 'Enable MFA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mfaEnabled ? Colors.red : const Color(0xFFC4FF62),
                        foregroundColor: _mfaEnabled ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is MFA?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Multi-Factor Authentication adds an extra layer of security to your account.',
                      style: TextStyle(color: Color(0xFF938F99)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMFA() async {
    setState(() => _isLoading = true);
    try {
      if (_mfaEnabled) {
        await _mfaService.disableMFA();
        Fluttertoast.showToast(msg: 'MFA disabled');
      } else {
        await _mfaService.enableMFA();
        Fluttertoast.showToast(msg: 'MFA enabled');
      }
      await _loadMFAStatus();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}