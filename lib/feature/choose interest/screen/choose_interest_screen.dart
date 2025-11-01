
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../nav bar/screen/custom_bottom_nav_bar.dart';
import '../widget/choose_interest_widget.dart';

class ChooseInterestScreen extends StatefulWidget {
  const ChooseInterestScreen({super.key});

  @override
  State<ChooseInterestScreen> createState() => _ChooseInterestScreenState();
}

class _ChooseInterestScreenState extends State<ChooseInterestScreen> {
  final List<Map<String, dynamic>> interests = [
    {"id": 1, "name": "Travel", "image": "https://i.postimg.cc/GpZDNXwj/photo-1613064934056-08a061014f37.jpg"},
    {"id": 2, "name": "Sports", "image": "https://i.postimg.cc/q7fMHSqy/FINAL-Swimming.webp"},
    {"id": 3, "name": "Relationships", "image": "https://i.postimg.cc/PJcnzv8Z/ai-generated-man-in-love-gives-a-happy-woman-a-bouquet-of-roses-romantic-couple-on-a-date-on-a-blurr.jpg"},
    {"id": 4, "name": "Science", "image": "https://i.postimg.cc/TYM6wgGN/istockphoto-200445234-001-612x612.jpg"},
    {"id": 5, "name": "Geography", "image": "https://i.postimg.cc/pVKSs7MN/geography-scaled.jpg"},
    {"id": 6, "name": "Mental Health", "image": "https://i.postimg.cc/28641bwT/what-is-a-mental-health-nurse.jpg"},
    {"id": 7, "name": "Art", "image": "https://i.postimg.cc/YC2qrYz0/istockphoto-526685029-612x612.jpg"},
    {"id": 8, "name": "History", "image": "https://i.postimg.cc/tCTM9gV0/etty-cleopatra.jpg"},
  ];

  final Set<int> selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: Column(
        children: [
          const SizedBox(height: 90),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Pick your favorite topics to get started",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "“ Your voice, your choice — pick what moves you ”",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // GridView
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 183.5 / 142,
                ),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final item = interests[index];
                  final bool isSelected = selectedIds.contains(item['id']);

                  return ChooseInterestWidget(
                    image: item['image'],
                    text: item['name'],
                    isSelect: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedIds.remove(item['id']);
                        } else {
                          selectedIds.add(item['id']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // Continue Button (Only when selected)
      bottomNavigationBar: selectedIds.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _apiCallButton,
            child: const Text(
              "Continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }

  Future<void> _apiCallButton() async{




    final selectedInterests = interests
        .where((e) => selectedIds.contains(e['id']))
        .toList();


    // TODO: Save selected interests (e.g., to GetX controller or SharedPreferences)
    print("Selected: $selectedInterests");


    Get.offAll(() => const CustomBottomNavBar());

  }
}