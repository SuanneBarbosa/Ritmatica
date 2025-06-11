// user_interface/widgets/side_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/screens/tela_ritmos_salvos.dart'; // Para navegação

class SideMenu extends StatelessWidget {
  final VoidCallback onSalvarRitmo;

  const SideMenu({super.key, required this.onSalvarRitmo});

  @override
  Widget build(BuildContext context) {
    return Consumer<RitmoProvider>(
      builder: (context, ritmoProvider, child) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  'Ritmatica',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.save_alt_outlined),
                title: const Text('Salvar Ritmo Atual'),
                onTap: () {
                  Navigator.pop(context);
                  onSalvarRitmo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text('Ver Ritmos Salvos'),
                onTap: () {
                  Navigator.pop(context);
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
                title: const Text('Ticks por Coluna Visual'),
                subtitle: Consumer<RitmoProvider>(
                  builder: (_, provider, __) {
                    double sliderValue = provider.subdivisoesPorColunaVisual
                        .toDouble()
                        .clamp(4.0, 64.0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Slider(
                          min: 4,
                          max: 64,
                          divisions: (64 - 4) ~/ 4,
                          value: sliderValue,
                          label: provider.subdivisoesPorColunaVisual.toString(),
                          onChanged: (valor) {
                            provider.atualizarLarguraColuna(valor.toInt());
                          },
                        ),
                        Text(
                          "${provider.subdivisoesPorColunaVisual} ticks",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
