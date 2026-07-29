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
              title: '1. Definir uma Relação Rítmica',
              description:
                  'Na tela principal, você encontrará três faixas (R1, R2, R3). Cada uma possui dois campos: "B" (intervalo de tempo) e "D" (número de batidas). Por exemplo, para criar a relação "2 para 3", insira "2" no campo B e "3" no campo D.',
            ),
            _buildInstructionItem(
              title: '2. Ativar Faixas para Tocar',
              description:
                  'Após definir os valores, clique no botão com o nome da faixa (R1, R2 ou R3) para ativá-la. Apenas as faixas ativas serão reproduzidas. As faixas ativas ficam com a cor destacada.',
            ),
            _buildInstructionItem(
              title: '3. Iniciar ou Parar a Reprodução',
              description:
                  'Pressione o botão "Play" para iniciar a animação e os sons de todas as faixas que foram ativadas. Para interromper a reprodução, pressione o botão "Stop".',
            ),
            _buildInstructionItem(
              title: '4. Navegar pela Linha do Tempo',
              description:
                  'Utilize a barra deslizante horizontal ou os botões de seta para avançar ou retroceder na linha do tempo, ajustando a visualização da animação na tela.',
            ),
            _buildInstructionItem(
              title: '5. Ajustar a Densidade Visual',
              description:
                  'No menu lateral (canto superior esquerdo), use a barra "Largura da Coluna" para aumentar ou diminuir o espaçamento visual das batidas.',
            ),
            _buildInstructionItem(
              title: '6. Salvar um Ritmo',
              description:
                  'Para salvar o conjunto de razões que você criou, abra o menu lateral e clique em "Salvar Ritmo".',
            ),
            _buildInstructionItem(
              title: '7. Carregar um Ritmo Salvo',
              description:
                  'No menu lateral, selecione "Lista de Ritmos Salvas". Na nova tela, encontre o ritmo desejado e clique no botão "Aplicar" para carregá-lo na tela principal.',
            ),
            _buildInstructionItem(
              title: '8. Excluir um Ritmo Salvo',
              description:
                  'Na tela de "Ritmos Salvos", utilize o ícone de lixeira em um ritmo para excluí-lo permanentemente da sua lista.',
            ),
            _buildInstructionItem(
              title: '9. Limpar Valores de uma Faixa',
              description:
                  'Para apagar os números de uma faixa (R1, R2 ou R3) na tela principal, clique no ícone de lixeira localizado à direita dos campos de entrada da relação correspondente.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
      {required String title, required String description}) {
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