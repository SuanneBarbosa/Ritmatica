import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/fracao_model.dart';
import '../models/conjunto_ritmo_model.dart';
import '../utils/cores.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';


class RitmoProvider with ChangeNotifier {
  late List<FracaoModel> _fracoes;
  List<ConjuntoRitmoModel> _conjuntosSalvos = [];
  final Map<String, Timer> _timersPorFracao = {};
  final Map<String, List<AudioPlayer>> _playerPool = {
    'r1': List.generate(4, (_) => AudioPlayer()),
    'r2': List.generate(4, (_) => AudioPlayer()),
    'r3': List.generate(4, (_) => AudioPlayer()),
  };
  final Map<String, int> _nextPlayerIdx = {'r1': 0, 'r2': 0, 'r3': 0};
  final Map<String, int> _bolinhasMostradas = {};
  Map<String, int> get bolinhasMostradas => _bolinhasMostradas;
  double _offsetHorizontalScroll = 0.0; 
  int _subdivisoesPorColunaVisual = 20; 


 
  List<FracaoModel> get fracoes => _fracoes;
  List<ConjuntoRitmoModel> get conjuntosSalvos => _conjuntosSalvos;
  double get offsetHorizontalScroll => _offsetHorizontalScroll;
  int get subdivisoesPorColunaVisual => _subdivisoesPorColunaVisual;
  bool get estaTocandoGlobalmente => _timersPorFracao.isNotEmpty;




  Future<void> _preloadAssets() async {
  for (var f in _fracoes) {
    final pool = _playerPool[f.id]!;
    await Future.wait(pool.map((p) => p.setAsset('assets/${f.assetSom}')));
  }
}

  RitmoProvider() {
   
    _fracoes = [
      FracaoModel(id: 'r1', cor: AppCores.corB1, assetSom: 'sounds/r1_som.mp3'),
      FracaoModel(id: 'r2', cor: AppCores.corB2, assetSom: 'sounds/r2_som.mp3'),
      FracaoModel(id: 'r3', cor: AppCores.corB3, assetSom: 'sounds/r3_som.mp3'),
    ];

    for (var f in _fracoes) {
      final pool = _playerPool[f.id]!;
      for (var p in pool) {
        p.setAsset('assets/${f.assetSom}');
      }
    }
    _preloadAssets().then((_) => notifyListeners());
    carregarConjuntosSalvos().then((_) => notifyListeners());
  }

void resetarRitmo() {
    _stopAllFracoes();
    _bolinhasMostradas.clear();

    for (var fracao in _fracoes) {
      fracao.numerador = null;     
      fracao.denominador = null;    
      fracao.estaSelecionada = false; 
      fracao.estaTocando = false;    
    }
    notifyListeners();
  }


 Future<void> _tocarSom(String id) async {
    final pool = _playerPool[id]!;
    final idx = _nextPlayerIdx[id]!;
    final player = pool[idx];
    _nextPlayerIdx[id] = (idx + 1) % pool.length;

    if (kIsWeb) {
      try {
        if (player.playing) {
          await player.stop();
        }
        await player.seek(Duration.zero);
        player.play();
      } catch (e) {
        debugPrint("Erro player web: $e");
      }
    } else {
      player
        ..seek(Duration.zero)
        ..play();
    }
  }
 

  void atualizarValorFracao(String id, String valorInputUsuario) {
    final fracao = _fracoes.firstWhere((f) => f.id == id);

    if (!estaTocandoGlobalmente && _bolinhasMostradas.containsKey(id)) {
      _bolinhasMostradas.remove(id);
    }
   
    final partes = valorInputUsuario.split(':');

    if (partes.isNotEmpty) {
      final numTemp = int.tryParse(partes[0]);
      fracao.numerador = (numTemp != null && numTemp > 0) ? numTemp : null;
    } else {
      fracao.numerador = null;
    }

    if (partes.length > 1) {
      final denTemp = int.tryParse(partes[1]);
      fracao.denominador = (denTemp != null && denTemp > 0) ? denTemp : null;
    } else {
      fracao.denominador = null;
    }
    
    final bool isFractionValid = fracao.numerador != null && fracao.denominador != null;
    
    if (!isFractionValid) {
      fracao.estaSelecionada = false; 
      if (fracao.estaTocando) {
        _stopFracaoTimer(id);
        fracao.estaTocando = false;
        _bolinhasMostradas.remove(id);
      }
    }
    
    notifyListeners();
  }


  void pararFracaoSeTocando(String id) {
    final fracao = _fracoes.firstWhere((f) => f.id == id);

   
    if (fracao.estaTocando) {
      _stopFracaoTimer(id);
      fracao.estaTocando = false;
      fracao.estaSelecionada = false; 
      _bolinhasMostradas.remove(id); 
      
     
      notifyListeners();
    }
  }

  void excluirValorFracao(String id) {
    atualizarValorFracao(id, "");
  }


  void toggleSelecaoFaixa(String idFaixa) {
    final fracao = _fracoes.firstWhere((f) => f.id == idFaixa);
    final bool isFractionValid = fracao.numerador != null && fracao.denominador != null;

    if (!fracao.estaSelecionada && !isFractionValid) {
      return; 
    }
    
    fracao.estaSelecionada = !fracao.estaSelecionada;

    if (fracao.estaSelecionada) {
     
      fracao.estaTocando = true;
      _bolinhasMostradas[idFaixa] = 0;
      _startFracaoTimer(fracao);
    } else {
      
      fracao.estaTocando = false;
      _bolinhasMostradas.remove(idFaixa);
      _stopFracaoTimer(idFaixa);
    }

    notifyListeners();
  }


  int _calcularIntervaloMs(FracaoModel f) {
   if (f.numerador == null || f.denominador == null || f.denominador == 0) {
      return 0;
    }
    final a = f.numerador!;
    final b = f.denominador!;
    final double segundos = a / b;
    return (segundos * 1000).round();
  }


  int getIntervaloMsPorId(String id) {
    try {
      final fracao = _fracoes.firstWhere((f) => f.id == id);
      return _calcularIntervaloMs(fracao);
    } catch (e) {
      return 0;
    }
  }


 void _startFracaoTimer(FracaoModel f) {
  final String id = f.id;
  _stopFracaoTimer(id);

  final intervalo = _calcularIntervaloMs(f);
  if (intervalo <= 0) return;

  _bolinhasMostradas[id] = 1;
  
  _tocarSom(id);
  notifyListeners();

  _timersPorFracao[id] = Timer.periodic(Duration(milliseconds: intervalo), (_) {

  _bolinhasMostradas[id] = (_bolinhasMostradas[id] ?? 1) + 1;
    
    _tocarSom(id);
    notifyListeners();
  });
}



   void _stopFracaoTimer(String id) {
    final t = _timersPorFracao.remove(id);
    t?.cancel();
  }


   void _stopAllFracoes() {
    for (var t in _timersPorFracao.values) {
      t.cancel();
    }
    _timersPorFracao.clear();
  }



   void iniciarOuPausarReproducaoGlobal() {
    if (estaTocandoGlobalmente) {
      _stopAllFracoes();
      for (var f in _fracoes) {
        f.estaTocando = false;
      }
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


  void atualizarLarguraColuna(int novaLargura) {
    _subdivisoesPorColunaVisual = novaLargura.clamp(4, 200);
    notifyListeners();
  }


  void definirOffsetHorizontalScroll(double novoOffsetTicks) {
    _offsetHorizontalScroll = novoOffsetTicks;
    notifyListeners();
  }



  void avancarScroll({int colunas = 10}) {
    _offsetHorizontalScroll += (colunas * _subdivisoesPorColunaVisual);
    notifyListeners();
  }


 
  void retrocederScroll({int colunas = 10}) {
    _offsetHorizontalScroll -= (colunas * _subdivisoesPorColunaVisual);
    if (_offsetHorizontalScroll < 0) {
      _offsetHorizontalScroll = 0;
    }
    notifyListeners();
  }



  Future<bool> salvarConjuntoAtual() async {
    final List<FracaoModel> fracoesValidas = _fracoes
        .where((f) => f.numerador != null && f.denominador != null)
        .toList();

    if (fracoesValidas.isEmpty) {
      print("Nenhuma fração válida para salvar.");
      return false;
    }

    final nomeAutomatico = fracoesValidas
        .map((f) => f.valorExibicao)
        .where((v) => v.isNotEmpty)
        .join(' | ');

    final novoConjunto = ConjuntoRitmoModel(
      nome: nomeAutomatico,
      fracoes: _fracoes.map((f) {
        final bool isFractionValid = f.numerador != null && f.denominador != null;
        return FracaoModel(
          id: f.id,
          numerador: isFractionValid ? f.numerador : null,
          denominador: isFractionValid ? f.denominador : null,
          cor: f.cor,
          assetSom: f.assetSom,
        );
      }).toList(),
    );

    _conjuntosSalvos.removeWhere((c) => c.nome == nomeAutomatico);
    _conjuntosSalvos.add(novoConjunto);
    await _persistirConjuntosSalvos();
    notifyListeners();
     return true;
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
   
    if (estaTocandoGlobalmente) {
      _stopAllFracoes();
      _bolinhasMostradas.clear();
      for (var f in _fracoes) {
        f.estaTocando = false;
      }
    }

   
    for (int i = 0; i < _fracoes.length; i++) {
      final fracaoAtual = _fracoes[i];
      
      if (i < conjunto.fracoes.length) {
        final fracaoSalva = conjunto.fracoes[i];
        
       
        fracaoAtual.numerador = fracaoSalva.numerador;
        fracaoAtual.denominador = fracaoSalva.denominador;

      } else {
        fracaoAtual.numerador = null;
        fracaoAtual.denominador = null;
      }
      
      fracaoAtual.estaSelecionada = false;
      fracaoAtual.estaTocando = false;
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
    for (var pool in _playerPool.values) {
      for (var p in pool) {
        p.dispose();
      }
    }
    super.dispose();
  }
}
