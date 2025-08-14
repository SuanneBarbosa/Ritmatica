import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fracao_model.dart';
import '../../services/ritmo_provider.dart';


class VisualizadorRitmo extends StatefulWidget {
    final bool estaTocando; 
  const VisualizadorRitmo({super.key,
    required this.estaTocando,});


  @override
  State<VisualizadorRitmo> createState() => _VisualizadorRitmoState();
}

class _VisualizadorRitmoState extends State<VisualizadorRitmo>
    with TickerProviderStateMixin {
 
  late Map<String, AnimationController> _controllers;
 
  late Map<String, int> _previousBolinhasMostradas;


  @override
  void initState() {
    super.initState();
    _controllers = {};
    _previousBolinhasMostradas = {};
   
   
    final provider = Provider.of<RitmoProvider>(context, listen: false);
    for (var fracao in provider.fracoes) {
      _criarControllerParaFracao(fracao, provider);
    }
  }


 
  void _criarControllerParaFracao(FracaoModel fracao, RitmoProvider provider) {
   
    final intervalo = provider.getIntervaloMsPorId(fracao.id);


    _controllers[fracao.id] = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: intervalo > 0 ? intervalo : 1000), 
    );
  
    _previousBolinhasMostradas[fracao.id] = provider.bolinhasMostradas[fracao.id] ?? 0;
  }
 
  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<RitmoProvider>(context);
    for (var fracao in provider.fracoes) {
      final controller = _controllers[fracao.id];
      if (controller == null) continue; 
      if (widget.estaTocando) {
       
        if (!controller.isAnimating && controller.value > 0.0 && controller.value < 1.0) {
      
          controller.forward(); 
        }
      } else {
        
        if (controller.isAnimating) {
          controller.stop();
        }
      }

      final atual = provider.bolinhasMostradas[fracao.id] ?? 0;
      final anterior = _previousBolinhasMostradas[fracao.id] ?? 0;

      if (atual > anterior) {
        final intervalo = provider.getIntervaloMsPorId(fracao.id);
        controller.duration =
            Duration(milliseconds: intervalo > 0 ? intervalo : 1000);
      
        controller.forward(from: 0.0);
      }
      
      _previousBolinhasMostradas[fracao.id] = atual;
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RitmoProvider>(context, listen: false);
    final repaintListenable = Listenable.merge(_controllers.values.toList());

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          height: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: CustomPaint(
            painter: PintorRitmo(
              fracoes: provider.fracoes,
              subdivisoesPorColuna: provider.subdivisoesPorColunaVisual,
              offsetHorizontalTicks: provider.offsetHorizontalScroll,
              canvasSize: constraints.biggest,
              bolinhasMostradas: provider.bolinhasMostradas,
              // animationProgress: animationProgress,
              controllers: _controllers, 
              repaint: repaintListenable,
            ),
           
          ),
        );
      },
    );
  }
}

class PintorRitmo extends CustomPainter {
  final List<FracaoModel> fracoes;
  final int subdivisoesPorColuna;
  final double offsetHorizontalTicks;
  final Size canvasSize;
  final Map<String, int> bolinhasMostradas;
  final Map<String, AnimationController> controllers;
  static const double RAIO_BOLINHA = 7.0;
  static const double ESPACO_SEGMENTO = 7.0;
  static const double ESPESSURA_LINHA = 1.5;


  PintorRitmo({
    required this.fracoes,
    required this.subdivisoesPorColuna,
    // required this.estaTocandoGlobalmente,
    required this.offsetHorizontalTicks,
    required this.canvasSize,
    required this.bolinhasMostradas,
     required this.controllers,
      required Listenable repaint, 
     
    // required this.animationProgress,
  }) : super(repaint: repaint);




   Offset _getPosicaoBolinha(int index, FracaoModel fracao, double yCenter, double larguraColuna, double offsetX) {
      final int cols = fracao.numerador!;
      final int bols = fracao.denominador!;
      final double blocoW = cols * larguraColuna;


      final int blocoIdx = index ~/ bols;
      final double inicioXDoBloco = blocoIdx * blocoW;
      final int bolinhaNoBlocoIdx = index % bols;


      double posXnoMundo;
       if (cols == bols) {
      posXnoMundo = inicioXDoBloco + ((bolinhaNoBlocoIdx + 1) * larguraColuna);
    } else {
      final double fracaoPosNoBloco = (bolinhaNoBlocoIdx + 1.0) / bols;
      posXnoMundo = inicioXDoBloco + (fracaoPosNoBloco * blocoW);
    }
    final double posXnoCanvas = posXnoMundo + offsetX;
    return Offset(posXnoCanvas, yCenter);
  }


  @override
  void paint(Canvas canvas, Size size) {
    if (subdivisoesPorColuna <= 0 || fracoes.isEmpty) return;


    final double larguraColuna = ESPACO_SEGMENTO * subdivisoesPorColuna;
    final double offsetX = -offsetHorizontalTicks * ESPACO_SEGMENTO;
    final Paint paintGrid = Paint()..color = Colors.white..strokeWidth = 1.0..style = PaintingStyle.stroke;
    if (larguraColuna > 0) {
      double xStart = ((-offsetX / larguraColuna).floor()) * larguraColuna;
       for (double x = xStart; x < -offsetX + size.width + larguraColuna; x += larguraColuna) {
        double xCanvas = x + offsetX;
        if (xCanvas >= -larguraColuna && xCanvas <= size.width + larguraColuna) {
          for (double y = 0; y < size.height; y += 10) {
            canvas.drawLine(Offset(xCanvas, y), Offset(xCanvas, y + 5), paintGrid);
          }
        }
      }
     }


    final double alturaTotal = size.height * 0.9;
    final double margemV = size.height * 0.1 / 2;
    final double alturaFaixa = alturaTotal / fracoes.length;


    for (int row = 0; row < fracoes.length; row++) {
      final fracao = fracoes[row];
      if (fracao.numerador == null || fracao.denominador == null) continue;
      final int numBolinhasTotal = bolinhasMostradas[fracao.id] ?? 0;
      if (numBolinhasTotal <= 0) continue;
      final double yCenter = margemV + alturaFaixa * row + alturaFaixa / 2;
      final double progress = controllers[fracao.id]?.value ?? 0.0;
     
      Offset posAnterior, posProxima;


      if (numBolinhasTotal == 1) {
     
        posAnterior = Offset(0, yCenter);
        posProxima = _getPosicaoBolinha(0, fracao, yCenter, larguraColuna, offsetX);
      } else {
     
        posAnterior = _getPosicaoBolinha(numBolinhasTotal - 2, fracao, yCenter, larguraColuna, offsetX);
        posProxima = _getPosicaoBolinha(numBolinhasTotal - 1, fracao, yCenter, larguraColuna, offsetX);
      }
     
    
      final Offset pontoFinalDaLinha = Offset.lerp(posAnterior, posProxima, progress)!;
      final Paint paintLine = Paint()..color = fracao.cor.withOpacity(0.8)..strokeWidth = ESPESSURA_LINHA..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(0, yCenter), pontoFinalDaLinha, paintLine);

      final int numBolinhasCompletas = numBolinhasTotal - 1;
      final Paint paintDot = Paint()..color = fracao.cor;
      for (int i = 0; i < numBolinhasCompletas; i++) {
        final position = _getPosicaoBolinha(i, fracao, yCenter, larguraColuna, offsetX);
        if (position.dx > -RAIO_BOLINHA && position.dx < size.width + RAIO_BOLINHA) {
          canvas.drawCircle(position, RAIO_BOLINHA, paintDot);
        }
      }
     
   
      if (progress >= 1.0) {
        final position = _getPosicaoBolinha(numBolinhasTotal - 1, fracao, yCenter, larguraColuna, offsetX);
        if (position.dx > -RAIO_BOLINHA && position.dx < size.width + RAIO_BOLINHA) {
          canvas.drawCircle(position, RAIO_BOLINHA, paintDot);
        }
      }
    }
  }


  @override
  bool shouldRepaint(covariant PintorRitmo old) {
    return old.offsetHorizontalTicks != offsetHorizontalTicks ||
           old.subdivisoesPorColuna != subdivisoesPorColuna ||
           old.bolinhasMostradas != bolinhasMostradas;
  }
}
