import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ritmatica_app/user_interface/screens/about.dart';
import 'package:ritmatica_app/user_interface/screens/agradecimentos.dart';
import 'package:ritmatica_app/user_interface/screens/instrucoes.dart';
import 'package:ritmatica_app/user_interface/screens/tutorial_screen.dart';
import '../../services/ritmo_provider.dart';
import '../../user_interface/screens/tela_ritmos_salvos.dart'; // Para navegação

class SideMenu extends StatelessWidget {
  final VoidCallback onSalvarRitmo;

  const SideMenu({super.key, required this.onSalvarRitmo});

  @override
  Widget build(BuildContext context) {
    return Consumer<RitmoProvider>(
      builder: (context, ritmoProvider, child) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Semantics(
                            // label: 'Apoio',
                            // header: true,
                            child: const Text(
                              'Apoio',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Semantics(
                            label:
                                'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
                            // image: true,
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/image/IFSP_Logo.png',
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 5),
                                  Image.asset(
                                    'assets/image/CNPQ_Logo.png',
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 5),
                                  Image.asset(
                                    'assets/image/RUMO_Logo.png',
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      left: 230,
                      child: Semantics(
                        label: 'Botão de Fechar menu',
                        // button: true,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: Semantics(
                  label: 'Salvar Ritmo atual na tela',
                  button: true,
                  child: const Text("Salvar Ritmo"),
                ),
                leading: const Icon(
                  Icons.save_alt_outlined,
                  color: Colors.blue,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSalvarRitmo();
                },
              ),
              ListTile(
                title: Semantics(
                  label: 'Abrir a página com lista de Ritmos Salvos',
                  button: true,
                  child: const Text("Lista de Ritmos Salvas"),
                ),
                leading: const Icon(
                  Icons.list_alt_outlined,
                  color: Colors.blue,
                ),

                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaRitmosSalvos()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined, color: Colors.blue), 
                title: Semantics(
                  label: 'Abrir tutorial para entender os conceitos do aplicativo',
                  button: true,
                  child: const Text("Entendendo o Ritmática"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TutorialScreen(), 
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_column, color: Colors.blue),
                subtitle: Semantics(
                  label: 'Ajustar a Largura da Coluna.',
                  child: Consumer<RitmoProvider>(
                    builder: (_, provider, __) {
                      return ExcludeSemantics(
                        child: Slider(
                          min: 20,
                          max: 200,
                          divisions: 8,
                          value: provider.subdivisoesPorColunaVisual.toDouble(),
                          label: 'Largura da Coluna.',

                          onChanged: (valor) {
                            provider.atualizarLarguraColuna(valor.toInt());
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              ListTile(
                title: Semantics(
                  label: 'Abrir a página com as instruções de uso',
                  button: true,
                  child: const Text("Instruções de Uso"),
                ),
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsageInstructionsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: Colors.blue),
                title: Semantics(
                  label: 'Abrir a página de agradecimentos',
                  child: const Text("Agradecimentos"),
                ),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThankYouScreen(),
                      ),
                    ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: Semantics(
                  label: 'Abrir a página de informações sobre o aplicativo',
                  child: const Text("Sobre"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
