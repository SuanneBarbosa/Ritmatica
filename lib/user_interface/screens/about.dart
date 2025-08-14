import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),

            _buildSupportCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Ritmática',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Versão 1.0',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
            const Divider(height: 30),
            _buildSectionTitle('O que é o App?'),
            const Text(
              'O Ritmática é uma ferramenta educacional que transforma conceitos de ritmo e frações em uma experiência visual e sonora, facilitando o aprendizado através de animações e sons.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Principais Funcionalidades'),
            _buildFeatureItem(
              Icons.edit,
              'Configuração de Frações:',
              'Digite frações como 1/2, 3/4 ou 5/3 nas faixas B1, B2 e B3 para definir os padrões rítmicos de cada linha.',
            ),
            _buildFeatureItem(
              Icons.play_circle_outline,
              'Reprodução com Som e Animação:',
              'Toque no botão de ativar B1, B2 ou B3 para ativar a reprodução. O app irá exibir a animação das bolinhas e tocar sons correspondentes a cada fração configurada.',
            ),
            _buildFeatureItem(
              Icons.tune,
              'Ajuste de Visualização:',
              'Use o controle de largura da coluna para aumentar ou diminuir a densidade das bolinhas no mosaico e explore o slider horizontal para navegar pelas colunas visíveis.',
            ),
            _buildFeatureItem(
              Icons.save_alt,
              'Salvar e Carregar Ritmos:',
              'Salve suas configurações de ritmo e recupere-as quando quiser através da tela de Ritmos Salvos.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSectionTitle('Apoio Institucional'),
            const SizedBox(height: 15),
            Semantics(
              label:
                  'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/image/IFSP_Logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/image/CNPQ_Logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/image/RUMO_Logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $description'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
