import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../home/widget/audio_image_widget.dart';
import '../../home/widget/video_image_widget.dart';
import '../../home/widget/view_video_and_details.dart';

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

// Mock API fetch
Future<List<VideoModel>> fetchVideos(String category) async {
  await Future.delayed(const Duration(seconds: 1));
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
    VideoModel(
      title: "$category Audio 3",
      subTitle: "Audio Subtitle",
      date: "2025-10-30",
      videoUrl: "https://www.example.com/audio3.mp3",
      category: category,
    ),
  ];
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isVideo = true;
  int selectedIndex = 0;
  bool isLoading = false;
  List<VideoModel> allVideos = [];
  List<VideoModel> filteredVideos = [];

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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadVideos(String category) async {
    setState(() {
      isLoading = true;
    });
    final result = await fetchVideos(category);
    setState(() {
      allVideos = result;
      filteredVideos = result;
      isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredVideos = allVideos.where((video) {
        final matchesType = isVideo
            ? video.videoUrl.contains('.mp4') || video.title.contains('Video')
            : video.videoUrl.contains('.mp3') || video.title.contains('Audio');
        final matchesQuery = video.title.toLowerCase().contains(query) ||
            video.subTitle.toLowerCase().contains(query);
        return matchesType && matchesQuery;
      }).toList();
    });
  }

  void _onCategoryChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
    _loadVideos(categories[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: Column(
        children: [
          const SizedBox(height: 60),

          // Search Bar + Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E9DC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search videos or audios...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search, color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Toggle Button
                GestureDetector(
                  onTap: () => setState(() => isVideo = !isVideo),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: isVideo ? Alignment.centerLeft : Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              isVideo ? "Video" : "Audio",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: isVideo ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
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

          const SizedBox(height: 16),

          // Category Buttons
          SizedBox(
            height: 45,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => _onCategoryChanged(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Content: ListView or GridView
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredVideos.isEmpty
                ? Center(
              child: Text(
                "No results found",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
                : isVideo
                ? _buildVideoList()
                : _buildAudioGrid(),
          ),
        ],
      ),
    );
  }

  // Video: ListView
  Widget _buildVideoList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredVideos.length,
      itemBuilder: (context, i) {
        final video = filteredVideos[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VideoImageWidget(
            title: video.title,
            subTitle: video.subTitle,
            date: video.date,
            imageUrl: video.videoUrl,
            onTap: () => Get.to(() => ViewVideoAndDetails()),
          ),
        );
      },
    );
  }

  // Audio: GridView
  Widget _buildAudioGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: filteredVideos.length,
      itemBuilder: (context, i) {
        final video = filteredVideos[i];
        return AudioImageWidget(
          title: video.title,
          subTitle: video.subTitle,
          date: video.date,
          imageUrl: "https://via.placeholder.com/327x144",
          onTap: () => Get.to(() => ViewVideoAndDetails()),
        );
      },
    );
  }
}