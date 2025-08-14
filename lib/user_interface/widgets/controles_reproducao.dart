import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../models/fracao_model.dart'; 

class ControlesReproducao extends StatelessWidget {
  const ControlesReproducao({super.key});

  Widget _construirBotaoSelecaoFaixa(BuildContext context, FracaoModel fracao, RitmoProvider ritmoProvider) {
    print("Construindo botão ${fracao.id}, selecionada: ${fracao.estaSelecionada}, cor: ${fracao.cor}");

    bool estaSelecionada = fracao.estaSelecionada;
    const double larguraBotaoFactor = 0.5; 

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: LayoutBuilder( 
        builder: (BuildContext context, BoxConstraints constraints) {
          final double larguraDoBotao = constraints.maxWidth * larguraBotaoFactor;

          return Center( 
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(larguraDoBotao, 40), 
                backgroundColor: estaSelecionada ? fracao.cor.withOpacity(0.8) : Colors.blueGrey[700],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: estaSelecionada
                      ? BorderSide(color: Colors.white.withOpacity(0.9), width: 2.5)
                      : BorderSide(color: Colors.blueGrey[600]!, width: 1.5),
                ),
                elevation: estaSelecionada ? 6 : 2,
              ),
              onPressed: () {
                print("Botão ${fracao.id} pressionado!");
                ritmoProvider.toggleSelecaoFaixa(fracao.id);

                if (!ritmoProvider.estaTocandoGlobalmente) {
                  ritmoProvider.iniciarOuPausarReproducaoGlobal();
                }
              },
              child: Text(fracao.id.toUpperCase()),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RitmoProvider>(
      builder: (context, ritmoProvider, child) {
        print("ControlesReproducao Consumer está reconstruindo.");

        final fracaoB1 = ritmoProvider.fracoes.firstWhere((f) => f.id == 'b1', orElse: () {
          print("ERRO: Fração b1 não encontrada em ritmoProvider.fracoes!");
          return FracaoModel(id: 'b1', cor: Colors.grey, assetSom: '', estaSelecionada: false);
        });
        final fracaoB2 = ritmoProvider.fracoes.firstWhere((f) => f.id == 'b2', orElse: () {
          print("ERRO: Fração b2 não encontrada em ritmoProvider.fracoes!");
          return FracaoModel(id: 'b2', cor: Colors.grey, assetSom: '', estaSelecionada: false);
        });
        final fracaoB3 = ritmoProvider.fracoes.firstWhere((f) => f.id == 'b3', orElse: () {
          print("ERRO: Fração b3 não encontrada em ritmoProvider.fracoes!");
          return FracaoModel(id: 'b3', cor: Colors.grey, assetSom: '', estaSelecionada: false);
        });

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              _construirBotaoSelecaoFaixa(context, fracaoB1, ritmoProvider),
              const SizedBox(height: 12),
              _construirBotaoSelecaoFaixa(context, fracaoB2, ritmoProvider),
              const SizedBox(height: 12),
              _construirBotaoSelecaoFaixa(context, fracaoB3, ritmoProvider),
            ],
          ),
        );
      },
    );
  }
}