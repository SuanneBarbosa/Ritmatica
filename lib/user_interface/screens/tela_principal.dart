// user_interface/screens/tela_principal.dart


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/widgets/faixa_input_fracao.dart'; // Contém LinhaInputFracao (pública)
import '../../user_interface/widgets/botao_faixa_individual.dart'; // Widget do botão criado
import '../../user_interface/widgets/visualizador_ritmo.dart';
import '../../user_interface/widgets/side_menu.dart'; // Widget do menu lateral

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
    // ... (código existente)
    _controladorNomeSalvar.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Provider.of<RitmoProvider>(context, listen: false)
                    .salvarConjuntoAtual(_controladorNomeSalvar.text);
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

    // Slider de scroll horizontal:
    // O scroll é em "ticks". Definimos um número máximo de colunas para o slider.
    const int maxColunasScrollSlider = 100; // Ex: permite scrollar até 100 colunas
    final double maxScrollOffsetTicks = ritmoProvider.subdivisoesPorColunaVisual > 0
        ? (maxColunasScrollSlider * ritmoProvider.subdivisoesPorColunaVisual).toDouble()
        : 1.0; // Evita divisão por zero se subdivisoesPorColunaVisual for 0 inicialmente

    double currentSliderValue = ritmoProvider.offsetHorizontalScroll.clamp(0.0, maxScrollOffsetTicks);
    
    // Se o valor do provider estiver fora do range do slider (ex: negativo), ajusta o valor do slider.
    // O provider pode ter offset negativo se o slider permitir no futuro, mas por agora o slider é 0-max.
    if (ritmoProvider.offsetHorizontalScroll < 0) currentSliderValue = 0;


    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(
        onSalvarRitmo: _mostrarDialogoSalvar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coluna Esquerda (Menu e Play/Stop)
            // ... (código existente)
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
            const SizedBox(width: 10),

            // Coluna Central (Visualizador, Controles, Slider de Scroll)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: VisualizadorRitmo(), // Não precisa mais da key para calcular offset
                  ),
                  const SizedBox(height: 10),

                  Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: Icon(
                      ritmoProvider.estaTocandoGlobalmente
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                    ),
                    iconSize: 60,
                    color: ritmoProvider.estaTocandoGlobalmente
                        ? Colors.redAccent.shade200
                        : Colors.greenAccent.shade400,
                    tooltip: ritmoProvider.estaTocandoGlobalmente ? 'Parar' : 'Tocar',
                    onPressed: () {
                      ritmoProvider.iniciarOuPausarReproducaoGlobal();
                    },
                  ),
                ),

                   // Slider para o scroll horizontal
                  if (maxScrollOffsetTicks > 0.001)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: Slider(
                        value: currentSliderValue,
                        min: 0.0, // O slider atual só permite scroll para a direita
                        max: maxScrollOffsetTicks,
                        divisions: (maxScrollOffsetTicks / (ritmoProvider.subdivisoesPorColunaVisual > 0 ? ritmoProvider.subdivisoesPorColunaVisual : 1)).round().clamp(1, 10000), // Divide por colunas
                        label: ritmoProvider.subdivisoesPorColunaVisual > 0 
                               ? "Col: ${(currentSliderValue / ritmoProvider.subdivisoesPorColunaVisual).floor()}"
                               : "Pos: ${currentSliderValue.round()}",
                        onChanged: (double value) {
                          ritmoProvider.definirOffsetHorizontalScroll(value);
                        },
                      ),
                    )
                  else
                    const SizedBox(height: 48 + 16), 
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ritmoProvider.fracoes.map((fracao) {
                          return Row(
                            mainAxisSize: MainAxisSize.min, // só ocupa o necessário
                            children: [
                              // Linha de entrada: "B1: [quadrado cor][campo 60px][lixeira]"
                              LinhaInputFracao(fracao: fracao),
                              const SizedBox(width: 8),
                              // Botão logo ao lado: "B1" (quadrado colorido)
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