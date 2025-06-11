// visualizador_ritmo.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fracao_model.dart';
import '../../services/ritmo_provider.dart';


class VisualizadorRitmo extends StatelessWidget {
  const VisualizadorRitmo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RitmoProvider>(
      builder: (context, provider, child) {
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
                  estaTocandoGlobalmente: provider.estaTocandoGlobalmente,
                  offsetHorizontalTicks: provider.offsetHorizontalScroll,
                  canvasSize: constraints.biggest,
                  bolinhasMostradas: provider.bolinhasMostradas,
                ),
              ),
            );
          },
        );
      },
    );
  }
}



class PintorRitmo extends CustomPainter {
  final List<FracaoModel> fracoes;
  final int subdivisoesPorColuna;
  final bool estaTocandoGlobalmente;
  final double offsetHorizontalTicks;
  final Size canvasSize;
  final Map<String, int> bolinhasMostradas;

  static const double RAIO_BOLINHA = 7.0;
  static const double ESPACO_SEGMENTO = 7.0;
  static const double ESPESSURA_LINHA = 1.5;

  PintorRitmo({
    required this.fracoes,
    required this.subdivisoesPorColuna,
    required this.estaTocandoGlobalmente,
    required this.offsetHorizontalTicks,
    required this.canvasSize,
    required this.bolinhasMostradas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (subdivisoesPorColuna <= 0 || fracoes.isEmpty) return;

    final double larguraColuna = ESPACO_SEGMENTO * subdivisoesPorColuna;
    final double offsetX = -offsetHorizontalTicks * ESPACO_SEGMENTO;

    
    final Paint paintGrid = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double xStart = ((-offsetX / larguraColuna).floor()) * larguraColuna;
    if (larguraColuna > 0) {
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

      final int numBolinhasDestaFracao = bolinhasMostradas[fracao.id] ?? 0;
      if (numBolinhasDestaFracao <= 0) continue;

      final int cols = fracao.numerador!;
      final int bols = fracao.denominador!;
      final double blocoW = cols * larguraColuna;
      final double yCenter = margemV + alturaFaixa * row + alturaFaixa / 2;

      
      List<Offset> allPositions = [];
      for (int i = 0; i < numBolinhasDestaFracao; i++) {
        final int blocoIdx = i ~/ bols; 
        final double inicioXDoBloco = blocoIdx * blocoW; 
        final int bolinhaNoBlocoIdx = i % bols; 

        double posXnoMundo; 
        if (cols == bols) {
          posXnoMundo = inicioXDoBloco + (bolinhaNoBlocoIdx * larguraColuna);
        } else {
          final double fracaoPosNoBloco = (bolinhaNoBlocoIdx + 1.0) / bols;
          posXnoMundo = inicioXDoBloco + (fracaoPosNoBloco * blocoW);
        }

        final double posXnoCanvas = posXnoMundo + offsetX;
        allPositions.add(Offset(posXnoCanvas, yCenter));
      }

    
      if (allPositions.isEmpty) continue;

     
      final Paint paintLine = Paint()
        ..color = fracao.cor.withOpacity(0.8)
        ..strokeWidth = ESPESSURA_LINHA
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, yCenter), allPositions.last, paintLine);

     
      final Paint paintDot = Paint()..color = fracao.cor;
      for (final position in allPositions) {
      
        if (position.dx > -RAIO_BOLINHA && position.dx < size.width + RAIO_BOLINHA) {
          canvas.drawCircle(position, RAIO_BOLINHA, paintDot);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PintorRitmo old) {
    if (old.estaTocandoGlobalmente != estaTocandoGlobalmente) return true;
    if (old.offsetHorizontalTicks != offsetHorizontalTicks) return true;
    if (old.subdivisoesPorColuna != subdivisoesPorColuna) return true;

    for (var f in fracoes) {
      final oldCount = old.bolinhasMostradas[f.id] ?? 0;
      final newCount = bolinhasMostradas[f.id] ?? 0;
      if (oldCount != newCount) return true;
    }

    return false;
  }
}