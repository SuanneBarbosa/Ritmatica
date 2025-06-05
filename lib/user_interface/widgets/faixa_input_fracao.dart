import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fracao_model.dart';
import '../../services/ritmo_provider.dart';

class FaixaInputFracao extends StatelessWidget {
  const FaixaInputFracao({super.key});

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);

    return Container(
      
     
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Distribui espaço entre os inputs
        children: ritmoProvider.fracoes.map((fracao) {
          // Adiciona um padding em volta de cada linha de input para espaçamento
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            child: LinhaInputFracao(fracao: fracao),
          );
        }).toList(),
      ),
    );
  }
}

class LinhaInputFracao extends StatefulWidget {
  final FracaoModel fracao;

  const LinhaInputFracao({required this.fracao});

  @override
  State<LinhaInputFracao> createState() => _LinhaInputFracaoState();
}

class _LinhaInputFracaoState extends State<LinhaInputFracao> {
  late TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(text: widget.fracao.valorExibicao);
  }

  @override
  void didUpdateWidget(covariant LinhaInputFracao oldWidget) {
    super.didUpdateWidget(oldWidget);

    print("TextField (${widget.fracao.id}) didUpdateWidget. Modelo_Exibicao: ${widget.fracao.valorExibicao}, Controlador_Texto: ${_controlador.text}");

    if (oldWidget.fracao.valorExibicao != widget.fracao.valorExibicao) {
      final novoTexto = widget.fracao.valorExibicao;
      if (_controlador.text != novoTexto) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controlador.text = novoTexto;
          _controlador.selection = TextSelection.fromPosition(
            TextPosition(offset: novoTexto.length),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fator de largura para o TextField (ex: 0.6 para 60% do espaço disponível para ele)
    // const double textFieldWidthFactor = 0.5; // Ajuste conforme necessário

    return Row(
      children: [
        Text('${widget.fracao.id.toUpperCase()}:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)), // Cor do texto
        const SizedBox(width: 5),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
             color: widget.fracao.cor,
             border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
             borderRadius: BorderRadius.circular(4)
          ),
        ),
        const SizedBox(width: 8),
        // Expanded( // Expanded ainda é necessário para que esta seção ocupe o espaço restante
          
        //   child: Row(
        //     children: [
        //       Expanded(
        //          child: SizedBox( // Mantém a altura do TextField e serve de pai para FractionallySizedBox
            
        //     height: 40,
        //    // Alinha o TextField à esquerda dentro do espaço fracionado
        //       child: TextField(
        //         controller: _controlador,
        //         keyboardType: TextInputType.text,
        //         textAlignVertical: TextAlignVertical.center,
        //         style: const TextStyle(color: Colors.black87), // Cor do texto dentro do input
        //         decoration: InputDecoration(
        //           hintText: 'N:D',
        //           hintStyle: TextStyle(color: Colors.grey[600]),
        //           isDense: true,
        //           filled: true, // Para a cor de fundo do TextField funcionar
        //           fillColor: Colors.white.withOpacity(0.9), // Cor de fundo do TextField
        //           contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Ajuste o padding interno
        //           border: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(6.0),
        //             borderSide: BorderSide.none, // Remove a borda padrão se 'filled' é true
        //           ),
        //           enabledBorder: OutlineInputBorder( // Borda quando não focado
        //             borderRadius: BorderRadius.circular(6.0),
        //             borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
        //           ),
        //           focusedBorder: OutlineInputBorder( // Borda quando focado
        //             borderRadius: BorderRadius.circular(6.0),
        //             borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        //           ),
        //         ),
        //         onChanged: (valor) {
        //           print("TextField (${widget.fracao.id}) onChanged: $valor");
        //           Provider.of<RitmoProvider>(context, listen: false)
        //               .atualizarValorFracao(widget.fracao.id, valor);
        //         },
        //       ),
            
        //   ),
          
        //       ),
        //        IconButton(
        //   icon: const Icon(Icons.delete_outline, color: Colors.white70),
        //   padding: EdgeInsets.zero, // Remove padding extra do IconButton
        //   constraints: const BoxConstraints(), // Permite que o IconButton seja menor
        //   onPressed: () {
        //     _controlador.clear();
        //     Provider.of<RitmoProvider>(context, listen: false)
        //         .excluirValorFracao(widget.fracao.id);
        //   },
        // ),
        //     ],
        //   )
          
          
         
        // ),

        Row(
        children: [
            SizedBox(
             width: 90,   // largura fixa o suficiente para “3:3”
              height: 30,
              child: TextField(
                controller: _controlador,
                keyboardType: TextInputType.text,
               textAlignVertical: TextAlignVertical.center,
               style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'N:D',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                   borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(6.0),
                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(6.0),
                   borderSide:
                        BorderSide(color: Theme.of(context).primaryColor, width: 1.5),                  ),
               ),
               onChanged: (valor) {
                 Provider.of<RitmoProvider>(context, listen: false)
                     .atualizarValorFracao(widget.fracao.id, valor);
               },
             ),
           ),
           const SizedBox(width: 4),
           IconButton(
             icon: const Icon(Icons.delete_outline, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
             onPressed: () {
               _controlador.clear();
               Provider.of<RitmoProvider>(context, listen: false)
                   .excluirValorFracao(widget.fracao.id);
            },
           ),
         ],
        ),
       
      ],
    );
  }
}