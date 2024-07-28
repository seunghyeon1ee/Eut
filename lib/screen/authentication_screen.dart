import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taba_app_proj/screen/register_elder_fin.dart';
import 'package:taba_app_proj/provider/auth_provider.dart';

class Authentic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const LogInElder2();
  }
}

class LogInElder2 extends StatefulWidget {
  const LogInElder2({Key? key}) : super(key: key);

  @override
  _LogInElder2State createState() => _LogInElder2State();
}

class _LogInElder2State extends State<LogInElder2> {
  final TextEditingController _phoneController = TextEditingController();

  void _verifyPhone() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.verifyPhoneNumber(context, _phoneController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In Elder 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPhone,
              child: Text('Verify Phone Number'),
            ),
          ],
        ),
      ),
    );
  }
}
