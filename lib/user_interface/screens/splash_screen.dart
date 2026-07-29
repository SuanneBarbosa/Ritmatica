import 'dart:async';
import 'package:flutter/material.dart';
import 'enter_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool orientationShown;

  const SplashScreen({super.key, required this.orientationShown});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Fade in animation trigger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Auto navigate after 3 seconds
    _timer = Timer(const Duration(seconds: 3), _navigateToEnterScreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToEnterScreen() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => EnterScreen(orientationShown: widget.orientationShown),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Stack(
        children: [
          // Centered main logo with fade-in effect
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale:
                        _opacity == 1.0
                            ? 1.0
                            : 0.7, // Inicia em 0.7 do tamanho original e cresce até 1.0
                    duration: const Duration(milliseconds: 5000),
                    curve: Curves.easeOutBack,
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/image/logo/ritmatica.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.music_note_rounded,
                            size: 200,
                            color: Color(0xFF4F46E5),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Supporters logo in the bottom area (centered badge)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSupporterLogo('assets/image/CNPQ_Logo.png'),
                      const SizedBox(width: 16),
                      _buildSupporterLogo('assets/image/IFSP_Logo.png'),
                      const SizedBox(width: 16),
                      _buildSupporterLogo('assets/image/RUMO_Logo.png'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupporterLogo(String assetPath) {
    return Image.asset(
      assetPath,
      height: 56,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }
}
