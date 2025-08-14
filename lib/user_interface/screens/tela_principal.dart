import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/widgets/faixa_input_fracao.dart';
import '../../user_interface/widgets/botao_faixa_individual.dart';
import '../../user_interface/widgets/visualizador_ritmo.dart';
import '../../user_interface/widgets/side_menu.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final TextEditingController _controladorNomeSalvar = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarDialogoOrientacao(context);
      });
    }
  }

  Future<void> _mostrarDialogoOrientacao(BuildContext context) async {
    const String titulo = 'Aviso: Orientação do Dispositivo.';
    const String conteudo =
        'Antes de utilizar o aplicativo, posicione o celular na sua mão, em modo paisagem, girando no sentido anti-horário.';
    const String acao = 'Toque no botão OK para fechar este aviso.';

    final String fullSemanticLabel = '$titulo $conteudo $acao';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          semanticLabel: fullSemanticLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),

          title: ExcludeSemantics(
            child: const Text(
              'Orientação do Dispositivo',
              textAlign: TextAlign.center,
            ),
          ),

          content: SingleChildScrollView(
            child: Text(
              conteudo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,

          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('OK'),

              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);

    const int maxColunasIniciaisSlider = 100;
    final double initialMaxTicks =
        (maxColunasIniciaisSlider * ritmoProvider.subdivisoesPorColunaVisual)
            .toDouble();
    final double currentOffset = ritmoProvider.offsetHorizontalScroll;
    final double sliderMaximum = max(initialMaxTicks, currentOffset);
    final double sliderValue = currentOffset.clamp(0.0, sliderMaximum);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: SideMenu(
        onSalvarRitmo: () async {
          final bool foiSalvo =
              await Provider.of<RitmoProvider>(
                context,
                listen: false,
              ).salvarConjuntoAtual();

          if (!context.mounted) return;
          if (foiSalvo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ritmo salvo com sucesso!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nenhuma fração válida para salvar.'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label: 'Abrir menu de navegação',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    iconSize: 30,
                    tooltip: 'Abrir menu',
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),

                const Spacer(),
              ],
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: VisualizadorRitmo(
                      estaTocando: ritmoProvider.estaTocandoGlobalmente,
                    ),
                  ),
                  const SizedBox(height: 5),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Semantics(
                        label:
                            ritmoProvider.estaTocandoGlobalmente
                                ? 'Botão Stop para parar a reprodução'
                                : 'Botão Play para iniciar a reprodução',
                        hint:
                            ritmoProvider.estaTocandoGlobalmente
                                ? 'Interrompe a reprodução global do ritmo'
                                : 'Inicia a reprodução global do ritmo',
                        button: true,
                        excludeSemantics: true,
                        child: IconButton(
                          icon: Icon(
                            ritmoProvider.estaTocandoGlobalmente
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                          ),
                          iconSize: 50,
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
                      ),

                      const SizedBox(width: 12),
                      Semantics(
                        label:
                            'Botão para retroceder 10 colunas na tela de animação do ritmo',
                        button: true,
                        excludeSemantics: true,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          tooltip: 'Retroceder',
                          onPressed: () {
                            ritmoProvider.retrocederScroll(colunas: 10);
                          },
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: sliderMaximum,
                          divisions:
                              (sliderMaximum > 0)
                                  ? (sliderMaximum /
                                          (ritmoProvider
                                                      .subdivisoesPorColunaVisual >
                                                  0
                                              ? ritmoProvider
                                                  .subdivisoesPorColunaVisual
                                              : 1))
                                      .round()
                                      .clamp(1, 100000)
                                  : 1,
                          label:
                              "Coluna: ${(currentOffset / ritmoProvider.subdivisoesPorColunaVisual).floor()}",
                          onChanged: (double value) {
                            ritmoProvider.definirOffsetHorizontalScroll(value);
                          },
                        ),
                      ),
                      Semantics(
                        label:
                            'Botão para avançar 10 colunas na tela de animação do ritmo',
                        button: true,
                        excludeSemantics: true,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          tooltip: 'Avançar',
                          onPressed: () {
                            ritmoProvider.avancarScroll(colunas: 10);
                          },
                        ),
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
                              return FocusTraversalGroup(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Semantics(
                                      sortKey: const OrdinalSortKey(1.0),
                                      child: LinhaInputFracao(fracao: fracao),
                                    ),
                                    const SizedBox(height: 1),

                                    Semantics(
                                      sortKey: const OrdinalSortKey(2.0),
                                      child: BotaoFaixaIndividual(
                                        fracao: fracao,
                                      ),
                                    ),
                                  ],
                                ),
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
