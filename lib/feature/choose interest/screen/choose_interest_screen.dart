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
  // API থেকে আসা ডেটা (মক)
  final List<Map<String, dynamic>> interests = [
    {"id": 1, "name": "Travel", "image": "assets/interests/music.png"},
    {"id": 2, "name": "Sports", "image": "assets/interests/travel.png"},
    {"id": 3, "name": "Relationships", "image": "assets/interests/food.png"},
    {"id": 4, "name": "Science", "image": "assets/interests/sports.png"},
    {"id": 5, "name": "Geography", "image": "assets/interests/art.png"},
    {"id": 6, "name": "Mental Health", "image": "assets/interests/tech.png"},
    {"id": 7, "name": "Art", "image": "assets/interests/tech.png"},
    {"id": 8, "name": "History", "image": "assets/interests/tech.png"},
  ];

  final Set<int> selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFF3),

      // Body
      body: Column(
        children: [
          const SizedBox(height:90),

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

          // GridView - Expanded দিয়ে height fix
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
            onPressed: () {
              final selectedInterests = interests
                  .where((e) => selectedIds.contains(e['id']))
                  .toList();

              Get.to(() => const CustomBottomNavBar());
            },
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}