import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../auth/login/screen/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "desc": "A place to serve, share, and grow in faith together."
    },
    {
      "image": "assets/images/onboarding2.png",
      "desc": "Join a community that supports and uplifts you."
    },
    {
      "image": "assets/images/onboarding3.png",
      "desc": "Connect with others and strengthen your faith."
    },
    {
      "image": "assets/images/onboarding4.png",
      "desc": "Let’s walk together on this beautiful journey of faith."
    },
  ];

  void jumpToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// PageView section
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              return Stack(
                children: [
                  /// Background Image
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(onboardingData[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// Gradient Overlay + Text Section
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.33,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xCCC7EBF0),
                            Color(0xFFC7EBF0),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// ✅ Title with different colored word for each page
                            if (index == 0)
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "WELCOME",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    TextSpan(text: " TO OUR\nCHURCH COMMUNITY"),
                                  ],
                                ),
                              )
                            else if (index == 1)
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(text: "SERVE WITH\n"),
                                    TextSpan(
                                      text: "LOVE",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              )
                            else if (index == 2)
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(text: "GIVE WITH A GENEROUS\n"),
                                      TextSpan(
                                        text: "HEART",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "GROW ",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      TextSpan(text: "TOGETHER\nIN FAITH"),
                                    ],
                                  ),
                                ),

                            const SizedBox(height: 10),

                            /// Description
                            Text(
                              onboardingData[index]['desc']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          /// ✅ Dot Indicators
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                      (dotIndex) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentIndex == dotIndex ? 24 : 8,
                    decoration: BoxDecoration(
                      color: currentIndex == dotIndex
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// ✅ Next / Get Started Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 25, right: 25),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (currentIndex == onboardingData.length - 1) {
                      jumpToHome();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentIndex == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          /// ✅ Skip button
          if (currentIndex != onboardingData.length - 1)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 15),
                  child: TextButton(
                    onPressed: () {
                      _controller.animateToPage(
                        onboardingData.length - 1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
