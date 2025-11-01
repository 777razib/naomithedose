/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller_AccountTextEditingController/AccountTextEditingController.dart';

class AddNewPassword extends GetxController {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? userModel;

  final DataHelperController dataHelperController = Get.put(DataHelperController());
  final AccountTextEditingController accountTextEditingController = Get.put(AccountTextEditingController());

  /// ✅ Set email from previous step
  void setEmail(String email) {
    userModel = UserModel(email: email);
  }

  Future<bool> addNewPasswordApiCallMethod() async {
    bool isSuccess = false;

    final email = userModel?.email?.trim();
    final changePasswordText = accountTextEditingController.passwordController.text;

    debugPrint("📧 Email: $email");
    debugPrint("🔢 OTP: $changePasswordText");

    // Validation
    if (email == null || email.isEmpty) {
      _errorMessage = "Email is missing.";
      update();
      return false;
    }

    if (changePasswordText.isEmpty || changePasswordText == null) {
      Get.snackbar("Error", "Invalid OTP format");
      return false;
    }

    try {
      Map<String, dynamic> mapBody = {
        "email": email,
        "password": changePasswordText,
      };

      debugPrint("📤 Sending request to ${NetworkPath.resetPassword}");
      debugPrint("📦 Payload: $mapBody");

      final NetworkResponse response = await NetworkCall.postRequest(
        url: NetworkPath.resetPassword,
        body: mapBody,
      );

      debugPrint("📥 RESPONSE Status: ${response.statusCode}");
      debugPrint("📥 RESPONSE Body: ${response.responseData}");

      if (response.isSuccess) {
        final data = response.responseData?['data'];
        final token = dataHelperController.accessToken ?? '';
        print("====$token");

        final updatedUser = UserModel.fromJson(data);
        await dataHelperController.saveUserData(token, updatedUser);
        await dataHelperController.getUserData();

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
}*/
