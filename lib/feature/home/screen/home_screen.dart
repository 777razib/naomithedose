import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../widget/ImageWidget.dart';
import '../widget/video_widget.dart';
import '../widget/view_video_and_details.dart';

class VideoModel {
  final String title;
  final String subTitle;
  final String date;
  final String videoUrl;
  final String category;

  VideoModel({
    required this.title,
    required this.subTitle,
    required this.date,
    required this.videoUrl,
    required this.category,
  });
}

// Mock API fetch (replace with real API call)
Future<List<VideoModel>> fetchVideos(String category) async {
  await Future.delayed(const Duration(seconds: 1)); // simulate network delay
  // Replace below with real API response mapping
  return [
    VideoModel(
      title: "$category Video 1",
      subTitle: "Subtitle 1",
      date: "2025-10-31",
      videoUrl: "https://www.example.com/video1.mp4",
      category: category,
    ),
    VideoModel(
      title: "$category Video 2",
      subTitle: "Subtitle 2",
      date: "2025-10-31",
      videoUrl: "https://www.example.com/video2.mp4",
      category: category,
    ),
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isVideo = false;
  int selectedIndex = 0;
  bool isLoading = false;
  List<VideoModel> videos = [];

  final List<String> categories = [
    "Business",
    "Education",
    "Comedy",
    "Fiction",
    "History",
  ];

  @override
  void initState() {
    super.initState();
    _loadVideos(categories[selectedIndex]);
  }

  void _loadVideos(String category) async {
    setState(() {
      isLoading = true;
      videos = [];
    });
    final result = await fetchVideos(category);
    setState(() {
      videos = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Image.asset(
                    "assets/icons/linly-high-resolution-logo 1.png",
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isVideo = !isVideo;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isVideo ? AppColors.primary : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: isVideo
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              "Video",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: isVideo
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal buttons + videos
          Expanded(
            child: Column(
              children: [
                // 🔹 Horizontal Category Buttons
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          _loadVideos(categories[index]);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.primary, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // 🔹 Show Selected Category Videos
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, i) {
                      final video = videos[i];
                      return ImageWidget(
                        title: video.title,
                        subTitle: video.subTitle,
                        date: video.date,
                        imageUrl: video.videoUrl,
                        onTap: () {
                          Get.to(ViewVideoAndDetails());
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
