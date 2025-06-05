// user_interface/widgets/side_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/screens/tela_ritmos_salvos.dart'; // Para navegação

class SideMenu extends StatelessWidget {
  // Callback para acionar a função de salvar da TelaPrincipal
  final VoidCallback onSalvarRitmo;

  const SideMenu({
    super.key,
    required this.onSalvarRitmo,
  });

  @override
  Widget build(BuildContext context) {
    // Usar Consumer para que o Slider e o texto do BPM se atualizem
    return Consumer<RitmoProvider>(
      builder: (context, ritmoProvider, child) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor, // Ou a cor que desejar
                ),
                child: const Text(
                  'Ritmatica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tempo (BPM):", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: ritmoProvider.tempoBPM,
                            min: 30,
                            max: 240,
                            divisions: (240 - 30).toInt(),
                            label: ritmoProvider.tempoBPM.round().toString(),
                            onChanged: (double value) {
                              ritmoProvider.definirTempo(value);
                            },
                          ),
                        ),
                        Text(ritmoProvider.tempoBPM.round().toString(), style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.save_alt_outlined),
                title: const Text('Salvar Ritmo Atual'),
                onTap: () {
                  Navigator.pop(context); // Fecha o drawer primeiro
                  onSalvarRitmo(); // Chama a função da TelaPrincipal
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text('Ver Ritmos Salvos'),
                onTap: () {
                  Navigator.pop(context); // Fecha o drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaRitmosSalvos()),
                  );
                },
              ),





ListTile(
  title: const Text('Largura da Coluna'),
  subtitle: Consumer<RitmoProvider>(
    builder: (_, provider, __) {
      return Slider(
        min: 20,
        max: 200,
        divisions: 9,
        value: provider.subdivisoesPorColunaVisual.toDouble(),
        label: provider.subdivisoesPorColunaVisual.toString(),
        onChanged: (valor) {
          provider.atualizarLarguraColuna(valor.toInt());
        },
      );
    },
  ),
),

ListTile(
  title: const Text('Ticks por Coluna Visual'), // Nome mais descritivo
  subtitle: Consumer<RitmoProvider>(
    builder: (_, provider, __) {
      // Valores de exemplo, ajuste conforme a necessidade de granularidade
      // para as frações. Um bom LCM para denominadores comuns é útil.
      // (ex: 12, 16, 24, 32, 36, 48, 60)
      double sliderValue = provider.subdivisoesPorColunaVisual.toDouble().clamp(4.0, 64.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Slider(
            min: 4,  // Mínimo de ticks (ex: para representar 1/2, 1/4)
            max: 64, // Máximo de ticks
            divisions: (64 - 4) ~/ 4, // Ex: divisões em passos de 4
            value: sliderValue,
            label: provider.subdivisoesPorColunaVisual.toString(),
            onChanged: (valor) {
              provider.atualizarLarguraColuna(valor.toInt());
            },
          ),
          Text("${provider.subdivisoesPorColunaVisual} ticks", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      );
    },
  ),
),


              
              // Adicione mais opções de menu aqui se necessário
            ],
          ),
        );
      },
    );
  }
}