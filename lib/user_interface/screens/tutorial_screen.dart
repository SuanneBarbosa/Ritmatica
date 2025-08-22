import 'package:flutter/material.dart';



class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutorial: Entendendo o Ritmática"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionCard(
              context,
              title: 'O que é o Ritmática?',
              content: const Text(
                'Bem-vindo ao Ritmática! Este não é apenas um aplicativo de música, mas uma ferramenta para explorar a matemática dos ritmos de uma forma visual e sonora.\n\n'
                'Ele foi projetado para ser uma experiência multissensorial, ajudando a entender conceitos de razão e proporção de maneira intuitiva.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            _buildSectionCard(
              context,
              title: 'O Conceito Principal: Criando um Ritmo',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cada faixa (B1, B2, B3) possui dois campos para criar um ritmo. A relação entre esses dois números é a base de tudo:',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildConceptBox(
                    'Primeiro Campo (N): Intervalo de Tempo',
                    'Representa "em quanto tempo" um ciclo rítmico acontece. Um número maior significa um ciclo mais longo e, portanto, um ritmo mais lento.',
                  ),
                  const SizedBox(height: 12),
                  _buildConceptBox(
                    'Segundo Campo (D): Número de Batidas',
                    'Representa "quantas batidas" (sons e bolinhas) acontecem dentro daquele intervalo de tempo.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Exemplo Prático:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se você inserir "2 : 3", significa que:',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  _buildBulletPoint(
                      'Em um intervalo de 2 unidades de tempo, você ouvirá 3 batidas.'),
                  _buildBulletPoint(
                      'Visualmente, você verá 3 bolinhas coloridas aparecendo de forma regular ao longo de um espaço que representa essas 2 unidades de tempo.'),
                ],
              ),
            ),
            _buildSectionCard(
              context,
              title: 'Explorando Polirritmos',
              content: const Text(
                'Quando você ativa mais de uma faixa ao mesmo tempo (por exemplo, B1 e B2), você cria um "polirritmo".\n\n'
                'Isso permite comparar visual e sonoramente duas razões diferentes. Como a relação 2:3 soa e se parece em comparação com 4:5? Experimente e descubra as relações entre elas!',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
             _buildSectionCard(
              context,
              title: 'Descobrindo a Proporção (Ritmos Equivalentes)',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'Uma das ideias mais importantes que você pode explorar é a proporção. Tente inserir os seguintes ritmos em duas faixas diferentes:',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                   const SizedBox(height: 10),
                  _buildBulletPoint('Faixa B1: 2 : 3'),
                  _buildBulletPoint('Faixa B2: 4 : 6'),
                  const SizedBox(height: 10),
                  const Text(
                    'Você perceberá que o ritmo fundamental é o mesmo! A faixa 4:6 é apenas uma versão mais lenta da 2:3, mas a proporção entre o tempo e as batidas (2 para 3) foi mantida. Isso é proporção em ação!',
                     style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
             _buildSectionCard(
              context,
              title: 'Para Acessibilidade',
              content: const Text(
                'O Ritmática foi pensado para todos. Se você possui deficiência visual, os sons são sua principal ferramenta para perceber a relação entre as frações. Se possui deficiência auditiva, a animação das bolinhas e das linhas no visualizador cumpre o mesmo papel, mostrando visualmente a estrutura do ritmo.',
                 style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title, required Widget content}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildConceptBox(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

   Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5))),
        ],
      ),
    );
  }
}