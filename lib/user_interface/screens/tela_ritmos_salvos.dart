import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';

class TelaRitmosSalvos extends StatelessWidget {
  const TelaRitmosSalvos({super.key});

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ritmos Salvos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ritmoProvider.conjuntosSalvos.isEmpty
          ? const Center(child: Text('Nenhum ritmo salvo ainda.'))
          : ListView.builder(
              itemCount: ritmoProvider.conjuntosSalvos.length,
              itemBuilder: (context, index) {
                final conjunto = ritmoProvider.conjuntosSalvos[index];
                return ListTile(
                  title: Text(conjunto.nome),
                  subtitle: Text(conjunto.fracoes.map((f) => f.valorExibicao).where((v) => v.isNotEmpty).join(' | ')),
                  onTap: () {
                    ritmoProvider.aplicarConjuntoSalvo(conjunto);
                    Navigator.pop(context); // Volta para a tela principal
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                       showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: const Text('Confirmar Exclusão'),
                            content: Text('Tem certeza que deseja excluir o ritmo "${conjunto.nome}"?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  ritmoProvider.excluirConjuntoSalvo(conjunto.nome);
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}