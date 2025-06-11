// services/ritmo_provider.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/fracao_model.dart';
import '../models/conjunto_ritmo_model.dart';
import '../utils/cores.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RitmoProvider with ChangeNotifier {
  late List<FracaoModel> _fracoes;
  List<ConjuntoRitmoModel> _conjuntosSalvos = [];

  // Quando cada fração estiver "ativada", armazenamos aqui o Timer específico:
  final Map<String, Timer> _timersPorFracao = {};

   final Map<String, List<AudioPlayer>> _playerPool = {
    'b1': List.generate(4, (_) => AudioPlayer()),
    'b2': List.generate(4, (_) => AudioPlayer()),
    'b3': List.generate(4, (_) => AudioPlayer()),
  };
  final Map<String, int> _nextPlayerIdx = {'b1': 0, 'b2': 0, 'b3': 0};

  // late AudioPlayer _playerB1;
  // late AudioPlayer _playerB2;
  // late AudioPlayer _playerB3;
  // Map<String, AudioPlayer> _players = {};

  // Usamos bolinhasMostradas para controlar quantas bolinhas já devem ser desenhadas por fração:
  final Map<String, int> _bolinhasMostradas = {};
  Map<String, int> get bolinhasMostradas => _bolinhasMostradas;

  double _offsetHorizontalScroll = 0.0; // Mantido para a visualização (scroll em "ticks")
  int _subdivisoesPorColunaVisual = 20; // Continua controlando quantas subdivisões a coluna gráfica tem

  // Getters públicos
  List<FracaoModel> get fracoes => _fracoes;
  List<ConjuntoRitmoModel> get conjuntosSalvos => _conjuntosSalvos;
  double get offsetHorizontalScroll => _offsetHorizontalScroll;
  int get subdivisoesPorColunaVisual => _subdivisoesPorColunaVisual;
  bool get estaTocandoGlobalmente => _timersPorFracao.isNotEmpty;


  Future<void> _preloadAssets() async {
  // Para cada fração, aguarda todos os players do pool
  for (var f in _fracoes) {
    final pool = _playerPool[f.id]!;
    await Future.wait(pool.map((p) => p.setAsset('assets/${f.assetSom}')));
  }
}


  RitmoProvider() {
    // Cria as 3 frações iniciais
    _fracoes = [
      FracaoModel(id: 'b1', cor: AppCores.corB1, assetSom: 'sounds/b1_som.mp3'),
      FracaoModel(id: 'b2', cor: AppCores.corB2, assetSom: 'sounds/b2_som.mp3'),
      FracaoModel(id: 'b3', cor: AppCores.corB3, assetSom: 'sounds/b3_som.mp3'),
    ];

   // --- MUDANÇA: Carregar os assets diretamente no pool ---
    // Removemos a inicialização dos players individuais (_playerB1, etc)
    // e o mapa _players.
    for (var f in _fracoes) {
      final pool = _playerPool[f.id]!;
      for (var p in pool) {
        // Não precisamos de 'await' aqui, o carregamento acontece em background.
        p.setAsset('assets/${f.assetSom}');
      }
    }
    _preloadAssets().then((_) => notifyListeners());
    carregarConjuntosSalvos().then((_) => notifyListeners());
  }
 void _tocarSom(String id) {
    final pool = _playerPool[id]!;
    final idx = _nextPlayerIdx[id]!;
    final player = pool[idx];
    _nextPlayerIdx[id] = (idx + 1) % pool.length;

    player
      ..seek(Duration.zero)
      ..play();
  }
  // ------------------------------------------------------------
  // ATUALIZAÇÕES DE FRAÇÃO (numerador:denominador) e seleção
  // ------------------------------------------------------------

  void atualizarValorFracao(String id, String valorInputUsuario) {
    final fracao = _fracoes.firstWhere((f) => f.id == id);
    final partes = valorInputUsuario.split(':');
    if (valorInputUsuario.isEmpty) {
      fracao.numerador = null;
      fracao.denominador = null;
    } else if (partes.length == 2) {
      final numTemp = int.tryParse(partes[0]);
      final denTemp = int.tryParse(partes[1]);
      if (numTemp != null && denTemp != null && denTemp > 0 && numTemp > 0) {
        fracao.numerador = numTemp;
        fracao.denominador = denTemp;
      } else {
        fracao.numerador = null;
        fracao.denominador = null;
      }
    } else {
      fracao.numerador = null;
      fracao.denominador = null;
    }

    // Se essa fração estiver tocando mas agora ficou inválida, paramos seu timer
    if (fracao.estaTocando && (fracao.numerador == null || fracao.denominador == null)) {
      _stopFracaoTimer(id);
      fracao.estaTocando = false;
      _bolinhasMostradas.remove(id);
    }

    notifyListeners();
  }

  void excluirValorFracao(String id) {
    atualizarValorFracao(id, "");
  }

  void toggleSelecaoFaixa(String idFaixa) {
    final fracao = _fracoes.firstWhere((f) => f.id == idFaixa);
    fracao.estaSelecionada = !fracao.estaSelecionada;

    if (fracao.estaSelecionada) {
      // Se agora foi marcada e está com numerador/denominador válidos, inicia imediatamente
      if (fracao.numerador != null && fracao.denominador != null) {
        fracao.estaTocando = true;
        _bolinhasMostradas[idFaixa] = 0;
        _startFracaoTimer(fracao);
      }
    } else {
      // Caso tenha desmarcado, paramos seu timer
      fracao.estaTocando = false;
      _bolinhasMostradas.remove(idFaixa);
      _stopFracaoTimer(idFaixa);
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // LÓGICA DE INÍCIO E PARADA PARA CADA FRAÇÃO (timer individual)
  // ------------------------------------------------------------

  /// Calcula o intervalo em milissegundos a partir de numerador/denominador.
  /// Exemplo: 1/1 → 1000 ms. 3/3 → 1000 ms. 7/9 → (7/9)*1000 ≃ 777 ms.
  int _calcularIntervaloMs(FracaoModel f) {
    // Garantimos que numerador/denominador nunca sejam nulos aqui
    final n = f.numerador!;
    final d = f.denominador!;
    final double segundos = n / d;
    return (segundos * 1000).round();
  }

  /// Inicia um Timer.periodic exclusivo para uma fração que está válid
  // void _startFracaoTimer(FracaoModel f) {
  //   final String id = f.id;

  //   // Se já tinha um timer ativo, paramos antes
  //   _stopFracaoTimer(id);

  //   final intervalo = _calcularIntervaloMs(f);
  //   if (intervalo <= 0) return;

  //   // Cria um novo Timer.periodic para essa fração
  //   final timer = Timer.periodic(Duration(milliseconds: intervalo), (_) async {
  //     // A cada disparo:
  //     // 1) Tocar o som
  //     final player = _players[id];
  //     if (player != null) {
  //       try {
  //       await player.stop();                    // Garante zero state
  //       await player.seek(Duration.zero);       // Volta ao início
  //       await player.play();                    // Toca novamente
  //     } catch (e) {
  //       print("Erro ao tocar som para $id: $e");
  //     }
  //     }
  //     // 2) Incrementar contador de bolinhas
  //     _bolinhasMostradas[id] = (_bolinhasMostradas[id] ?? 0) + 1;
  //     // 3) Notificar a UI para redesenhar
  //     notifyListeners();
  //   });

  //   _timersPorFracao[id] = timer;
  // }

// void _startFracaoTimer(FracaoModel f) {
//   final String id = f.id;
//   _stopFracaoTimer(id);

//   final intervalo = _calcularIntervaloMs(f);
//   if (intervalo <= 0) return;

//   final timer = Timer.periodic(Duration(milliseconds: intervalo), (_) async {
//     // 1) Cria um AudioPlayer temporário
//     final playerTemporario = AudioPlayer();
//     try {
//       await playerTemporario.setAsset('assets/${f.assetSom}');
//       await playerTemporario.seek(Duration.zero);
//       await playerTemporario.play();
//     } catch (e) {
//       print("Erro ao tocar som (player temporário) para $id: $e");
//     } finally {
//       // 2) Dispose do player temporário imediatamente após finalizar
//       playerTemporario.dispose();
//     }

//     // 3) Incrementa bolinhas e notifica a UI
//     _bolinhasMostradas[id] = (_bolinhasMostradas[id] ?? 0) + 1;
//     notifyListeners();
//   });

//   _timersPorFracao[id] = timer;
// }


// void _startFracaoTimer(FracaoModel f) {
//   final String id = f.id;
//   _stopFracaoTimer(id);

//   final intervalo = _calcularIntervaloMs(f);
//   if (intervalo <= 0) return;

//   final timer = Timer.periodic(Duration(milliseconds: intervalo), (_) {
//     // 1) Primeiro incrementa a bolinha e notifica a UI.
//     _bolinhasMostradas[id] = (_bolinhasMostradas[id] ?? 0) + 1;
//     notifyListeners();

//     // 2) Em seguida, dispara o som (fire-and-forget). 
//     //    Não estamos aguardando (await) tudo aqui, 
//     //    apenas garantindo que a bolinha apareça imediatamente.
//     final playerTemporario = AudioPlayer();
//     playerTemporario
//       .setAsset('assets/${f.assetSom}')
//       .then((_) => playerTemporario.seek(Duration.zero))
//       .then((_) => playerTemporario.play())
//       .catchError((e) {
//         print("Erro ao tocar som (player temporário) para $id: $e");
//       })
//       .whenComplete(() {
//         // Depois de tocar (ou em erro), dispomos o player.
//         playerTemporario.dispose();
//       });
//   });

//   _timersPorFracao[id] = timer;
// }

//  void _startFracaoTimer(FracaoModel f) {
//     final String id = f.id;
//     _stopFracaoTimer(id);

//     final intervalo = _calcularIntervaloMs(f);
//     if (intervalo <= 0) return;

//     _timersPorFracao[id] = Timer.periodic(Duration(milliseconds: intervalo), (_) {
//       // 1) Atualiza bolinha e notifica
//       _bolinhasMostradas[id] = (_bolinhasMostradas[id] ?? 0) + 1;
//       notifyListeners();
//       // 2) Toca som reutilizando pool
//       _tocarSom(id);
//     });
//   }

 void _startFracaoTimer(FracaoModel f) {
    final String id = f.id;
    _stopFracaoTimer(id); // Garante que não haja timers duplicados

    final intervalo = _calcularIntervaloMs(f);
    if (intervalo <= 0) return;

    // A cada "tick" do timer, fazemos duas coisas:
    _timersPorFracao[id] = Timer.periodic(Duration(milliseconds: intervalo), (_) {
      // 1) Atualiza a UI para mostrar a nova bolinha
      _bolinhasMostradas[id] = (_bolinhasMostradas[id] ?? 0) + 1;
      notifyListeners();
      
      // 2) Toca o som usando o nosso método do pool
      _tocarSom(id);
    });
  }


  /// Para e remove o Timer da fração de id `id`
  // void _stopFracaoTimer(String id) {
  //   final existing = _timersPorFracao[id];
  //   if (existing != null) {
  //     existing.cancel();
  //     _timersPorFracao.remove(id);
  //   }
  // }

   void _stopFracaoTimer(String id) {
    final t = _timersPorFracao.remove(id);
    t?.cancel();
  }

  /// Para todos os timers de todas as frações
  // void _stopAllFracoes() {
  //   for (final t in _timersPorFracao.values) {
  //     t.cancel();
  //   }
  //   _timersPorFracao.clear();
  // }

   void _stopAllFracoes() {
    _timersPorFracao.values.forEach((t) => t.cancel());
    _timersPorFracao.clear();
  }

  // ------------------------------------------------------------
  // MÉTODOS PÚBLICOS PARA “PLAY / STOP GLOBAL”
  // ------------------------------------------------------------

  /// Se alguma fração estiver selecionada e válida, inicia o respectivo timer.
  /// Se já estaba tocando globalmente, para tudo.
  // void iniciarOuPausarReproducaoGlobal() {
  //   if (estaTocandoGlobalmente) {
  //     // Para tudo:
  //     _timersPorFracao.keys.toList().forEach(_stopFracaoTimer);
  //     // Marca todas as frações como não tocando
  //     for (var f in _fracoes) {
  //       f.estaTocando = false;
  //     }
  //     // _bolinhasMostradas.clear();
  //     notifyListeners();
  //     return;
  //   }

  //   // Se não está tocando, tentamos iniciar cada fração que estiver selecionada e válida
  //   bool algumaIniciada = false;
  //   for (var f in _fracoes) {
  //     if (f.estaSelecionada && f.numerador != null && f.denominador != null) {
  //       f.estaTocando = true;
  //       _bolinhasMostradas[f.id] = 0;
  //       _startFracaoTimer(f);
  //       algumaIniciada = true;
  //     }
  //   }

  //   if (!algumaIniciada) {
  //     // Se nada tinha sido selecionado ou todos inválidos, apenas notifica para atualizar UI
  //     notifyListeners();
  //   } else {
  //     notifyListeners();
  //   }
  // }

   void iniciarOuPausarReproducaoGlobal() {
    if (estaTocandoGlobalmente) {
      _stopAllFracoes();
      for (var f in _fracoes) f.estaTocando = false;
      notifyListeners();
      return;
    }
    // ignore: unused_local_variable
    bool started = false;
    for (var f in _fracoes) {
      if (f.estaSelecionada && f.numerador != null && f.denominador != null) {
        f.estaTocando = true;
        _bolinhasMostradas[f.id] = 0;
        _startFracaoTimer(f);
        started = true;
      }
    }
    notifyListeners();
  }

  // ------------------------------------------------------------
  // CONTROLES DE LARGURA/COLUNAS E SCROLL
  // ------------------------------------------------------------

  void atualizarLarguraColuna(int novaLargura) {
    _subdivisoesPorColunaVisual = novaLargura.clamp(4, 200);
    notifyListeners();
  }

  void definirOffsetHorizontalScroll(double novoOffsetTicks) {
    _offsetHorizontalScroll = novoOffsetTicks;
    notifyListeners();
  }


  void avancarScroll({int colunas = 10}) {
    // Avança o scroll em 'colunas' * 'ticks por coluna'.
    _offsetHorizontalScroll += (colunas * _subdivisoesPorColunaVisual);
    notifyListeners();
  }

  /// Retrocede o scroll para a esquerda em uma quantidade de colunas.
  void retrocederScroll({int colunas = 10}) {
    _offsetHorizontalScroll -= (colunas * _subdivisoesPorColunaVisual);
    // Garante que o scroll não fique negativo.
    if (_offsetHorizontalScroll < 0) {
      _offsetHorizontalScroll = 0;
    }
    notifyListeners();
  }

  // ------------------------------------------------------------
  // SALVAR / CARREGAR RITMOS
  // ------------------------------------------------------------

  Future<void> salvarConjuntoAtual(String nome) async {
    if (nome.isEmpty) return;
    bool temValores = _fracoes.any((f) => f.numerador != null && f.denominador != null);
    if (!temValores) return;

    final novoConjunto = ConjuntoRitmoModel(
      nome: nome,
      fracoes: _fracoes
          .map((f) => FracaoModel(
                id: f.id,
                numerador: f.numerador,
                denominador: f.denominador,
                cor: f.cor,
                assetSom: f.assetSom,
              ))
          .toList(),
    );

    _conjuntosSalvos.removeWhere((c) => c.nome == nome);
    _conjuntosSalvos.add(novoConjunto);
    await _persistirConjuntosSalvos();
    notifyListeners();
  }

  Future<void> _persistirConjuntosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsons = _conjuntosSalvos.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList('conjuntosRitmoSalvos', jsons);
  }

  Future<void> carregarConjuntosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? listas = prefs.getStringList('conjuntosRitmoSalvos');
    if (listas != null) {
      _conjuntosSalvos = listas
          .map((s) => ConjuntoRitmoModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    }
  }

  void aplicarConjuntoSalvo(ConjuntoRitmoModel conjunto) {
    // Para tudo antes de carregar
    iniciarOuPausarReproducaoGlobal(); // isso para todos
    for (int i = 0; i < _fracoes.length; i++) {
      if (i < conjunto.fracoes.length) {
        _fracoes[i].numerador = conjunto.fracoes[i].numerador;
        _fracoes[i].denominador = conjunto.fracoes[i].denominador;
      } else {
        _fracoes[i].numerador = null;
        _fracoes[i].denominador = null;
      }
      _fracoes[i].estaSelecionada = false;
      _fracoes[i].estaTocando = false;
    }
    notifyListeners();
  }

  void excluirConjuntoSalvo(String nome) {
    _conjuntosSalvos.removeWhere((c) => c.nome == nome);
    _persistirConjuntosSalvos();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAllFracoes();
    // limpa pool de players
    for (var pool in _playerPool.values) {
      for (var p in pool) {
        p.dispose();
      }
    }
    super.dispose();
  }
}
