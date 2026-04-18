import 'package:flutter/material.dart';

/// A loading screen with a gradient background and centered logo
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(124, 231, 255, 1),
              Color.fromRGBO(70, 79, 255, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 329,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset('assets/logo.png', width: 190, height: 195),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
