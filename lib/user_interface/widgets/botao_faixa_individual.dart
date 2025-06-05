// user_interface/widgets/botao_faixa_individual.dart

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
    // Acessa o provider para o estado e ações
    final ritmoProvider = Provider.of<RitmoProvider>(context);
    bool estaSelecionada = fracao.estaSelecionada;

    // Definir um tamanho fixo ou mínimo para o botão
    const double larguraBotao = 100.0; // Ajuste conforme necessário
    const double alturaBotao = 40.0;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(larguraBotao, alturaBotao), // Garante um tamanho mínimo
        // Ou use fixedSize: Size(larguraBotao, alturaBotao) se quiser tamanho exato
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0) // Padding interno
      ),
      onPressed: () {
        print("Botão Individual ${fracao.id} pressionado!");
        ritmoProvider.toggleSelecaoFaixa(fracao.id);

        // A lógica de iniciar/parar global pode ser mantida ou removida daqui,
        // dependendo se você quer que clicar no botão inicie a reprodução
        // ou apenas selecione a faixa. Vamos remover por enquanto,
        // deixando o play/stop global com essa responsabilidade.
        if (!ritmoProvider.estaTocandoGlobalmente) {
          ritmoProvider.iniciarOuPausarReproducaoGlobal();
        }
      },
      child: Text(fracao.id.toUpperCase()),
    );
  }
}