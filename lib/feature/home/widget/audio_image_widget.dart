// widget/AudioImageWidget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class AudioImageWidget extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? date;
  final String? episodes;
  final String imageUrl;
  final VoidCallback onTap;

  const AudioImageWidget({
    super.key,
    this.title,
    this.subTitle,
    this.date,
    required this.imageUrl,
    required this.onTap,
    this.episodes,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive width
    final screenWidth = MediaQuery.of(context).size.width;
    final widgetWidth = screenWidth > 400 ? 327.0 : (screenWidth - 48) / 2; // 2 columns
    final imageHeight = widgetWidth * (144 / 327);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: widgetWidth,
        margin: EdgeInsets.zero, // GridView handles spacing
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Height Image
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: imageHeight,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.music_note, size: 40, color: Colors.grey),
                      ),
                    ),
                    // Play Icon
                    /*const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),

              // Text Section - Fixed Height to prevent overflow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    if (title != null && title!.isNotEmpty)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),

                    // Subtitle
                    if (subTitle != null && subTitle!.isNotEmpty)
                      Text(
                        subTitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),

                    Row(children: [
// Date
                      if (episodes != null && episodes!.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            episodes!,
                            style:  TextStyle(
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),

                      // Date
                      if (date != null && date!.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            date!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}