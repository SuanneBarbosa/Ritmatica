import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fracao_model.dart';
import '../../services/ritmo_provider.dart';
import 'package:flutter/services.dart';

class FaixaInputFracao extends StatelessWidget {
  const FaixaInputFracao({super.key});

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            ritmoProvider.fracoes.map((fracao) {
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

  @override
  Widget build(BuildContext context) {
    final identidadeRazao = 'relação ${widget.fracao.id.toUpperCase()}';

    Widget buildConditionalTextField(
      TextEditingController controller,
      String hintText,
      String labelPart,
    ) {
      return SizedBox(
        width: 40,
        height: 32,
        child: Semantics(
          label:
              'Campo $hintText para a $identidadeRazao. Valor atual: ${controller.text.isEmpty ? 'vazio' : controller.text}',
          hint: 'Toque para abrir o teclado numérico e digitar o valor',

          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            readOnly: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

            showCursor: true,
            onTap: () {
              Provider.of<RitmoProvider>(
                context,
                listen: false,
              ).pararFracaoSeTocando(widget.fracao.id);
            },

            onChanged: (_) => _onChanged(),

            decoration: InputDecoration(hintText: hintText, isDense: true),
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
        buildConditionalTextField(_numCtrl, 'B', 'Numerador'),
      //   Semantics(
      //   label: 'Está para', 
      //   child: const Text( 
      //     ':',
      //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //   ),
      // ),
      ExcludeSemantics(
child: const Text(':', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
),

        buildConditionalTextField(_denCtrl, 'D', 'Denominador'),

        IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: widget.fracao.cor,
            semanticLabel: 'Limpar $identidadeRazao',
          ),
          tooltip: 'Limpar relação',
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
