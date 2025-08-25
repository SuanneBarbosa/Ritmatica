// services/tutorial_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  // Chave para controlar se a tela de orientação já foi exibida
  static const _orientationShownKey = 'orientation_shown';
  
  // Chave para controlar se o tutorial interativo da tela principal foi concluído
  static const _mainTutorialCompletedKey = 'main_tutorial_completed';

  /// Verifica se a tela de orientação já foi mostrada.
  Future<bool> isOrientationShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_orientationShownKey) ?? false;
  }

  /// Marca a tela de orientação como vista.
  Future<void> markOrientationAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orientationShownKey, true);
  }

  /// Verifica se o tutorial principal já foi concluído.
  Future<bool> isMainTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_mainTutorialCompletedKey) ?? false;
  }

  /// Marca o tutorial principal como concluído.
  Future<void> markMainTutorialAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mainTutorialCompletedKey, true);
  }
}