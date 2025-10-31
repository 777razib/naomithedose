import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/app_colors.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController controller = Get.put(EditProfileController());
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    await controller.getProfile();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: CustomAppBar(title:  Text('Personal Details')),
      body: _isInitialized ? _buildBody() : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),

          // Circular Profile Picture with Edit Icon
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(() {
                final userProfile = controller.userProfile.value;

                // If new image is selected, show it
                if (controller.newProfileImagePath.value.isNotEmpty) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(
                      File(controller.newProfileImagePath.value),
                    ),
                  );
                }

                // If no new image but profile has existing image
                if (userProfile.profileImage.isNotEmpty) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(userProfile.profileImage),
                  );
                }

                // Default placeholder
                return CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.account_circle,
                    size: 60,
                    color: AppColors.primary,
                  ),
                );
              }),

              // Camera icon to pick new image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          // White container with fields
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Name Field
                _buildFirstNameField(),
                SizedBox(height: 24),

                // Last Name Field
                _buildLastNameField(),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Save Button - Using GetBuilder instead of Obx for better control
          GetBuilder<EditProfileController>(
            builder: (controller) {
              final hasChanges = controller.hasChanges;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasChanges ? () => controller.updateProfile() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasChanges ? AppColors.primary : Colors.grey[400],
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Name',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.firstNameController,
          decoration: InputDecoration(
            hintText: 'Enter your first name',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Name',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.lastNameController,
          decoration: InputDecoration(
            hintText: 'Enter your last name',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      controller.setNewProfileImage(result.files.single.path!);
    }
  }
}