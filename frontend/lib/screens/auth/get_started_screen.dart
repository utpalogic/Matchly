import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6B3),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Soccer player illustration placeholder
            Expanded(
              flex: 8,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for image
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        size: 120,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Add your soccer player image here',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Path: assets/images/soccer_player.png',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section with text and button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB8C657), Color(0xFFA4B84C)],
                ),
              ),
              child: Column(
                children: [
                  // Motivational text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      children: [
                        const TextSpan(
                          text: 'TALK WITH YOUR ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'FEET\n',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        const TextSpan(
                          text: 'PLAY WITH YOUR ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'HEART',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Get Started button
                  CustomButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    icon: Icons.arrow_forward,
                    height: 60,
                    borderRadius: 30,
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
