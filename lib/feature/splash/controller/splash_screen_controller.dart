// splash_screen_controller.dart
import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services_class/shared_preferences_helper.dart';
import '../../nav bar/screen/custom_bottom_nav_bar.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../auth/login/screen/signin_screen.dart'; // <-- Add this

class SplashScreenController extends GetxController {
  Future<void> checkIsLogin() async {
    // 1. Wait for login status
    bool? isLogin = await SharedPreferencesHelper.checkLogin();
    String? token = await SharedPreferencesHelper.getAccessToken();

    // 2. Splash delay
    await Future.delayed(const Duration(seconds: 3));

    print("------------Is Login: $isLogin | Token: $token");

    // 3. Navigation logic
    if (isLogin == true && token != null && token.isNotEmpty) {
      // User is logged in → Go to Home
      Get.offAll(() => const CustomBottomNavBar());
    } else {
      // Not logged in OR token expired
      final seenOnboarding = await _checkOnboardingSeen();

      if (!seenOnboarding) {
        Get.offAll(() => const OnboardingScreen());
      } else {
        Get.offAll(() => const SignInScreen());
        // Show toast only if token was expired but login was true
        if (isLogin == true) {
          EasyLoading.showToast(
            "Your session has expired. Please log in again.",
            duration: const Duration(seconds: 3),
            toastPosition: EasyLoadingToastPosition.bottom,
          );
        }
      }
    }
  }

  // Check if onboarding was seen
  Future<bool> _checkOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seen_onboarding') ?? false;
  }

  @override
  void onInit() {
    super.onInit();
    checkIsLogin();
  }
}