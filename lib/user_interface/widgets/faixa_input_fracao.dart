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
    _numCtrl = TextEditingController(
        text: widget.fracao.numerador?.toString() ?? '');
    _denCtrl = TextEditingController(
        text: widget.fracao.denominador?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant LinhaInputFracao old) {
    super.didUpdateWidget(old);
    if (old.fracao.numerador?.toString() !=
        widget.fracao.numerador?.toString()) {
      _numCtrl.text = widget.fracao.numerador?.toString() ?? '';
    }
    if (old.fracao.denominador?.toString() !=
        widget.fracao.denominador?.toString()) {
      _denCtrl.text = widget.fracao.denominador?.toString() ?? '';
    }
  }

  void _onChanged() {
    final num = int.tryParse(_numCtrl.text);
    final den = int.tryParse(_denCtrl.text);
    final prov = Provider.of<RitmoProvider>(context, listen: false);
    if (num != null && den != null && num > 0 && den > 0) {
      prov.atualizarValorFracao(widget.fracao.id, '$num:$den');
    } else {
      prov.atualizarValorFracao(widget.fracao.id, '');
    }
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _denCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.fracao.id.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: widget.fracao.cor)),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          height: 32,
          child: TextField(
            controller: _numCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'N',
              isDense: true,
            ),
            onChanged: (_) => _onChanged(),
          ),
        ),
        const Text('/', style: TextStyle(fontSize: 16)),
        SizedBox(
          width: 40,
          height: 32,
          child: TextField(
            controller: _denCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'D',
              isDense: true,
            ),
            onChanged: (_) => _onChanged(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            _numCtrl.clear();
            _denCtrl.clear();
            Provider.of<RitmoProvider>(context, listen: false)
                .excluirValorFracao(widget.fracao.id);
          },
        ),
      ],
    );
  }
}