import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shimmer/shimmer.dart';

import '../../../core/app_colors.dart';
import '../controllers/profile_controller.dart';
import 'donation_history.dart';
import 'donation_screen.dart';
import 'edit_profile_screen.dart' show EditProfilePage;
import 'event_screen.dart';
import 'notepad_screen.dart'; // For shimmer loading effect

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key}) {
    // Initialize the controller only once when ProfileScreen is called
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    // Fetch the profile when the screen is initialized
    controller.getProfile();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60), // Top padding
            // Profile Header Section
            Obx(() {
              // Check if the profile is loaded
              if (controller.userProfile.value.fullName.isEmpty) {
                return _buildShimmerProfile(); // Show shimmer loading effect
              }

              final userProfile = controller.userProfile.value;

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: userProfile.profileImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(userProfile.profileImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: userProfile.profileImage.isEmpty
                          ? Icon(
                              Icons.account_circle,
                              size: 80,
                              color: AppColors.primary,
                            )
                          : null,
                    ),

                    SizedBox(width: 16),

                    // Name and Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            userProfile.fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),

                          // Email
                          Text(
                            userProfile.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 24),

            // Menu Items
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  // Shimmer effect for profile image, name, and location while loading
  Widget _buildShimmerProfile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Shimmer for Profile Picture
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
            SizedBox(width: 16),
            // Shimmer for Name and Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer for Name
                  Container(
                    width: 150,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 8),
                  // Shimmer for Email
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final personalInfoItems = [
      _MenuItem(
        title: 'Personal Details',
        iconPath: 'assets/icons/profile.png',
        onTap: () {
          Get.to(() => EditProfilePage());
        },
      ),
      _MenuItem(
        title: 'View events',
        iconPath: 'assets/icons/calender.png',
        onTap: () {
          Get.to(() => EventsPage());
        },
      ),
      _MenuItem(
        title: 'Donation',
        iconPath: 'assets/icons/donation.png',
        onTap: () {
          Get.to( () => DonationPage());
        },
      ),
      _MenuItem(
        title: 'Donation History',
        iconPath: 'assets/icons/history.png',
        onTap: () {
          Get.to( () => DonationHistoryScreen());
        },
      ),
      _MenuItem(
        title: 'Notepad',
        iconPath: 'assets/icons/note.png',
        onTap: () {
          Get.to( () => NotepadScreen());
        },
      ),
    ];

    final logoutItem = _MenuItem(
      title: 'Log Out',
      iconPath: 'assets/icons/logout.png', // You can add a logout icon asset if needed
      isLogout: true,
      onTap: () {
        _showLogoutDialog(context);
      },
    );

    return Column(
      children: [
        // Personal Info Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Info Label
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                'Personal info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 8),
            // Personal Info Menu Items
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  // Personal info items
                  ...List.generate(personalInfoItems.length, (index) {
                    final item = personalInfoItems[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            item.iconPath!,
                            width: 20,
                            height: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      onTap: item.onTap,
                    );
                  }),
                  // Logout item
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          logoutItem.iconPath!,
                          width: 20,
                          height: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    title: Text(
                      logoutItem.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    onTap: logoutItem.onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final controller = Get.find<ProfileController>();
                
                // Simulate logout
                bool isSuccess = await controller.logout();
                if (isSuccess) {
                  print('User logged out successfully');
                  
                  // Clear controller if needed
                  try {
                    if (Get.isRegistered<ProfileController>()) {
                      Get.delete<ProfileController>(force: true);
                      print('Profile controller cleared');
                    }
                  } catch (e) {
                    print('Controller cleanup error: $e');
                  }
                  
                  // Show success message
                  Get.snackbar(
                    'Success',
                    'Logged out successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  print('Error logging out');
                  Get.snackbar(
                    'Error',
                    'There was an issue logging you out.',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// MenuItem class for holding the menu item data
class _MenuItem {
  final String title;
  final String? iconPath;
  final bool isLogout;
  final bool hasToggle;
  final Function()? onTap;

  _MenuItem({
    required this.title,
    this.iconPath,
    this.isLogout = false,
    this.hasToggle = false,
    this.onTap,
  });
}