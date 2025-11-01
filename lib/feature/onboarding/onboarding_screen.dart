import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naomithedose/core/style/text_style.dart';
import '../../core/app_colors.dart';
import '../auth/login/screen/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            // Centered Image
            Center(
              child: Container(
                height: 320,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/images/freepik__a-minimal-yet-captivating-digital-illustration-of-__61183 1.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              "Dive Deeper",
              style: globalTextStyle(
                color: AppColors.primary,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              "Discover voices that inspire, educate, and entertain",
              style: globalTextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Let's Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Let’s Start",
                  style: globalTextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lottie Animation - Always Running & Inside Column
            Expanded(
              child: Lottie.asset(
                'assets/lottie_json/Remix of wave (1).json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true, // Always running
              ),
            ),

            const SizedBox(height: 20), // Optional bottom padding
          ],
        ),
      ),
    );
  }
}