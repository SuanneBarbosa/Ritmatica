import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../models/fracao_model.dart';

class TelaRitmosSalvos extends StatelessWidget {
  const TelaRitmosSalvos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ritmos Salvos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Consumer<RitmoProvider>(
          builder: (context, ritmoProvider, child) {
            if (ritmoProvider.conjuntosSalvos.isEmpty) {
              return const Center(child: Text('Nenhum Ritmo salvo ainda.'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              itemCount: ritmoProvider.conjuntosSalvos.length,
              itemBuilder: (context, index) {
                final conjunto = ritmoProvider.conjuntosSalvos[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: conjunto.fracoes.map((fracao) {
                                return _buildFracaoDisplay(fracao);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                label:
                                    'Aplicar na tela principal ou excluir o ritmo salvo',
                                button: true,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ritmoProvider.aplicarConjuntoSalvo(conjunto);
                                  },
                                  child: const FittedBox(
                                    child: Text('Aplicar'),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip:
                                  'Excluir o ritmo',
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                semanticLabel: 'Excluir ',
                              ),
                              onPressed: () => _showDeleteDialog(
                                  context, ritmoProvider, conjunto),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, RitmoProvider ritmoProvider, dynamic conjunto) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          'Confirmar Exclusão',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Deseja excluir "${conjunto.nome.replaceAll(' | ', ', ')}"?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              ritmoProvider.excluirConjuntoSalvo(
                conjunto.nome,
              );
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // MUDANÇA 3: Acessibilidade (Semantics)
  Widget _buildFracaoDisplay(FracaoModel fracao) {
    // Constrói a label para o leitor de tela
    String semanticLabel = 'Razão ${fracao.id.toUpperCase()}';
    if (fracao.numerador != null && fracao.denominador != null) {
      semanticLabel += ', ${fracao.numerador} está para ${fracao.denominador}';
    } else {
      semanticLabel += ', valor não definido';
    }

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics( // Impede que o leitor de tela leia os filhos individualmente
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // MUDANÇA 2: Borda preta no texto R1, R2, R3
              Stack(
                children: [
                  // Camada de trás: A borda preta
                  Text(
                    '${fracao.id.toUpperCase()}:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1.5 // Espessura da borda
                        ..color = Colors.black, // Cor da borda
                    ),
                  ),
                  // Camada da frente: A cor original
                  Text(
                    '${fracao.id.toUpperCase()}:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: fracao.cor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberBox(fracao.numerador, fracao.cor)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  ':',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: _buildNumberBox(fracao.denominador, fracao.cor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBox(int? value, Color color) {
    final bool isEmptyValue = value == null;
    return Container(
      height: 25,
      decoration: BoxDecoration(
        color: isEmptyValue ? Colors.grey.shade300 : color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: isEmptyValue ? Colors.grey : color, width: 1.5),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value?.toString() ?? '',
            style: const TextStyle(
              // MUDANÇA 1: Cor do texto alterada para preto
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}