import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/onboarding2.png', // Replace with your onboarding images
      'description': '',
    },
    {
      'image': 'assets/images/onboarding1.png',
      'description': 'Get Veterinary Help Anytime, Anywhere!',
    },
    {
      'image': 'assets/images/onboarding1.png',
      'description': 'Find and book nearby veterinarians easily to keep your livestock healthy and productive.',
    },
    {
      'image': 'assets/images/onboarding1.png',
      'description': 'Bringing Pet Owners Together with Trusted Veterinarians. Discover the finest care for your beloved pets.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final data = _onboardingData[index];
              return OnboardingPage(
                image: data['image']!,
                description: data['description']!,
                isLastPage: index == _onboardingData.length - 1,
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _currentPage == _onboardingData.length - 1
                ? SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the login screen
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text(
                        'Begin Your Journey',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(_onboardingData.length - 1);
                          },
                          child: const Text('SKIP'),
                        ),
                        Row(
                          children: List.generate(_onboardingData.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.teal
                                    : Colors.grey,
                              ),
                            );
                          }),
                        ),
                        TextButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: const Text('NEXT'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String description;
  final bool isLastPage;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.description,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          image,
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black.withOpacity(0.5), // Optional: Add a semi-transparent overlay
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png', // Replace with your logo image
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              if (isLastPage) ...[
                Image.asset(
                  'assets/images/Container.png', // Replace with your last onboarding image
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 20),
              ],
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
