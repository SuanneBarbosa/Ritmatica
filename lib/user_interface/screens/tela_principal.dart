import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:ritmatica_app/services/tutorial_service.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/widgets/faixa_input_fracao.dart';
import '../../user_interface/widgets/botao_faixa_individual.dart';
import '../../user_interface/widgets/visualizador_ritmo.dart';
import '../../user_interface/widgets/side_menu.dart';
import '../../user_interface/widgets/interactive_tutorial_overlay.dart';
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

  bool _showTutorial = false;
  final GlobalKey _keyGrupoInputs = GlobalKey();
  final GlobalKey _keyVisualizador = GlobalKey();
  final GlobalKey _keyBotaoB1 = GlobalKey();
  final GlobalKey _keyPlayGlobal = GlobalKey();
  final GlobalKey _keySlider = GlobalKey();
  final GlobalKey _keyMenu = GlobalKey();
  final GlobalKey _keyCentral = GlobalKey();

   final TutorialService _tutorialService = TutorialService();

  @override
  void initState() {
    super.initState();
    _checkIfTutorialNeeded();

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      });
    }
  }

   Future<void> _checkIfTutorialNeeded() async {
    final bool tutorialCompleted = await _tutorialService.isMainTutorialCompleted();
    if (!tutorialCompleted) {
      if (mounted) {
        setState(() {
          _showTutorial = true;
        });
      }
    }
  }


  Future<void> _markTutorialAsCompleted() async {
    await _tutorialService.markMainTutorialAsCompleted();
    if (mounted) {
      setState(() {
        _showTutorial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);
    final List<TutorialStep> tutorialSteps = [
      TutorialStep(
        key: _keyCentral,
        text:
            'Bem-vindo ao Ritmática! Este tutorial guiará você pelas funcionalidades principais. Use os botões de próximo e anterior na parte inferior da tela para navegar ou feche o tutorial no botão Pular Tutorial.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        key: _keyGrupoInputs,
        text:
            'Passo 1 de 6: Controles de Ritmo. Na parte inferior da tela, estão as três faixas de controle: B1, B2 e B3. '
            'Cada uma possui dois campos de texto. O primeiro campo, "N", é o intervalo de tempo. O segundo, "D", é o número de batidas. Clique em no botão inferior próximo para continuar',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 80),
      ),
      TutorialStep(
        key: _keyVisualizador,
        text:
            'Passo 2 de 6: Visualizador de Ritmo. Na área superior e maior da tela, a animação do seu ritmo será exibida. '
            'Cada batida sonora corresponderá a uma bolinha colorida aparecendo nesta área. Clique em no botão inferior próximo para continuar',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 120),
      ),
      TutorialStep(
        key: _keyBotaoB1,
        text:
            'Passo 3 de 6: Ativar uma Faixa. Abaixo dos campos de texto, cada faixa tem um botão de ativação. '
            'Toque duas vezes no botão para ativá-lo. Apenas as faixas ativas serão reproduzidas. Clique em no botão inferior próximo para continuar',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100),
      ),
      TutorialStep(
        key: _keyPlayGlobal,
        text:
            'Passo 4 de 6: Botão de Play e Stop. Localizado à esquerda da barra deslizante, este botão inicia e para a reprodução de todas as faixas ativas. '
            'O leitor de tela anunciará se é "Play" ou "Stop". Clique em no botão inferior próximo para continuar',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 50, right: 200),
      ),
      TutorialStep(
        key: _keySlider,
        text:
            'Passo 5 de 6: Barra de Navegação. No centro da tela, entre os botões de play e setas, há uma barra deslizante. '
            'Use-a para navegar pela linha do tempo da animação. As setas ao lado movem a visualização em blocos. Clique em no botão inferior próximo para continuar',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100, left: 150),
      ),
      TutorialStep(
        key: _keyMenu,
        text:
            'Passo 6 de 6: Menu Principal. Localizado no canto superior esquerdo da tela, este botão abre o menu de navegação com opções para salvar, carregar ritmos e acessar as configurações. Clique em no botão inferior próximo para continuar',
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
      ),
      TutorialStep(
        key: _keyCentral,
        text: 'Tutorial concluído! Boa exploração! Clique no botão Finalizar',
        alignment: Alignment.center,
      ),
      TutorialStep(
        key: _keyCentral,
        text:
            'Dica de Uso: Para explorar a proporção, crie um ritmo "2 para 3" na faixa B1 e um ritmo "4 para 6" na faixa B2. '
            'Ao tocar as duas juntas, você ouvirá que elas possuem a mesma cadência rítmica, ou seja, o mesmo "padrão de batidas".',
        alignment: Alignment.center,
      ),
    ];

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
          final bool foiSalvo = await Provider.of<RitmoProvider>(
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
      body: Stack(
        children: [
        
          Center(child: SizedBox(key: _keyCentral, width: 1, height: 1)),
          AbsorbPointer(
            absorbing: _showTutorial,
            child: Padding(
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
                          key: _keyMenu,
                          icon: const Icon(Icons.menu),
                          iconSize: 30,
                          tooltip: 'Abrir menu',
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
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
                          child: Container(
                            key: _keyVisualizador,
                            child: VisualizadorRitmo(
                              estaTocando: ritmoProvider.estaTocandoGlobalmente,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Semantics(
                              label: ritmoProvider.estaTocandoGlobalmente
                                  ? 'Botão Stop para parar a reprodução'
                                  : 'Botão Play para iniciar a reprodução',
                              hint: ritmoProvider.estaTocandoGlobalmente
                                  ? 'Interrompe a reprodução global do ritmo'
                                  : 'Inicia a reprodução global do ritmo',
                              button: true,
                              excludeSemantics: true,
                              child: IconButton(
                                key: _keyPlayGlobal,
                                icon: Icon(
                                  ritmoProvider.estaTocandoGlobalmente
                                      ? Icons.stop_circle_outlined
                                      : Icons.play_circle_outline,
                                ),
                                iconSize: 50,
                                color: ritmoProvider.estaTocandoGlobalmente
                                    ? Colors.redAccent.shade200
                                    : Colors.white,
                                tooltip: ritmoProvider.estaTocandoGlobalmente
                                    ? 'Parar'
                                    : 'Tocar',
                                onPressed: () {
                                  ritmoProvider
                                      .iniciarOuPausarReproducaoGlobal();
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
                                key: _keySlider,
                                value: sliderValue,
                                min: 0.0,
                                max: sliderMaximum,
                                divisions: (sliderMaximum > 0)
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
                                  ritmoProvider
                                      .definirOffsetHorizontalScroll(value);
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              key: _keyGrupoInputs,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ritmoProvider.fracoes.map((fracao) {
                                GlobalKey? botaoKey;
                                if (fracao.id == 'b1') {
                                  botaoKey = _keyBotaoB1;
                                }

                                return FocusTraversalGroup(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Semantics(
                                        sortKey: const OrdinalSortKey(1.0),
                                        child: LinhaInputFracao(
                                          fracao: fracao,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Semantics(
                                        sortKey: const OrdinalSortKey(2.0),
                                        child: BotaoFaixaIndividual(
                                          fracao: fracao,
                                          key: botaoKey,
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
          ),
          if (_showTutorial)
            InteractiveTutorialOverlay(
              steps: tutorialSteps,
              onFinish: _markTutorialAsCompleted,
              onSkip: _markTutorialAsCompleted,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controladorNomeSalvar.dispose();
    super.dispose();
  }
}