import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';

class TelaRitmosSalvos extends StatelessWidget {
  const TelaRitmosSalvos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context, listen: false);

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

      body: Consumer<RitmoProvider>(
        builder: (context, ritmoProviderDados, child) {
          if (ritmoProviderDados.conjuntosSalvos.isEmpty) {
            return const Center(child: Text('Nenhum Ritmo salvo ainda.'));
          }
          return ListView.builder(
            itemCount: ritmoProvider.conjuntosSalvos.length,
            itemBuilder: (context, index) {
              final conjunto = ritmoProvider.conjuntosSalvos[index];
              //final numero = index + 1;
              final listaFracoes =
                  conjunto.fracoes
                      .where((f) => f.valorExibicao.isNotEmpty)
                      .map((f) => f.valorExibicao.replaceAll(':', '/'))
                      .toList();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 5.0,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listaFracoes.join('  |  '),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            Semantics(
                             
                              label:
                                  'Aplicar o conjunto de ritmo selecionado e voltar para a tela principal ao clicar no botão aplicar.',
                              button: true,

                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ritmoProvider.aplicarConjuntoSalvo(conjunto);
                                },
                                child: const Text('Aplicar'),
                              ),
                            ),

                            const SizedBox(width: 8),

                            IconButton(
                              tooltip: 'Excluir o conjunto',
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                semanticLabel: 'Excluir o conjunto',
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15.0,
                                          ),
                                        ),

                                        title: const Text(
                                          'Confirmar Exclusão',
                                          textAlign: TextAlign.center,
                                        ),

                                        content: Text(
                                          'Deseja excluir "${listaFracoes.join(', ')}"?',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        actionsAlignment:
                                            MainAxisAlignment.spaceEvenly,

                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
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
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            onPressed: () {
                                              ritmoProvider
                                                  .excluirConjuntoSalvo(
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
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
