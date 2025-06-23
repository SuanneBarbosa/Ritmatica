// user_interface/screens/tela_principal.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/widgets/faixa_input_fracao.dart'; // Contém LinhaInputFracao (pública)
import '../../user_interface/widgets/botao_faixa_individual.dart'; // Widget do botão criado
import '../../user_interface/widgets/visualizador_ritmo.dart';
import '../../user_interface/widgets/side_menu.dart'; // Widget do menu lateral
import 'dart:math';
import 'package:flutter/foundation.dart'; 
// import 'package:flutter_tts/flutter_tts.dart';

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
  // late FlutterTts _flutterTts;

  @override
  void initState() {
     super.initState();
    
    // PASSO 2: ADICIONE A CONDIÇÃO AQUI
    if (!kIsWeb) {
      // O código abaixo só será executado se NÃO for a plataforma web.
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
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
             

shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0)),

              
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
      resizeToAvoidBottomInset: false,
      drawer: SideMenu(
        onSalvarRitmo: () async {
          // Chama diretamente o método de salvar do provider
        final bool foiSalvo = await  Provider.of<RitmoProvider>(
            context,
            listen: false,
          ).salvarConjuntoAtual();

         if (!context.mounted) return;
         if (foiSalvo) {
          // Mostra a mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ritmo salvo com sucesso!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Mostra uma mensagem de aviso/informação
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma fração válida para salvar.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.redAccent, // Cor diferente para aviso
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
                ),),
                
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
                    flex: 2,
                    child: VisualizadorRitmo(
                      estaTocando: ritmoProvider.estaTocandoGlobalmente,
                    ), // Não precisa mais da key para calcular offset
                  ),
                  const SizedBox(height: 5),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // botão de play/stop
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
                        label: 'Botão para retroceder 10 colunas na tela de animação do ritmo',
                        button: true,
                        excludeSemantics: true,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          tooltip: 'Retroceder',
                          onPressed: () {
                            // Você pode ajustar o número de colunas a retroceder.
                            ritmoProvider.retrocederScroll(colunas: 10);
                          },
                        ),
                      ),

                      // slider ocupando o resto do espaço (ou largura fixa, se preferir)
                      // if (maxScrollOffsetTicks > 0.001)
                      Expanded(
                        child: Slider(
                          value: sliderValue, // <- Usa a variável segura
                          min: 0.0,
                          max: sliderMaximum, // <- Usa a variável segura
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
                        label: 'Botão para avançar 10 colunas na tela de animação do ritmo',
                        button: true,
                        excludeSemantics: true,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          tooltip: 'Avançar',
                          onPressed: () {
                            // Você pode ajustar o número de colunas a retroceder.
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
          // 2. Semantics com sortKey: Define a ordem de visita.
          // Itens com 'sortKey' menor são visitados primeiro.
          Semantics(
            sortKey: const OrdinalSortKey(1.0), // Ordem 1: A linha de input
            child: LinhaInputFracao(fracao: fracao),
          ),
          const SizedBox(height: 1), // Widget visual, sem semântica

          Semantics(
            sortKey: const OrdinalSortKey(2.0), // Ordem 2: O botão de faixa
            child: BotaoFaixaIndividual(fracao: fracao),
          ),
        ],
      ),
    );
                              // return Column(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       // É crucial que LinhaInputFracao tenha sua própria semântica bem definida.
                              //       LinhaInputFracao(fracao: fracao),
                              //       const SizedBox(height: 1),
                              //       // E que BotaoFaixaIndividual também tenha.
                              //       BotaoFaixaIndividual(fracao: fracao),
                              //     ],
                                
                              // );
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
