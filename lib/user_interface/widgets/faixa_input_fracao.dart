import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fracao_model.dart';
import '../../services/ritmo_provider.dart';
// import './teclado_numerico.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; 

class FaixaInputFracao extends StatelessWidget {
  const FaixaInputFracao({super.key});

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);

    return Container(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Distribui espaço entre os inputs
        children:
            ritmoProvider.fracoes.map((fracao) {
              // Adiciona um padding em volta de cada linha de input para espaçamento
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 8.0,
                ),
                child: LinhaInputFracao(fracao: fracao),
              );
            }).toList(),
      ),
    );
  }
}

class LinhaInputFracao extends StatefulWidget {
  final FracaoModel fracao;
  const LinhaInputFracao({required this.fracao, super.key});

  @override
  State<LinhaInputFracao> createState() => _LinhaInputFracaoState();
}

class _LinhaInputFracaoState extends State<LinhaInputFracao> {
  late TextEditingController _numCtrl;
  late TextEditingController _denCtrl;

  @override
  void initState() {
    super.initState();
    _numCtrl = TextEditingController();
    _denCtrl = TextEditingController();
    _atualizarControllersComModelo();
  }

  @override
  void didUpdateWidget(covariant LinhaInputFracao oldWidget) {
    super.didUpdateWidget(oldWidget);
    _atualizarControllersComModelo();
  }

  void _atualizarControllersComModelo() {
    final novoNumeradorStr = widget.fracao.numerador?.toString() ?? '';
    final novoDenominadorStr = widget.fracao.denominador?.toString() ?? '';
    if (_numCtrl.text != novoNumeradorStr) {
      _numCtrl.text = novoNumeradorStr;
    }
    if (_denCtrl.text != novoDenominadorStr) {
      _denCtrl.text = novoDenominadorStr;
    }
  }

  void _onChanged() {
    final prov = Provider.of<RitmoProvider>(context, listen: false);
    prov.atualizarValorFracao(
      widget.fracao.id,
      '${_numCtrl.text}:${_denCtrl.text}',
    );
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _denCtrl.dispose();
    super.dispose();
  }

  // dentro de user_interface/widgets/faixa_input_fracao.dart
// na classe _LinhaInputFracaoState

// void _abrirTecladoCustomizado(TextEditingController controller) {
//   showDialog(
//     context: context,
//     // AQUI ESTÁ A MÁGICA:
//     // O builder do showDialog nos dá mais controle sobre o posicionamento.
//     builder: (ctx) {
//       return Dialog(
//         // Alinha o diálogo no topo da tela.
//         alignment: Alignment.topCenter,
        
//         // Remove a elevação (sombra) padrão do diálogo.
//         elevation: 0,
        
//         // Faz o fundo ser transparente para não vermos a caixa branca do diálogo.
//         backgroundColor: Colors.white,
        
//         // Impede que o diálogo ocupe toda a largura da tela.
//         insetPadding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 100.0),

//         child: SizedBox(
//           // Mantemos uma altura fixa para o nosso teclado.
//           height: 250,
//           child: TecladoNumerico(
//             onDigitPressed: (digit) {
//               controller.text += digit;
//             },
//             onBackspacePressed: () {
//               if (controller.text.isNotEmpty) {
//                 controller.text =
//                     controller.text.substring(0, controller.text.length - 1);
//               }
//             },
//             onConfirmPressed: () {
//               Navigator.of(ctx).pop(); // Fecha o diálogo
//               _onChanged();
//             },
//           ),
//         ),
//       );
//     },
//   ).whenComplete(() {
//     // Esta função é chamada quando o diálogo é fechado.
//     _onChanged();
//   });
// }

  @override
  Widget build(BuildContext context) {
    final identidadeFracao = 'fração ${widget.fracao.id.toUpperCase()}';


    //  void handleTap(TextEditingController controller) {
    //   final prov = Provider.of<RitmoProvider>(context, listen: false);
    //   // prov.pararFracaoSeTocando(widget.fracao.id);
     
    //   _abrirTecladoCustomizado(controller);
    // }
    
     Widget buildConditionalTextField(
        TextEditingController controller, String hintText, String labelPart) {
           
      return SizedBox(
        width: 40,
        height: 32,
        child: Semantics(
label: '$labelPart para a $identidadeFracao. Valor atual: ${controller.text.isEmpty ? 'vazio' : controller.text}',
      hint: 'Toque para abrir o teclado númerico e digitar o valor', // Hint simplificado
      
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        
        // --- MUDANÇAS PRINCIPAIS AQUI ---

        // 1. O campo é SEMPRE editável. Isso permite que o teclado nativo apareça.
        readOnly: false, 

        // 2. Define o tipo de teclado para numérico (funciona em web e mobile).
        keyboardType: TextInputType.number, 

        // 3. (RECOMENDADO) Garante que o usuário só possa digitar números.
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly
        ],
        
        showCursor: true,

        // 4. Ao TOCAR no campo, paramos a fração se ela estiver tocando.
        //    Isso acontece ANTES do teclado aparecer.
        onTap: () {
          Provider.of<RitmoProvider>(context, listen: false)
              .pararFracaoSeTocando(widget.fracao.id);
        },

        // 5. Ao ALTERAR o texto (digitando), chamamos _onChanged para atualizar o estado.
        //    Isso agora funciona em TODAS as plataformas.
        onChanged: (_) => _onChanged(),

            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
            ),
          ),
        ),
      );
    }
    
    
    
    return Row(
      children: [
        Text(
          widget.fracao.id.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: widget.fracao.cor,
          ),
        ),
        const SizedBox(width: 8),
 buildConditionalTextField(_numCtrl, 'N', 'Numerador'),
ExcludeSemantics(child: const Text('/', style: TextStyle(fontSize: 16)),),


        buildConditionalTextField(_denCtrl, 'D', 'Denominador'),



      //   Semantics(
      //     label: 'Numerador para a $identidadeFracao. Valor atual: ${_numCtrl.text.isEmpty ? 'vazio' : _numCtrl.text}',
      //     button: true,
      //     hint: 'Toque para abrir o teclado numérico',
      //     excludeSemantics: true,
      //     child: SizedBox(
      //       width: 40,
      //       height: 32,
      //       child: TextField(
      //         controller: _numCtrl,
      //         textAlign: TextAlign.center,
      //         readOnly: true, // <-- FALTOU ESTA LINHA! ESSENCIAL.
      //         showCursor: true,
      //         onTap: () => _abrirTecladoCustomizado(_numCtrl),
      //         decoration: const InputDecoration(hintText: 'N', isDense: true),
      //         // Removido o onChanged daqui, pois é controlado pelo teclado.
      //       ),
      //     ),
      //   ),
      //   const Text('/', style: TextStyle(fontSize: 16)),
      //  Semantics(
      //     label: 'Denominador para a $identidadeFracao. Valor atual: ${_denCtrl.text.isEmpty ? 'vazio' : _denCtrl.text}',
      //     button: true,
      //     hint: 'Toque para abrir o teclado numérico',
      //     excludeSemantics: true,
      //     child: SizedBox(
      //       width: 40,
      //       height: 32,
      //       child: TextField(
      //         controller: _denCtrl,
      //         textAlign: TextAlign.center,
      //         readOnly: true, // <-- FALTOU ESTA LINHA!
      //         showCursor: true, // <-- ADICIONADO PARA CONSISTÊNCIA
      //         onTap: () => _abrirTecladoCustomizado(_denCtrl), // <-- FALTOU ESTA LINHA!
      //         decoration: const InputDecoration(hintText: 'D', isDense: true),
      //         // onChanged: (_) => _onChanged(), <-- REMOVIDO
      //       ),
      //     ),
      //   ),

        IconButton(
          // Passamos a cor da fração para o ícone
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: widget.fracao.cor, // Adicione esta linha
            semanticLabel: 'Limpar fração',
          ),
          tooltip: 'Limpar fração',
          onPressed: () {
            _numCtrl.clear();
            _denCtrl.clear();
            Provider.of<RitmoProvider>(
              context,
              listen: false,
            ).excluirValorFracao(widget.fracao.id);
          },
        ),

        // ),
      ],
    );
  }
}
