import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 

import './services/ritmo_provider.dart';
import './services/tutorial_service.dart';
import './user_interface/screens/splash_screen.dart';
import './user_interface/screens/tela_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  final tutorialService = TutorialService();
  final bool orientationHasBeenShown = await tutorialService.isOrientationShown();

  runApp(MeuApp(
    orientationShown: kIsWeb || orientationHasBeenShown,
  ));
}

class MeuApp extends StatelessWidget {
  final bool orientationShown;

  const MeuApp({
    super.key,
    required this.orientationShown,
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
        home: kIsWeb
            ? const TelaPrincipal()
            : SplashScreen(
                orientationShown: orientationShown,
              ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}