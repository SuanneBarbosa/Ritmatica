import 'package:flutter/material.dart';

class UsageInstructionsScreen extends StatelessWidget {
  const UsageInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruções de Uso'),
         backgroundColor: Colors.blue, 
         titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
         color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: ListView(
          children: [
            _buildInstructionItem(
              title: '1. Definir Frações',
              description:
                  'Na tela principal, você encontrará três faixas (B1, B2 e B3). Em cada uma delas, insira uma fração usando os campos de numerador (N) e denominador (D), por exemplo: 3/4, 1/2, etc. Esses valores controlarão o ritmo e a quantidade de bolinhas geradas na animação.',
            ),
            _buildInstructionItem(
              title: '2. Ativar ou Desativar Faixas',
              description:
                  'Após definir os valores, clique no botão com o nome da faixa (B1, B2 ou B3) para ativar ou desativar aquela faixa na reprodução. As faixas ativas serão exibidas com uma cor mais destacada.',
            ),
            _buildInstructionItem(
              title: '3. Iniciar ou Parar a Reprodução',
              description:
                  'Pressione o botão de "Play" para iniciar a animação das bolinhas e a reprodução dos sons. Para interromper a reprodução, pressione o botão de "Stop".',
            ),
            _buildInstructionItem(
              title: '4. Navegar por colunas',
              description:
                  'Utilize o slider horizontal ou os botões de seta para avançar ou retroceder as colunas, ajustando a posição da visualização das bolinhas no espaço da tela.',
            ),
            _buildInstructionItem(
              title: '5. Ajustar a Largura da Coluna',
              description:
                  'No menu lateral, você pode usar o slider "Largura da Coluna" para aumentar ou diminuir a quantidade de subdivisões visíveis por coluna, alterando assim o espaçamento e a densidade das bolinhas na coluna.',
            ),
            _buildInstructionItem(
              title: '6. Salvar um Ritmo',
              description:
                  'Para salvar um ritmo que você criou, abra o menu lateral e clique em "Salvar Ritmo Atual". O sistema irá armazenar o conjunto de frações e suas configurações atuais.',
            ),
            _buildInstructionItem(
              title: '7. Carregar um Ritmo Salvo',
              description:
                  'No menu lateral, selecione "Ver Ritmos Salvos". Você verá uma lista dos ritmos que já foram salvos. Clique em um deles para aplicar os valores e carregá-lo na tela principal.',
            ),
            _buildInstructionItem(
              title: '8. Excluir um Ritmo Salvo',
              description:
                  'Na tela de ritmos salvos, utilize o ícone de lixeira ao lado de um ritmo para excluí-lo permanentemente.',
            ),
            _buildInstructionItem(
              title: '9. Limpar Valores de uma Faixa',
              description:
                  'Para remover os valores de uma fração (numerador e denominador), clique no ícone de lixeira ao lado dos campos de entrada da faixa correspondente.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem({required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const Divider(
          thickness: 1,
          height: 20,
        ),
      ],
    );
  }
}
