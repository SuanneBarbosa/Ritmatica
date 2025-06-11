// user_interface/screens/tela_principal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/widgets/faixa_input_fracao.dart'; // Contém LinhaInputFracao (pública)
import '../../user_interface/widgets/botao_faixa_individual.dart'; // Widget do botão criado
import '../../user_interface/widgets/visualizador_ritmo.dart';
import '../../user_interface/widgets/side_menu.dart'; // Widget do menu lateral
import 'dart:math';

// user_interface/screens/tela_principal.dart
// ... (imports existentes)

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final TextEditingController _controladorNomeSalvar = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // REMOVIDO: _visualizadorKey (não mais usado para calcular maxScrollOffset dessa forma)

  void _mostrarDialogoSalvar() {
    _controladorNomeSalvar.clear();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Salvar Ritmo'),
            content: TextField(
              controller: _controladorNomeSalvar,
              decoration: const InputDecoration(hintText: "Nome do ritmo"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (_controladorNomeSalvar.text.isNotEmpty) {
                    Provider.of<RitmoProvider>(
                      context,
                      listen: false,
                    ).salvarConjuntoAtual(_controladorNomeSalvar.text);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);

      const int maxColunasIniciaisSlider = 100;
    final double initialMaxTicks = (maxColunasIniciaisSlider * ritmoProvider.subdivisoesPorColunaVisual).toDouble();

    // 2. Obtenha o valor atual do scroll do nosso estado (provider).
    final double currentOffset = ritmoProvider.offsetHorizontalScroll;

    // 3. Calcule o 'max' do slider. Ele deve ser o valor inicial ou o valor atual, o que for MAIOR.
    //    Isso garante que o trilho do slider sempre cresça para acomodar o valor.
    final double sliderMaximum = max(initialMaxTicks, currentOffset);

    // 4. O valor do slider é o valor atual do scroll.
    //    Usamos .clamp() como uma segurança final para garantir que ele NUNCA ultrapasse o 'max'.
    final double sliderValue = currentOffset.clamp(0.0, sliderMaximum);

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(onSalvarRitmo: _mostrarDialogoSalvar),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  iconSize: 30,
                  tooltip: 'Abrir menu',
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const Spacer(),
              ],
            ),
            // const SizedBox(width: 10),

            // Coluna Central (Visualizador, Controles, Slider de Scroll)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child:
                        VisualizadorRitmo(), // Não precisa mais da key para calcular offset
                  ),
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // botão de play/stop
                      IconButton(
                        icon: Icon(
                          ritmoProvider.estaTocandoGlobalmente
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline,
                        ),
                        iconSize: 48,
                        color:
                            ritmoProvider.estaTocandoGlobalmente
                                ? Colors.redAccent.shade200
                                : Colors.white,
                        tooltip:
                            ritmoProvider.estaTocandoGlobalmente
                                ? 'Parar'
                                : 'Tocar',
                        onPressed: () {
                          ritmoProvider.iniciarOuPausarReproducaoGlobal();
                        },
                      ),

                      const SizedBox(width: 12),

                      IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      tooltip: 'Retroceder',
                      onPressed: () {
                        // Você pode ajustar o número de colunas a retroceder.
                        ritmoProvider.retrocederScroll(colunas: 10);
                      },
                    ),

                      // slider ocupando o resto do espaço (ou largura fixa, se preferir)
                      // if (maxScrollOffsetTicks > 0.001)
                     Expanded(
                        child: Slider(
                          value: sliderValue, // <- Usa a variável segura
                          min: 0.0,
                          max: sliderMaximum, // <- Usa a variável segura
                          divisions: (sliderMaximum > 0)
                              ? (sliderMaximum / (ritmoProvider.subdivisoesPorColunaVisual > 0 ? ritmoProvider.subdivisoesPorColunaVisual : 1))
                                  .round()
                                  .clamp(1, 100000)
                              : 1,
                          label: "Col: ${(currentOffset / ritmoProvider.subdivisoesPorColunaVisual).floor()}",
                          onChanged: (double value) {
                            ritmoProvider.definirOffsetHorizontalScroll(value);
                          },
                        ),
                      ),
                     IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      tooltip: 'Avançar',
                      onPressed: () {
                        // Você pode ajustar o número de colunas a avançar.
                        ritmoProvider.avancarScroll(colunas: 10);
                      },
                    ),
                    ],
                  ),

                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            ritmoProvider.fracoes.map((fracao) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // esta linha já inclui o TextField e o ícone de lixeira
                                  LinhaInputFracao(fracao: fracao),
                                  const SizedBox(height: 4),
                                  // agora o botão "B1/B2/B3" fica abaixo do input
                                  BotaoFaixaIndividual(fracao: fracao),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorNomeSalvar.dispose();
    super.dispose();
  }
}
