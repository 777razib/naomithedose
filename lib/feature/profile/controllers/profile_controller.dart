// Controller for profile screen (for future API integration)
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProfileController extends GetxController {
  // Mock user data for UI demonstration
  final userProfile = UserProfile(
    fullName: 'John Doe',
    email: 'john.doe@example.com',
    profileImage: '', // Empty for placeholder icon
  ).obs;

  final pushNotificationEnabled = true.obs;

  // Simulate loading data
  void getProfile() {
    // Simulate API call delay
    Future.delayed(Duration(seconds: 2), () {
      userProfile.value = UserProfile(
        fullName: 'John Doe',
        email: 'john.doe@example.com',
        profileImage: '', // You can add a mock image URL here if needed
      );
    });
  }

  void setPushNotification(bool value) {
    pushNotificationEnabled.value = value;
  }

  // Mock logout function
  Future<bool> logout() async {
    // Simulate logout process
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}

// User profile model
class UserProfile {
  final String fullName;
  final String email;
  final String profileImage;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.profileImage,
  });
}