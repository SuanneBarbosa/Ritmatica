// visualizador_ritmo.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fracao_model.dart';
import '../../services/ritmo_provider.dart';
import 'dart:math';

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
                  circleIndex: provider.batidaAtual,
                  subdivisoesPorColuna: provider.subdivisoesPorColunaVisual,
                  estaTocandoGlobalmente: provider.estaTocandoGlobalmente,
                  offsetHorizontalTicks: provider.offsetHorizontalScroll,
                  canvasSize: constraints.biggest,
                  bolinhasMostradas: provider.bolinhasMostradas, // novo campo obrigatório
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
  final int circleIndex; // quantidade de bolinhas já exibidas
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
    required this.circleIndex,
    required this.subdivisoesPorColuna,
    required this.estaTocandoGlobalmente,
    required this.offsetHorizontalTicks,
    required this.canvasSize,
    required this.bolinhasMostradas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (subdivisoesPorColuna <= 0 || fracoes.isEmpty) return;

    // --- CALCULA LARGURA FIXA DAS COLUNAS E OFFSET ---
    final double larguraColuna = ESPACO_SEGMENTO * subdivisoesPorColuna;
    final double offsetX = offsetHorizontalTicks * ESPACO_SEGMENTO;

    // --- DESENHA COLUNAS TRACEJADAS FIXAS DE FUNDO ---
    final Paint paintGrid = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double xStart = ((-offsetX / larguraColuna).floor()) * larguraColuna;
    for (double x = xStart;
        x < -offsetX + size.width + larguraColuna;
        x += larguraColuna) {
      double xCanvas = x + offsetX;
      if (xCanvas >= -larguraColuna && xCanvas <= size.width + larguraColuna) {
        for (double y = 0; y < size.height; y += 10) {
          canvas.drawLine(
            Offset(xCanvas, y),
            Offset(xCanvas, y + 5),
            paintGrid,
          );
        }
      }
    }

    // --- DESENHA BOLINHAS E LINHA DE CONEXÃO ---
    final double alturaTotal = size.height * 0.9;
    final double margemV = size.height * 0.1 / 2;
    final double alturaFaixa = alturaTotal / fracoes.length;

    for (int row = 0; row < fracoes.length; row++) {
      final fracao = fracoes[row];
      if (!fracao.estaTocando || fracao.numerador == null || fracao.denominador == null) continue;

      final int cols = fracao.numerador!;    // número de colunas no bloco
      final int bols = fracao.denominador!;  // bolinhas por bloco
      final double blocoW = cols * larguraColuna;
      final double yCenter = margemV + alturaFaixa * row + alturaFaixa / 2;

      // pré-calcular posições de cada bolinha em cada bloco
      List<Offset> allPositions = [];
      ///mudei aqui
      // for (double x = -offsetX % blocoW - blocoW; x < size.width; x += blocoW) 
         for (double x = (-offsetX % blocoW); x < size.width; x += blocoW) {
        if (cols == bols) {
          // caso bols == cols: uma bolinha por coluna, centralizada em cada coluna
          for (int c = 0; c < cols; c++) {
            // double posX = x + c * larguraColuna + larguraColuna / 2;
            final double posX = x + c * larguraColuna;
            allPositions.add(Offset(posX, yCenter));
          }
        } else {
          // distribui bols bolinhas ao longo do bloco, última no tracejado
          for (int b = 0; b < bols; b++) {
            double fracPos = (b + 1) / bols;
            allPositions.add(Offset(x + fracPos * blocoW, yCenter));
          }
        }
      }

      // determina quantas bolinhas exibir até agora
      // int count = min(circleIndex, allPositions.length);
      // if (count <= 0) continue;

      final int count = min(bolinhasMostradas[fracao.id] ?? 0, allPositions.length);
  if (count <= 0) continue;

      // pinta linha de conexão até a última bolinha
      final Paint paintLine = Paint()
        ..color = fracao.cor.withOpacity(0.8)
        ..strokeWidth = ESPESSURA_LINHA
        ..strokeCap = StrokeCap.round;
      // canvas.drawLine(allPositions.first, allPositions[count - 1], paintLine);
      canvas.drawLine(Offset(0, yCenter), allPositions[count - 1], paintLine);

      // pinta bolinhas
      final Paint paintDot = Paint()..color = fracao.cor;
      for (int i = 0; i < count; i++) {
        canvas.drawCircle(allPositions[i], RAIO_BOLINHA, paintDot);
      }
    }
  }

  // @override
  // bool shouldRepaint(covariant PintorRitmo old) =>
  //     old.circleIndex != circleIndex ||
  //     old.estaTocandoGlobalmente != estaTocandoGlobalmente ||
  //     old.offsetHorizontalTicks != offsetHorizontalTicks ||
  //     old.subdivisoesPorColuna != subdivisoesPorColuna;

    @override
  bool shouldRepaint(covariant PintorRitmo old) {
    if (old.estaTocandoGlobalmente != estaTocandoGlobalmente) return true;
    if (old.offsetHorizontalTicks != offsetHorizontalTicks) return true;
    if (old.subdivisoesPorColuna != subdivisoesPorColuna) return true;

    // **Verifica se mudou o número de bolinhas para qualquer fração**
    for (var f in fracoes) {
      final oldCount = old.bolinhasMostradas[f.id] ?? 0;
      final newCount = bolinhasMostradas[f.id] ?? 0;
      if (oldCount != newCount) return true;
    }

    return false;
  }

}
