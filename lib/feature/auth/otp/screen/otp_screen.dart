import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/app_colors.dart';
import '../../create new password/screen/create_new_password_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 5; // ৫ ডিজিট

  final List<TextEditingController> _controllers =
  List.generate(_otpLength, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (index) => FocusNode());

  int _secondsRemaining = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      // পরের ফিল্ডে যাও
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      // ব্যাকস্পেসে পিছনে যাও
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
            ),
            child: const BackButton(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Title
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Description
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 14),
                children: [
                  TextSpan(text: "We have just sent you 5 digit code via your\nemail "),
                  TextSpan(
                    text: "example@gmail.com",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ৫ টি OTP ফিল্ড
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_otpLength, (index) {
                return SizedBox(
                  width: 56,
                  height: 56,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Optional: Validate OTP
                  Get.to(() =>  CreateNewPasswordScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  'Confirm Code',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Timer
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  const TextSpan(text: 'Resend code in '),
                  TextSpan(
                    text: '$_secondsRemaining s',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Resend Code
            GestureDetector(
              onTap: _secondsRemaining == 0
                  ? () {
                setState(() {
                  _secondsRemaining = 60;
                  startTimer();
                });
              }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn’t receive code? ", style: TextStyle(color: Colors.grey)),
                  Text(
                    'Resend Code',
                    style: TextStyle(
                      color: _secondsRemaining == 0 ? AppColors.primary : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}