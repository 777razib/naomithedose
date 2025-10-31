import 'package:flutter/material.dart';

class PodcastDescriptionScreen extends StatefulWidget {
  const PodcastDescriptionScreen({super.key});

  @override
  State<PodcastDescriptionScreen> createState() => _PodcastDescriptionScreenState();
}

class _PodcastDescriptionScreenState extends State<PodcastDescriptionScreen> {
  final String podcastTitle = "The Next Big Move";
  final String podcastAuthor = "By Tanishk Bagchi";
  final String podcastImage =
      "https://images.unsplash.com/photo-1571330735066-03aaa9429d89?q=80&w=1000&auto=format&fit=crop";

  final String description =
      "In this episode, we explore how innovation drives the next wave of business success. At 02:15, Tanishk shares insights into leadership strategies for creative teams. Later at 12:48, we discuss the balance between technology and human connection, and how brands can thrive in the digital age.";

  bool isPlaying = true;
  String query = "";
  List<String> matchedSentences = [];

  // Function to search the keyword in the description
  void _searchInDescription(String keyword) {
    setState(() {
      query = keyword.trim().toLowerCase();
      matchedSentences.clear();

      if (query.isEmpty) return;

      final sentences = description.split(RegExp(r'\. '));
      for (var sentence in sentences) {
        if (sentence.toLowerCase().contains(query)) {
          matchedSentences.add(sentence.trim());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFF3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Podcast Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: _searchInDescription,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Search podcasts...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Image + Title + Subtitle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          podcastImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              podcastTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              podcastAuthor,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description paragraph with teal timestamps
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                            text:
                                'In this episode, we explore how innovation drives the next wave of business success. At '),
                        TextSpan(
                          text: '02:15',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                            text:
                                ', Tanishk shares insights into leadership strategies for creative teams. Later at '),
                        TextSpan(
                          text: '12:48',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                            text:
                                ', we discuss the balance between technology and human connection, and how brands can thrive in the digital age.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Show search results if any
                  if (query.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Search Key information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (matchedSentences.isEmpty)
                          const Text(
                            "No matches found.",
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ...matchedSentences.map((sentence) {
                            // highlight the matching word in teal
                            final start = sentence.toLowerCase().indexOf(query);
                            final end = start + query.length;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                  children: [
                                    TextSpan(text: sentence.substring(0, start)),
                                    TextSpan(
                                      text: sentence.substring(start, end),
                                      style: const TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: sentence.substring(end)),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Currently Playing Card
      bottomSheet: Container(
        height: 80,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Podcast Image
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(podcastImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Podcast Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcastTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '23:15',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Host: Tanishk',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats and Play Button
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  // Eye Icon with count
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '1.2K',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Vertical separator line
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 16),

                  // Play/Pause Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
