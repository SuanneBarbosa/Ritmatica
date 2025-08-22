import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
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
  final GlobalKey _keyInputB1 = GlobalKey();
  // final GlobalKey _keyInputB2 = GlobalKey();
  // final GlobalKey _keyInputB3= GlobalKey();
  final GlobalKey _keyBotaoB1 = GlobalKey();
  final GlobalKey _keyGrupoInputs = GlobalKey();
  final GlobalKey _keyVisualizador = GlobalKey();
  // final GlobalKey _keyBotaoB2 = GlobalKey();
  // final GlobalKey _keyBotaoB3 = GlobalKey();
  final GlobalKey _keyPlayGlobal = GlobalKey();
  final GlobalKey _keySlider = GlobalKey();
  final GlobalKey _keyMenu = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkIfTutorialNeeded(); 

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarDialogoOrientacao(context);
      });
    }
  }

 
  Future<void> _checkIfTutorialNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final bool tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;
    if (!tutorialCompleted) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  Future<void> _markTutorialAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    if (mounted) {
      setState(() {
        _showTutorial = false;
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

    
   final List<TutorialStep> tutorialSteps = [
 
  TutorialStep(
    key: _keyVisualizador,
    text:
        'Bem-vindo ao Ritmática! Esta é a tela de animação. Aqui, você verá até 3 faixas com bolinhas coloridas representando os ritmos que você criar.',
    alignment: Alignment.bottomCenter,
    padding: const EdgeInsets.only(bottom: 120),
  ),

  
  TutorialStep(
    key: _keyGrupoInputs,
    text:
        'Passo 1: Comece aqui! Use as faixas B1, B2 e B3 para criar seus ritmos. Em cada uma, o campo "N" define o TEMPO e o campo "D" define o NÚMERO DE BATIDAS.',
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 80),
  ),

  
  TutorialStep(
    key: _keyBotaoB1,
    text:
        'Passo 2: Abaixo de cada faixa, use os botões B1, B2 e B3 para ATIVAR os ritmos que você deseja ouvir. As faixas ativas ficarão destacadas.',
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 100),
  ),

  
  TutorialStep(
    key: _keyPlayGlobal,
    text:
        'Passo 3: Use o botão de Play principal para iniciar ou parar a reprodução de TODAS as faixas que estiverem ativas ao mesmo tempo.',
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 50, right: 200),
  ),


  TutorialStep(
    key: _keySlider,
    text:
        'Passo 4: Abaixo da tela de animação, arraste este controle deslizante para navegar e visualizar diferentes partes do seu ritmo.',
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 100, left: 150),
  ),


  TutorialStep(
    key: _keyMenu,
    text:
        'Passo 5: No canto superior esquerdo, acesse o menu para salvar ritmos, ver a lista de salvos, ajustar a visualização e outras opções.',
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
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
                      // Expanded(
                      //   flex: 2,
                      //   child: VisualizadorRitmo(
                      //     estaTocando: ritmoProvider.estaTocandoGlobalmente,
                      //   ),
                      // ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                              key: _keyGrupoInputs,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ritmoProvider.fracoes.map((fracao) {
                              GlobalKey? inputKey;
                              GlobalKey? botaoKey;
                              if (fracao.id == 'b1') {
                                inputKey = _keyInputB1;
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
                                        key: inputKey,
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