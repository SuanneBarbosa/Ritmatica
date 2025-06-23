// user_interface/widgets/teclado_numerico.dart

import 'package:flutter/material.dart';

class TecladoNumerico extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onConfirmPressed;

  const TecladoNumerico({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Envolvemos em um SafeArea para evitar áreas como a "home bar" do iOS/Android.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Faz a coluna ter o tamanho dos filhos
          children: [
            _buildRow(['1', '2', '3']),
            _buildRow(['4', '5', '6']),
            _buildRow(['7', '8', '9']),
            _buildSpecialRow(),
          ],
        ),
      ),
    );
  }

  // Helper para criar uma linha de botões numéricos
  Widget _buildRow(List<String> digits) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: digits.map((digit) => _buildDigitButton(digit)).toList(),
      ),
    );
  }

  // Helper para criar a linha inferior com botões especiais
  Widget _buildSpecialRow() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botão de Apagar
          _buildActionButton(
            icon: Icons.backspace_outlined,
            onPressed: onBackspacePressed,
            label: 'Apagar último dígito',
          ),
          // Botão 0
          _buildDigitButton('0'),
          // Botão OK
          _buildActionButton(
            icon: Icons.check_circle_outline,
            onPressed: onConfirmPressed,
            label: 'Confirmar e fechar teclado',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // Helper para criar o botão de um dígito
  Widget _buildDigitButton(String digit) {
    return Expanded(
      child: Semantics(
        label: 'Dígito $digit',
        button: true,
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            onPressed: () => onDigitPressed(digit),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(digit, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // Helper para criar os botões de ação (Apagar, OK)
  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed, required String label, Color? color}) {
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }
}