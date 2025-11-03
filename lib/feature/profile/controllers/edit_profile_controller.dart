import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naomithedose/feature/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  // User profile observable
  final userProfile = UserProfile(
    fullName: '',
    email: '',
    profileImage: '',
  ).obs;

  // Text editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  
  // For profile image handling
  final newProfileImagePath = ''.obs;
  
  // For push notifications toggle
  final pushNotificationEnabled = true.obs;

  // Track original values for comparison
  String _originalFirstName = '';
  String _originalLastName = '';
  String _originalProfileImage = '';

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Add listeners to detect changes
    firstNameController.addListener(_onTextChanged);
    lastNameController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Force update to refresh the UI
    update();
  }

  @override
  void onClose() {
    firstNameController.removeListener(_onTextChanged);
    lastNameController.removeListener(_onTextChanged);
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  // Simulate loading profile data
  Future<void> getProfile() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    userProfile.value = UserProfile(
      fullName: 'John Doe',
      email: 'john.doe@example.com',
      profileImage: '',
    );
    
    // Populate first and last name controllers
    _populateNameControllers();
    
    // Store original values
    _storeOriginalValues();
  }

  // Helper method to populate name controllers from full name
  void _populateNameControllers() {
    if (userProfile.value.fullName.isNotEmpty) {
      List<String> nameParts = userProfile.value.fullName.split(' ');
      firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
      lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    } else {
      firstNameController.clear();
      lastNameController.clear();
    }
  }

  // Store original values for comparison
  void _storeOriginalValues() {
    if (userProfile.value.fullName.isNotEmpty) {
      List<String> nameParts = userProfile.value.fullName.split(' ');
      _originalFirstName = nameParts.isNotEmpty ? nameParts[0] : '';
      _originalLastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }
    _originalProfileImage = userProfile.value.profileImage;
  }

  // Set new profile image path
  void setNewProfileImage(String imagePath) {
    newProfileImagePath.value = imagePath;
    update(); // Force UI update
  }

  // Update profile method
  void updateProfile() {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    
    // Validate inputs
    if (firstName.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your first name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (lastName.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your last name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String fullName = '$firstName $lastName'.trim();

    // Simulate API call for update
    Future.delayed(Duration(seconds: 1), () {
      // Update user profile with new data
      userProfile.value = UserProfile(
        fullName: fullName,
        email: userProfile.value.email,
        profileImage: newProfileImagePath.value.isNotEmpty 
            ? newProfileImagePath.value 
            : userProfile.value.profileImage,
      );

      // Update original values
      _storeOriginalValues();
      
      // Clear the new image path after update
      newProfileImagePath.value = '';

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  // Toggle push notifications
  void setPushNotification(bool value) {
    pushNotificationEnabled.value = value;
  }

  // Simulate logout process
  Future<bool> logout() async {
    // Simulate logout API call
    await Future.delayed(Duration(seconds: 1));
    
    // Clear user data
    userProfile.value = UserProfile(
      fullName: '',
      email: '',
      profileImage: '',
    );
    
    // Clear controllers
    firstNameController.clear();
    lastNameController.clear();
    newProfileImagePath.value = '';
    
    // Clear original values
    _originalFirstName = '';
    _originalLastName = '';
    _originalProfileImage = '';
    
    return true;
  }

  // Method to check if profile has changes
  bool get hasChanges {
    final currentFirstName = firstNameController.text.trim();
    final currentLastName = lastNameController.text.trim();
    
    bool nameChanged = currentFirstName != _originalFirstName || 
                      currentLastName != _originalLastName;
    
    bool imageChanged = newProfileImagePath.value.isNotEmpty;
    
    return nameChanged || imageChanged;
  }

  // Method to reset changes
  void resetChanges() {
    _populateNameControllers();
    newProfileImagePath.value = '';
    update(); // Force UI update
  }
}
/*
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../model/user_data_model.dart';

class UpdateProfileController extends GetxController {
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  var userData = Rxn<UserDataModel>(); // ✅ Store user profile here

  var selectedImage = Rxn<File>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  var errorMessage = ''.obs;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> updateUserProfile() async {
    try {
      EasyLoading.show(status: "Loading...");

      final url = Uri.parse("${Urls.baseUrl}/users/update-profile");
      final token =  AuthController.accessToken;


      print("=============$token");
      Map<String, String> headers = {
        'Authorization': "$token",
      };

      var request = http.MultipartRequest('PATCH', url);
      request.fields.addAll({
        'data': jsonEncode({
          "fullName": fullNameController.text,
          "email": emailController.text,
        })
      });

      if (selectedImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', selectedImage.value!.path),
        );
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Response: $responseBody");

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(responseBody);

        if (jsonRes["success"] == true && jsonRes["data"] != null) {
          final updatedProfile = UserDataModel.fromJson(jsonRes["data"]);

          // ✅ Update observable
          userData.value = updatedProfile;

          // ✅ Update controllers
          fullNameController.text = updatedProfile.fullName;
          emailController.text = updatedProfile.email ?? '';
        }

        EasyLoading.showSuccess("Profile updated successfully");
      } else {
        EasyLoading.showError("Failed: ${response.reasonPhrase}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  Future<UserDataModel?> fetchMyProfile() async {
    EasyLoading.show(status: 'Fetching profile...');
    try {
      final token = AuthController.accessToken;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse("${Urls.baseUrl}/users/get-me"),
        headers: {"Authorization": token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonRes = jsonDecode(response.body);
        if (jsonRes["success"] == true) {
          final model = UserDataModel.fromJson(jsonRes["data"]);

          userData.value = model;

          // ✅ populate controllers
          fullNameController.text = model.fullName;
          emailController.text = model.email ?? '';

          return model;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Fetch profile error: $e");
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

*/