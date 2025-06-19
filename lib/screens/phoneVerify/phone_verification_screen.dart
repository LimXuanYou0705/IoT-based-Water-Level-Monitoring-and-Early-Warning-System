import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../helper/otp_helper.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
        ),
      );
      setState(() {
        _isError = false;
        _errorMessage = '';
        _isLoading = false;
        _isOTPSent = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
        ),
      );
      setState(() {
        _isError = true;
        _errorMessage = 'Failed to send OTP';
        _isLoading = false;
        _isOTPSent = false;
      });
    }
  }

  void _verifyOTP(String otp) async {

  }

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
              child:
                  _isOTPSent
                      ? _buildOtpVerificationScreen()
                      : _buildPhoneInputScreen(),
            ),
          ),
        ),
      ),
    );
  }

  // Widget for the phone input screen
  Widget _buildPhoneInputScreen() {
    return Column(
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
                  border: Border.all(color: Theme.of(context).hintColor),
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFF7F8FC)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
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
    );
  }

  final List<TextEditingController> _otpControllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  // Widget for the OTP verification screen
  Widget _buildOtpVerificationScreen() {

    bool isOtpComplete() {
      return _otpControllers.every((controller) => controller.text.isNotEmpty);
    }

    void clearOtpFields() {
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      setState(() {});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Verify OTP",
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF36B6FD),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "An OTP has been sent to +60${_phoneController.text}",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),

        // OTP Input Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Container(
              width: 45,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _otpControllers[index].text.isNotEmpty
                          ? Color(0xFF36B6FD)
                          : Colors.grey.shade300,
                  width: 2,
                ),
                color:
                    _otpControllers[index].text.isNotEmpty
                        ? Color(0xFF36B6FD).withOpacity(0.1)
                        : Colors.white,
              ),
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36B6FD),
                ),
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    // Move to next field
                    if (index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      // Last field, remove focus
                      _focusNodes[index].unfocus();
                    }
                  } else {
                    // Move to previous field when deleted
                    if (index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  }
                  // Trigger rebuild to update UI
                  setState(() {});
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                isOtpComplete()
                    ? () {
                      String otp =
                          _otpControllers
                              .map((controller) => controller.text)
                              .join();
                      // Handle OTP verification logic
                      print("OTP: $otp");
                      _verifyOTP(otp);
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF36B6FD),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Verify OTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Resend Button
        TextButton(
          onPressed: () {
            // Handle resend OTP logic here
            clearOtpFields();
          },
          child: Text(
            'Resend OTP',
            style: TextStyle(
              color: Color(0xFF36B6FD),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
