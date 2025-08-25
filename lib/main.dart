// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './services/ritmo_provider.dart';
import './services/tutorial_service.dart'; 
import './user_interface/screens/orientation_screen.dart'; 
import './user_interface/screens/tela_principal.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
  SystemUiOverlay.bottom
]);

  final tutorialService = TutorialService();
  final bool orientationHasBeenShown = await tutorialService.isOrientationShown();
  

  runApp(MeuApp(
    // Passamos o resultado para o widget principal
    showOrientationScreen: !orientationHasBeenShown,
  ));
}

class MeuApp extends StatelessWidget {
  // Variável para receber a decisão da tela inicial
  final bool showOrientationScreen;

  const MeuApp({
    super.key,
    required this.showOrientationScreen,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RitmoProvider(),
      child: MaterialApp(
        title: 'Ritmatica',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFF54ADFF),
        ),
        // --- LÓGICA CONDICIONAL APLICADA AQUI ---
        home: showOrientationScreen
            ? const OrientationScreen() // Se for a primeira vez, mostra a orientação
            : const TelaPrincipal(),   // Caso contrário, vai para a tela principal
        // ------------------------------------------
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}