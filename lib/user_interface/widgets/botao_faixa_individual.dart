import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fracao_model.dart';
import '../../services/ritmo_provider.dart';

class BotaoFaixaIndividual extends StatelessWidget {
  final FracaoModel fracao;

  const BotaoFaixaIndividual({
    super.key,
    required this.fracao,
  });

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);
    bool estaSelecionada = fracao.estaSelecionada;
    const double larguraBotao = 100.0; 
    const double alturaBotao = 40.0;
    final identidadeFracao = 'faixa ${fracao.id.toUpperCase()}';

    return Semantics(
      label: estaSelecionada
          ? '$identidadeFracao, selecionada'
          : 'Selecionar $identidadeFracao',
      hint: 'Toque para alternar a seleção de áudio desta faixa',
      selected: estaSelecionada,
      button: true,
      excludeSemantics: true,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(larguraBotao, alturaBotao), 
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
        ritmoProvider.toggleSelecaoFaixa(fracao.id);
      },
      child: Text(fracao.id.toUpperCase()),
    ),);
  }
}