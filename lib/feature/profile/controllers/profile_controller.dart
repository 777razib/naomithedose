// controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// User Profile Model
class UserProfile {
  final String fullName;
  final String email;
  final String profileImage;

  UserProfile({
    this.fullName = '',
    this.email = '',
    this.profileImage = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'profileImage': profileImage,
  };
}

/// Profile Controller
class ProfileController extends GetxController {
  // Reactive Variables
  final Rx<UserProfile> userProfile = UserProfile().obs;
  final RxBool isLoading = false.obs;
  final RxBool pushNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile(); // Auto load on screen open
  }

  /// Fetch Profile (API or Mock)
  Future<void> getProfile() async {
    isLoading.value = true;
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Replace with real API call
      final mockData = {
        'fullName': 'John Doe',
        'email': 'john.doe@example.com',
        'profileImage': 'https://i.pravatar.cc/150?u=john',
      };

      userProfile.value = UserProfile.fromJson(mockData);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update Push Notification Toggle
  void setPushNotification(bool value) {
    pushNotificationEnabled.value = value;
    // TODO: Save to API or local storage
    Get.snackbar(
      'Updated',
      'Push notifications ${value ? 'enabled' : 'disabled'}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Logout User
  Future<bool> logout() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      // TODO: Call real logout API
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Logout failed', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete Account (Permanent)
  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      // TODO: Call real delete API
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}