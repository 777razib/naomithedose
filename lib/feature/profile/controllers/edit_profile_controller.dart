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