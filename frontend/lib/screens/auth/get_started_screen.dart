import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6B3),
      body: SafeArea(
        child: Column(
          children: [
            // Player image taking the entire top section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/player.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Bottom section with text and button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB8C657), Color(0xFFA4B84C)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Motivational text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 26,
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

                  const SizedBox(height: 30),

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
