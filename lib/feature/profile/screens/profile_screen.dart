import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../widget/about_us_widget.dart';
import '../widget/privacy_policy_widget.dart';
import 'edit_profile_screen.dart' show EditProfilePage;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only once
    final controller = Get.put(ProfileController());

    // Fetch profile only once
    ever(controller.userProfile, (_) {});
    controller.getProfile();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // Profile Header
            Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerProfile();
              }

              final user = controller.userProfile.value;
              final hasProfile = user.fullName.isNotEmpty;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    ClipOval(
                      child: user.profileImage.isNotEmpty
                          ? Image.network(
                        user.profileImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(),
                      )
                          : _buildPlaceholderAvatar(),
                    ),

                    const SizedBox(width: 16),

                    // Name & Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasProfile ? user.fullName : 'Guest User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasProfile ? user.email : 'Login to see profile',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit Icon
                    if (hasProfile)
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => Get.to(() =>  EditProfilePage()),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Menu Section
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  // Placeholder Avatar
  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  // Shimmer Profile
  Widget _buildShimmerProfile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(width: 80, height: 80, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 120, height: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menu Section
  Widget _buildMenuSection(BuildContext context) {
    final personalItems = [
      _MenuItem(
        title: 'Personal Details',
        icon: Icons.person_outline,
        onTap: () => Get.to(() =>  EditProfilePage()),
      ),
      _MenuItem(
        title: 'About Us',
        icon: Icons.info_outline,
        onTap: () => Get.to(() => const AboutUsWidget()),
      ),
      _MenuItem(
        title: 'Privacy Policy',
        icon: Icons.privacy_tip_outlined,
        onTap: () => Get.to(() => const PrivacyPolicyWidget()),
      ),
    ];

    final dangerItems = [
      _MenuItem(
        title: 'Log Out',
        icon: Icons.logout,
        isDanger: true,
        onTap: () => _showLogoutDialog(context),
      ),
      _MenuItem(
        title: 'Delete Account',
        icon: Icons.delete_forever,
        isDanger: true,
        onTap: () => _showDeleteDialog(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Info
        _buildMenuCard(
          title: "Personal Info",
          items: personalItems,
        ),

        const SizedBox(height: 16),

        // Danger Zone
        _buildMenuCard(
          title: "Account Actions",
          items: dangerItems,
          isDanger: true,
        ),
      ],
    );
  }

  // Reusable Menu Card
  Widget _buildMenuCard({
    required String title,
    required List<_MenuItem> items,
    bool isDanger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDanger ? Colors.red.shade700 : Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.isDanger ? Colors.red.shade50 : Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: item.isDanger ? Colors.red : AppColors.primary,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: item.isDanger ? Colors.red : Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 56, thickness: 0.5),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await Get.find<ProfileController>().logout();
              if (success) {
                Get.snackbar('Success', 'Logged out successfully',
                    backgroundColor: Colors.green, colorText: Colors.white);
                Get.offAllNamed('/login'); // Replace with your login route
              } else {
                Get.snackbar('Error', 'Logout failed', backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Delete Account Dialog
  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account'),
        content: const Text('This action is permanent. All your data will be deleted.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              // Call delete API
              final success = await Get.find<ProfileController>().deleteAccount();
              if (success) {
                Get.snackbar('Deleted', 'Account deleted', backgroundColor: Colors.red, colorText: Colors.white);
                Get.offAllNamed('/login');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Menu Item Model
class _MenuItem {
  final String title;
  final IconData icon;
  final bool isDanger;
  final VoidCallback onTap;

  _MenuItem({
    required this.title,
    required this.icon,
    this.isDanger = false,
    required this.onTap,
  });
}