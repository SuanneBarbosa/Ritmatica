import 'package:flutter/material.dart';
import 'package:ritmatica_app/user_interface/widgets/vlibras_widget.dart';

class TutorialStep {
  final GlobalKey key;
  final String text;
  final Alignment alignment;
  final EdgeInsets padding;
  final bool isInteractive;

  TutorialStep({
    required this.key,
    required this.text,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(8.0),
    this.isInteractive = false,
  });
}

class InteractiveTutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onFinish;
  final VoidCallback onSkip;
  final ValueChanged<int>? onStepChanged; // <-- NOVO: Comunica a troca de passo

  const InteractiveTutorialOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
    required this.onSkip,
    this.onStepChanged, // <-- NOVO
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHighlight();
      widget.onStepChanged?.call(_currentStep); // Informa o passo inicial
      Future.delayed(const Duration(milliseconds: 500), () {
        _announceCurrentStep();
      });
    });
  }

  @override
  void didUpdateWidget(covariant InteractiveTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateHighlight());
  }

  void _announceCurrentStep() {
    if (_currentStep < widget.steps.length) {
      final text = widget.steps[_currentStep].text;
      debugPrint("Ritmática Tutorial: Enviando para VLibras -> $text");
      VLibrasWidget.buscarTraducao(text);
    }
  }

  void _calculateHighlight() {
    if (!mounted) return;
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
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _calculateHighlight();
          widget.onStepChanged?.call(_currentStep); // Atualiza a tela principal
          _announceCurrentStep();
        },
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_highlightRect == null) {
      return const SizedBox.shrink();
    }

    final step = widget.steps[_currentStep];
    final bool isLastStep = _currentStep == widget.steps.length - 1;
    final bool isFirstStep = _currentStep == 0;

    return Stack(
      children:[
        // 1. Camada de Fundo Escuro (APARECE APENAS NA PARTE INFORMATIVA)
        if (!step.isInteractive)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Bloqueia toques no fundo
              child: CustomPaint(
                painter: HolePainter(hole: _highlightRect!.inflate(10.0)),
              ),
            ),
          ),
        
        // 2. Destaque Amarelo (APARECE APENAS NA PARTE PRÁTICA PARA GUIAR O CLIQUE)
        if (step.isInteractive)
          Positioned.fromRect(
            rect: _highlightRect!.inflate(8.0),
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent.shade700, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        
        // 3. Caixa de Texto de Orientação
        _buildGuidanceBox(step),

        // 4. Botões de Navegação
        if (!isLastStep) _buildNextButton(isFirstStep),
        if (!isLastStep) _buildSkipButton(),
        if (isLastStep) _buildFinishButton(),

        // 5. VLibras 
        const Positioned(
          bottom: 0,
          right: 0,
          child: ExcludeSemantics(
            child: VLibrasWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidanceBox(TutorialStep step) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = (screenWidth * 0.025).clamp(16.0, 24.0);
    final maxBoxWidth = screenWidth * 0.70;

    if (step.alignment == Alignment.center || _highlightRect == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: maxBoxWidth,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(left: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow:[
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
          ),
          child: Semantics(
            liveRegion: true,
            child: Text(
              step.text,
              style: TextStyle(
                inherit: false,
                fontSize: fontSize,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final rect = _highlightRect!;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isBelow = step.alignment == Alignment.topCenter;
    
    double top = isBelow ? rect.bottom + 20 : rect.top - 150;

    if (top < 10) top = 10;
    if (top > screenHeight - 150) top = screenHeight - 150;

    return Positioned(
      top: top,
      left: 30,
      width: maxBoxWidth - 30,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow:[
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
          ],
        ),
        child: Semantics(
          liveRegion: true,
          child: Text(
            step.text,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isFirstStep) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double btnFontSize = (screenWidth * 0.022).clamp(16.0, 28.0);
    final double padH = (screenWidth * 0.03).clamp(24.0, 50.0);
    final double padV = (screenWidth * 0.015).clamp(12.0, 24.0);

    return Positioned(
      bottom: 20,
      right: (screenWidth * 0.25) + 20, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: btnFontSize, 
            fontWeight: FontWeight.bold
          ),
        ),
        onPressed: _nextStep,
        child: Text(isFirstStep ? 'Começar' : 'Próximo'),
      ),
    );
  }

  Widget _buildFinishButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final double btnFontSize = (screenWidth * 0.022).clamp(16.0, 28.0);
    final double padH = (screenWidth * 0.03).clamp(24.0, 50.0);
    final double padV = (screenWidth * 0.015).clamp(12.0, 24.0);

    return Positioned(
      bottom: 20,
      right: (screenWidth * 0.25) + 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
           textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: btnFontSize, 
            fontWeight: FontWeight.bold
          ),
        ),
        onPressed: widget.onFinish,
        child: const Text('Finalizar'),
      ),
    );
  }

  Widget _buildSkipButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = (screenWidth * 0.022).clamp(16.0, 28.0);

    return Positioned(
      bottom: 20,
      left: 20,
      child: TextButton(
        onPressed: widget.onSkip,
        child: Text(
          'Pular Tutorial',
          style: TextStyle(
            inherit: true,
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: const[
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3,
                color: Colors.black,
              ),
            ],
          ),
        ),
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
    final screenPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath =
        Path()
          ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(15)));
    final path = Path.combine(PathOperation.difference, screenPath, holePath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HolePainter oldDelegate) {
    return oldDelegate.hole != hole;
  }
}