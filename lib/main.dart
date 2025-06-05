import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './services/ritmo_provider.dart';
import './user_interface/screens/tela_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Forçar modo paisagem
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Esconder a barra de status para uma experiência mais imersiva
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RitmoProvider(),
      child: MaterialApp(
        title: 'Ritmatica',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          brightness: Brightness.light, // Ou light, baseado no vídeo
          scaffoldBackgroundColor: const Color(0xFF54ADFF), // Cor de fundo do vídeo
        ),
        home: const TelaPrincipal(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}