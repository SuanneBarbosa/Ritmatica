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
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    }
  }

  Future<void> _checkIfTutorialNeeded() async {
    final bool tutorialCompleted =
        await _tutorialService.isMainTutorialCompleted();
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
            'Bem-vindo ao Ritmática! Este tutorial guiará você pelas principais funcionalidades. Use os botões Próximo e Anterior na parte inferior da tela para navegar, ou feche o tutorial no botão Pular Tutorial.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        key: _keyGrupoInputs,
        text:
            'Controles de Ritmo: Para gerar um ritmo você deve criar uma razão. Na parte inferior da tela estão os campos para inserir os valores das razões: R1, R2 e R3. '
            'Cada razão possui dois campos: o primeiro número é colocado em "A" (intervalo de tempo) e o segundo em "B" (número de batidas). '
            'Por exemplo: na razão "2 está para 3", você deve colocar o número 2 em "A" e o número 3 em "B". '
            'Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 80),
      ),
      TutorialStep(
        key: _keyVisualizador,
        text:
            'Animação de Ritmo: Na área superior e maior da tela, a animação do seu ritmo será exibida. '
            'Cada batida sonora corresponderá a uma bolinha aparecendo nesta área. Clique em Próximo para continuar.',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 120),
      ),
      TutorialStep(
        key: _keyBotaoB1,
        text:
            'Ativar uma razão: Abaixo de cada razão tem um botão de ativação. '
            'Apenas as razões ativas serão reproduzidas. Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100),
      ),
      TutorialStep(
        key: _keyPlayGlobal,
        text:
            'Botão Play e Stop: Localizado à esquerda da barra deslizante, este botão inicia e interrompe a reprodução de todas as razões ativas. '
            'O leitor de tela anunciará se o botão está em "Play" ou "Stop". Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 50, right: 200),
      ),
      TutorialStep(
        key: _keyPlayGlobal,
        text:
            'Para tocar duas ou três razões ao mesmo tempo, primeiro ative os botões das razões desejadas, depois toque no botão de Stop, assim elas irão parar de tocar. Então, toque novamente nesse mesmo botão para dar play. Assim, todas as faixas ativadas iniciarão juntas.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 50, right: 200),
      ),
      TutorialStep(
        key: _keySlider,
        text:
            'Barra de Navegação: No centro da tela, entre os botões de Play e as setas, há uma barra deslizante. '
            'Use-a para navegar pela linha do tempo da animação. As setas ao lado movem a visualização em blocos. Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100, left: 150),
      ),
      TutorialStep(
        key: _keyMenu,
        text:
            'Menu Principal: Localizado no canto superior esquerdo da tela, este botão abre o menu de navegação com opções para salvar, carregar ritmos e acessar as configurações. Clique em Próximo para continuar.',
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
      ),
      TutorialStep(
        key: _keyCentral,
        text:
            'Agora vamos para a parte prática. Prepare-se para criar seu primeiro ritmo! Clique em Próximo para continuar.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        key: _keyGrupoInputs,
        text:
            'Vamos explorar a proporcionalidade! Primeiro, na Razão R1 insira "2" no campo "A" e "3" no campo "B". Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 80),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyGrupoInputs,
        text:
            'Agora, na Razão R2 insira "4" no campo "A" e "6" no campo "B". Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 80),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyBotaoB1,
        text: 'Ative as Razões tocando no botão "R1" e depois no botão "R2". Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyPlayGlobal,
        text:
            'Toque duas vezes no botão "Play" para ouvir as duas razões juntas, demonstrando a proporcionalidade. Perceba como a cadência rítmica é a mesma, ou seja, o mesmo padrão de batidas! Clique em Próximo para continuar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 50, right: 200),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyCentral,
        text:
            'Tutorial prático finalizado! Você aprendeu a criar e comparar ritmos proporcionais. Continue explorando! Clique no botão Finalizar.',
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

          Padding(
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
                              key: _keySlider,
                              value: sliderValue,
                              min: 0.0,
                              max: sliderMaximum,
                              divisions: (sliderMaximum > 0)
                                  ? (sliderMaximum /
                                          (ritmoProvider.subdivisoesPorColunaVisual > 0
                                              ? ritmoProvider.subdivisoesPorColunaVisual
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
                            key: _keyGrupoInputs,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ritmoProvider.fracoes.map((fracao) {
                              GlobalKey? botaoKey;
                              if (fracao.id == 'r1') {
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
          
          if (_showTutorial)
            InteractiveTutorialOverlay(
              steps: tutorialSteps,
                 onFinish: () {
                Provider.of<RitmoProvider>(context, listen: false).resetarRitmo();
                _markTutorialAsCompleted();
              },
              onSkip: () {
                Provider.of<RitmoProvider>(context, listen: false).resetarRitmo();
                _markTutorialAsCompleted();
              },
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