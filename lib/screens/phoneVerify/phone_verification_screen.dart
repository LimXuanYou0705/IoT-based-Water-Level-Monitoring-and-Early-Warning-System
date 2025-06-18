import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String? _countryCode = '+60';

  bool _isOTPSent = false;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    String phone = _phoneController.text.trim();
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
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            ],
                            validator: _phoneValidate,
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

  String? _phoneValidate(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isError == true;
        _errorMessage = 'Please enter your phone number';
      });
    }
    return null;
  }
}
