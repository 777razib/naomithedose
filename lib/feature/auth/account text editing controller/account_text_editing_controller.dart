import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountTextEditingController extends GetxController {
  static const int otpLength = 5;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final rollController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  // ✅ Renamed to avoid conflicts
  final List<TextEditingController> otpControllersList = List.generate(otpLength, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(otpLength, (index) => FocusNode());

  final agreeController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final fcmTokenController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool obscurePassword = true.obs;
  final RxBool hasPasswordError = false.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isEmailValid = false.obs;
  final RxBool isPhoneValid = false.obs;
  final RxString enteredOtp = ''.obs;

  // ✅ Getter for controllers
  List<TextEditingController> get controllers => otpControllersList;

  // ✅ Operator to access individual controllers
  TextEditingController operator [](int index) => otpControllersList[index];

  // ✅ Method to get complete OTP
  String getOtpString() {
    return otpControllersList.map((controller) => controller.text).join();
  }

  @override
  void onInit() {
    super.onInit();

    emailController.addListener(() {
      final isValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
          .hasMatch(emailController.text.trim());
      isEmailValid.value = isValid;
    });

    phoneController.addListener(() {
      final isValid = RegExp(r"^\d{6,}$").hasMatch(phoneController.text.trim());
      isPhoneValid.value = isValid;
    });
  }

 /* @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    rollController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    // Dispose OTP controllers
    for (var controller in otpControllersList) {
      controller.dispose();
    }

    // Dispose focus nodes
    for (var node in focusNodes) {
      node.dispose();
    }

    agreeController.dispose();
    dateOfBirthController.dispose();
    fcmTokenController.dispose();
    super.onClose();
  }*/
}