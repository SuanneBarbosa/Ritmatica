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
  
  // Inicializamos em 0 para o controle de bloqueio do tutorial
  int _currentStepIndex = -1; 
  bool _showTutorial = false;

  final GlobalKey _keyGrupoInputs = GlobalKey();
   final GlobalKey _keyInputR1 = GlobalKey();
  final GlobalKey _keyInputR2 = GlobalKey();
  final GlobalKey _keyInputR3 = GlobalKey();
  final GlobalKey _keyBotaoB1 = GlobalKey();
  final GlobalKey _keyBotaoB2 = GlobalKey();
  final GlobalKey _keyBotaoB3 = GlobalKey();
  final GlobalKey _keyVisualizador = GlobalKey();
 // final GlobalKey _keyBotaoB1 = GlobalKey();
  final GlobalKey _keyPlayGlobal = GlobalKey();
  final GlobalKey _keySlider = GlobalKey();
  final GlobalKey _keyMenu = GlobalKey();
  final GlobalKey _keyCentral = GlobalKey();
  final GlobalKey _keySliderBack = GlobalKey();
//final GlobalKey _keySlider = GlobalKey();
final GlobalKey _keySliderForward = GlobalKey();

  final TutorialService _tutorialService = TutorialService();

  // 👇 TRANSFORMEI OS PASSOS EM UM GETTER (Isso resolve o erro LateInitializationError)
  List<TutorialStep> get tutorialSteps {
    //final String btnLabel = _currentStepIndex == 0 ? 'Começar' : 'Próximo';
    return[
      TutorialStep(
        key: _keyCentral,
        text: 'Ative o VLibras no ícone à direita depois toque em "Começar" ou apenas em "Começar" para seguir sem a tradução.',
        alignment: Alignment.center,
      ),
      TutorialStep(
        key: _keyCentral,
        text: 'Bem-vindo! Toque em "Próximo" ou em "Pular Tutorial".',
        alignment: Alignment.center,
      ),
      TutorialStep(
        key: _keyGrupoInputs,
        text: 'Para gerar um ritmo você deve estabelecer uma relação entre B e D. Na parte inferior da tela estão os campos para inserir os valores de B (intervalo de tempo) e D (número de batidas) em cada uma das relações R1, R2 e R3.',
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 80),
      ),
      TutorialStep(
        key: _keyGrupoInputs,
        text: 'Por exemplo: na relação 2 está para 3, você deve colocar o número 2 em B e o número 3 em D.',
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 80),
      ),
      TutorialStep(
        key: _keyVisualizador,
        text: 'Na área superior da tela, a animação do seu ritmo será exibida. Cada batida corresponderá a uma bolinha.',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 120),
      ),
      TutorialStep(
        key: _keyBotaoB1,
        text: 'Abaixo de cada relação tem um ícone para ativar.',
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100),
      ),
      TutorialStep(
        key: _keyPlayGlobal,
        text: 'Localizado à esquerda da barra deslizante, o ícone play inicia e para a reprodução. O leitor de tela diz se está em Play ou Stop.',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 50, right: 200),
      ),
      TutorialStep(
        key: _keyPlayGlobal,
        text: 'Para tocar mais de uma relação simultaneamente, primeiro ative os ícones das relações, depois toque duas vezes no ícone de Stop e Play. Assim, todas as faixas ativadas iniciarão juntas.',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 50, right: 200),
      ),
      TutorialStep(
        key: _keyMenu,
        text: 'No canto superior esquerdo da tela, se localiza o menu de navegação com opções para salvar, carregar ritmos e acessar as configurações.',
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(right: 20),
      ),
      TutorialStep(
        key: _keyCentral,
        text: 'Prepare-se para criar seu primeiro ritmo!',
        alignment: Alignment.center,
      ),
      TutorialStep(
        key: _keyInputR1, 
        text: 'Vamos explorar a proporcionalidade! Primeiro, na relação R1 insira 2 em B e 3 em D.',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 80),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyInputR2,
        text: 'Na relação R2 insira 4 em B e 6 em D.',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 80),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyBotaoB1,
        text: 'Ative tocando no ícone R1 e depois no ícone R2.',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 100),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyPlayGlobal,
        text: 'Toque duas vezes em Play para ouvir as duas relações juntas, demonstrando a proporcionalidade. Observe o mesmo padrão de batidas!',
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 50, right: 200),
        isInteractive: true, 
      ),
      TutorialStep(
        key: _keyCentral,
        text: 'Tutorial prático finalizado!',
        alignment: Alignment.center,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _checkIfTutorialNeeded();

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
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

  // Lógica de Trava Inteligente para o Tutorial
  // bool _isWidgetEnabled(GlobalKey key) {
  //   if (!_showTutorial) return true; // Libera tudo se não estiver no tutorial
  //   if (_currentStepIndex < 0 || _currentStepIndex >= tutorialSteps.length) return false;
  //   final step = tutorialSteps[_currentStepIndex];
  //   // Libera o botão APENAS se for o passo interativo dele
  //   return step.isInteractive && step.key == key;
  // }

   bool _isWidgetEnabled(GlobalKey key) {
    if (!_showTutorial) return true;
    if (_currentStepIndex < 0 || _currentStepIndex >= tutorialSteps.length) return false;
    final step = tutorialSteps[_currentStepIndex];
    
    if (!step.isInteractive) return false;
    if (step.key == key) return true;
    
    // Libera os dois botões no passo de ativação
    if (step.key == _keyBotaoB1 && key == _keyBotaoB2) return true;

    return false;
  }

  // Widget _buildProtectedWidget(GlobalKey key, Widget child) {
  //   final enabled = _isWidgetEnabled(key);
  //   return IgnorePointer(
  //     ignoring: !enabled,
  //     child: ExcludeSemantics(
  //       excluding: !enabled && _showTutorial, 
  //       child: child,
  //     ),
  //   );
  // }

   Widget _buildProtectedWidget(GlobalKey key, Widget child) {
    final enabled = _isWidgetEnabled(key);
    return IgnorePointer(
      ignoring: !enabled,
      child: ExcludeSemantics(
        excluding: !enabled && _showTutorial, 
        child: Container(
          key: key, // A chave que demarca a área do tutorial fica injetada APENAS aqui!
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ritmoProvider = Provider.of<RitmoProvider>(context);

    const int maxColunasIniciaisSlider = 100;
    final double initialMaxTicks = (maxColunasIniciaisSlider * ritmoProvider.subdivisoesPorColunaVisual).toDouble();
    final double currentOffset = ritmoProvider.offsetHorizontalScroll;
    final double sliderMaximum = max(initialMaxTicks, currentOffset);
    final double sliderValue = currentOffset.clamp(0.0, sliderMaximum);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawerEnableOpenDragGesture: !_showTutorial, // Bloqueia arraste do menu lateral durante o tutorial
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
        children:[
          Center(child: SizedBox(key: _keyCentral, width: 1, height: 1)),

          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    _buildProtectedWidget(
                      _keyMenu,
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
                    ),
                    const Spacer(),
                  ],
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    children:[
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
                        children:[
                          _buildProtectedWidget(
                            _keyPlayGlobal,
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
                                //key: _keyPlayGlobal,
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
                          ),
                          const SizedBox(width: 12),
                          _buildProtectedWidget(
                            _keySliderBack,
                            Semantics(
                              label: 'Botão para retroceder 10 colunas na tela de animação do ritmo',
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
                          ),
                          Expanded(
                            child: _buildProtectedWidget(
                              _keySlider,
                              Slider(
                               // key: _keySlider,
                                value: sliderValue,
                                min: 0.0,
                                max: sliderMaximum,
                                divisions: (sliderMaximum > 0)
                                    ? (sliderMaximum / (ritmoProvider.subdivisoesPorColunaVisual > 0 ? ritmoProvider.subdivisoesPorColunaVisual : 1))
                                        .round()
                                        .clamp(1, 100000)
                                    : 1,
                                label: "Coluna: ${(currentOffset / ritmoProvider.subdivisoesPorColunaVisual).floor()}",
                                onChanged: (double value) {
                                  ritmoProvider.definirOffsetHorizontalScroll(value);
                                },
                              ),
                            ),
                          ),
                          _buildProtectedWidget(
                           _keySliderForward,
                            Semantics(
                              label: 'Botão para avançar 10 colunas na tela de animação do ritmo',
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
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            key: _keyGrupoInputs, // A chave do grupo TODO fica aqui
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ritmoProvider.fracoes.map((fracao) {
                              
                              // Distribui chaves exclusivas para R1, R2 e R3
                              GlobalKey? inputKey;
                              GlobalKey? botaoKey;
                              
                              if (fracao.id == 'r1') {
                                inputKey = _keyInputR1;
                                botaoKey = _keyBotaoB1;
                              } else if (fracao.id == 'r2') {
                                inputKey = _keyInputR2;
                                botaoKey = _keyBotaoB2;
                              } else if (fracao.id == 'r3') {
                                inputKey = _keyInputR3;
                                botaoKey = _keyBotaoB3;
                              }

                              return FocusTraversalGroup(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:[
                                    _buildProtectedWidget(
                                      inputKey!,
                                      Semantics(
                                        sortKey: const OrdinalSortKey(1.0),
                                        child: LinhaInputFracao(
                                          fracao: fracao,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    _buildProtectedWidget(
                                      botaoKey!,
                                      Semantics(
                                        sortKey: const OrdinalSortKey(2.0),
                                        child: BotaoFaixaIndividual(
                                          fracao: fracao,
                                        ),
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
              onStepChanged: (index) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _currentStepIndex = index;
                    });
                  }
                });
              },
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