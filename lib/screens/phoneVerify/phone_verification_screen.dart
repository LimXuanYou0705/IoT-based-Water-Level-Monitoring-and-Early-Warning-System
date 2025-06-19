import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helper/otp_helper.dart';
import 'otp_verification.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();

  bool _isOTPSent = false;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  void _sendOTP() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _isError = true;
        _errorMessage = 'Please enter your phone number';
        _isLoading = false;
      });
      return;
    }

    if (phone.length < 9 || phone.length > 10) {
      setState(() {
        _isError = true;
        _errorMessage = 'Invalid phone number! Must be 9–10 digits after +60.';
        _isLoading = false;
      });
      return;
    }

    String fullPhone = '+60$phone';

    final success = await OtpHelper.sendOtp(fullPhone);

    if (success) {
      setState(() {
        _isError = false;
        _errorMessage = '';
        _isLoading = false;
        _isOTPSent = true;
      });
      // Navigate to next screen, or show "Code sent"
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OtpVerificationScreen())
      );
    } else {
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to send OTP';
        _isLoading = false;
      });
      return;
    }

  }

  void _verifyOTP() async {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(leading: null, title: const Text('Poseidon Guard')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // Changed to center alignment
                children: [
                  Text(
                    "Enter your Phone for verification",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF36B6FD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).hintColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFF7F8FC),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.phone, size: 20),
                              SizedBox(width: 5),
                              Text('+60', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'e.g. 123456789',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                        width: double.infinity, // Make button full width
                        child: ElevatedButton(
                          onPressed: _sendOTP,
                          child: const Text('Send OTP'),
                        ),
                      ),
                  const SizedBox(height: 20),
                  _isError
                      ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
