import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naomithedose/core/services_class/shared_preferences_data_helper.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../../../../core/services_class/shared_preferences_helper.dart';
import '../../account text editing controller/account_text_editing_controller.dart';
import '../../model/user_model.dart';

class OtpController extends GetxController {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  //UserModel? userModel;

 // final DataHelperController dataHelperController = Get.put(DataHelperController());
  final AccountTextEditingController accountTextEditingController = Get.put(AccountTextEditingController());

  /// ✅ Set email from previous step
 /* void setEmail(String email) {
    userModel = UserModel(email: email);
  }*/

  Future<bool> otpApiCallMethod() async {
    bool isSuccess = false;

    final email = accountTextEditingController.emailController.text.trim();
    final otpText = accountTextEditingController.otpControllersList;

    debugPrint("📧 Email: $email");
    debugPrint("🔢 OTP: $otpText");

    // Validation
    if (email == null || email.isEmpty) {
      _errorMessage = "Email is missing.";
      update();
      return false;
    }

    if (otpText.isEmpty ) {
      Get.snackbar("Error", "Invalid OTP format");
      return false;
    }

    try {
      Map<String, dynamic> mapBody = {
        "email": email,
        "otp": otpText,
        //"otp": int.parse(otpText),
      };

      debugPrint("📤 Sending request to ${Urls.authFVerifyOtp}");
      debugPrint("📦 Payload: $mapBody");

      final NetworkResponse response = await NetworkCall.postRequest(
        url: Urls.authFVerifyOtp,
        body: mapBody,
      );

      debugPrint("📥 RESPONSE Status: ${response.statusCode}");
      debugPrint("📥 RESPONSE Body: ${response.responseData}");

      if (response.isSuccess) {
        final data = response.responseData?['data'];

        final token = response.responseData!["access_token"];
        print("====$token");

        final updatedUser = UserModel.fromJson(data);
        await AuthController.setUserData(token, updatedUser);
        await SharedPreferencesHelper.saveAccessToken(token);
        await AuthController.getUserData();

        isSuccess = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.responseData?['message'] ?? "Unknown error";
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
      debugPrint("❌ OTP Exception: $e");
    }

    update();
    return isSuccess;
  }
}
