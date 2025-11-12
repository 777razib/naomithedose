import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naomithedose/core/style/text_style.dart';
import '../../core/app_colors.dart';
import '../auth/login/screen/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // যোগ করুন

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
      body: Column(
        children: [
          Padding(
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
                        "assets/images/water.jpg",
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
                    onPressed: () async {
                      // Onboarding দেখা হয়েছে → চিহ্নিত করুন
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('seen_onboarding', true);

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
              ],
            ),
          ),

          // Lottie Animation
          /*  Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.blue.withOpacity(0.1),
              child: Lottie.asset(
                'assets/lottie_json/wave_animation.json',
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        Text('Lottie Error', style: TextStyle(color: Colors.red)),
                        Text('$error', style: TextStyle(color: Colors.red, fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),*/
          Expanded(
            child: Lottie.asset(
              'assets/lottie_json/wave_animation.json',
              fit: BoxFit.fill,
              height: 380,
              width: double.infinity,
              repeat: true,
              animate: true, // Always running

            ),
          ),

        ],
      ),
    );
  }
}
