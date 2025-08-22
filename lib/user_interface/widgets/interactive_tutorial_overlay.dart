import 'package:flutter/material.dart';

class TutorialStep {
  final GlobalKey key;
  final String text;
  final Alignment alignment;
  final EdgeInsets padding;

  TutorialStep({
    required this.key,
    required this.text,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(8.0),
  });
}

class InteractiveTutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  const InteractiveTutorialOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
    required this.onSkip,
  });

  @override
  State<InteractiveTutorialOverlay> createState() =>
      _InteractiveTutorialOverlayState();
}

class _InteractiveTutorialOverlayState extends State<InteractiveTutorialOverlay> {
  int _currentStep = 0;
  Rect? _highlightRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateHighlight());
  }

  void _calculateHighlight() {
    final key = widget.steps[_currentStep].key;
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      setState(() {
        _highlightRect = Rect.fromLTWH(
          offset.dx,
          offset.dy,
          size.width,
          size.height,
        );
      });
    }
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _calculateHighlight();
    } else {
      widget.onFinish();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _calculateHighlight();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_highlightRect == null) {
      return const SizedBox.shrink(); 
    }

    final step = widget.steps[_currentStep];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: HolePainter(
              hole: _highlightRect!.inflate(10.0), 
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: step.alignment,
              child: Padding(
                padding: step.padding,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      step.text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Pular Tutorial',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                Row(
                  children: [
                    if (_currentStep > 0)
                      ElevatedButton(
                        onPressed: _previousStep,
                        child: const Text('Anterior'),
                      ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(_currentStep == widget.steps.length - 1
                          ? 'Finalizar'
                          : 'Próximo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  final Rect hole;

  HolePainter({required this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.7);
    final screenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(15)));
    final path = Path.combine(PathOperation.difference, screenPath, holePath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HolePainter oldDelegate) {
    return oldDelegate.hole != hole;
  }
}