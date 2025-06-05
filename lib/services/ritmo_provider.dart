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
  
  // _subdivisoesPorColunaVisual: Quantos "ticks" lógicos uma coluna visual possui.
  // Controlado pelo slider "Largura da Coluna" no SideMenu.
  int _subdivisoesPorColunaVisual = 20; // Valor inicial (ex: permite 1/2, 1/3, 1/4, 1/6, 1/8, 1/12)
                                        // O slider do side menu atualiza este valor.

  late AudioPlayer _playerB1;
  late AudioPlayer _playerB2;
  late AudioPlayer _playerB3;
  Map<String, AudioPlayer> _players = {};

  Timer? _timerReproducao;
  int _batidaAtual = -1; // Representa o tick atual (0 a _subdivisoesPorColunaVisual - 1)
  double _tempoBPM = 120.0;

  // REMOVIDO: COMPRIMENTO_PADRAO_VISUALIZADOR_SUBDIVISOES
  // REMOVIDO: _totalSubdivisoesNecessarias (o pintor não usará mais da mesma forma)

  double _offsetHorizontalScroll = 0.0; // Em unidades de "tick"

  // Getters
  List<FracaoModel> get fracoes => _fracoes;
  List<ConjuntoRitmoModel> get conjuntosSalvos => _conjuntosSalvos;
  int get batidaAtual => _batidaAtual;
  // int get totalSubdivisoesNecessarias => _subdivisoesPorColunaVisual; // Se algo ainda precisar de um "ciclo"
  double get offsetHorizontalScroll => _offsetHorizontalScroll;
  double get tempoBPM => _tempoBPM;
  bool get estaTocandoGlobalmente => _timerReproducao != null && _timerReproducao!.isActive;
  int get subdivisoesPorColunaVisual => _subdivisoesPorColunaVisual;

  int get totalTicksGlobais => 20 * _subdivisoesPorColunaVisual; // 20 colunas visíveis
int get indiceColunaAtual => _batidaAtual ~/ _subdivisoesPorColunaVisual;
int get tickDentroDaColunaAtual => _batidaAtual % _subdivisoesPorColunaVisual;



final Map<String, int> _bolinhasMostradas = {};
Map<String, int> get bolinhasMostradas => _bolinhasMostradas;
  

  RitmoProvider() {
    _fracoes = [
      FracaoModel(id: 'b1', cor: AppCores.corB1, assetSom: 'sounds/b1_som.mp3'),
      FracaoModel(id: 'b2', cor: AppCores.corB2, assetSom: 'sounds/b2_som.mp3'),
      FracaoModel(id: 'b3', cor: AppCores.corB3, assetSom: 'sounds/b3_som.mp3'),
    ];

    _playerB1 = AudioPlayer();
    _playerB2 = AudioPlayer();
    _playerB3 = AudioPlayer();
    _players = {'b1': _playerB1, 'b2': _playerB2, 'b3': _playerB3};

    _players.forEach((id, player) async {
      final fraction = _fracoes.firstWhere((f) => f.id == id);
      try {
        await player.setAsset('assets/${fraction.assetSom}');
      } catch (e) {
        print("Erro ao carregar asset para $id: $e");
      }
    });

    carregarConjuntosSalvos().then((_) {
      _notificarMudancasVisuais();
    });
  }

  void _notificarMudancasVisuais() {
    // Esta função é chamada quando algo que afeta a visualização (não os padrões de batida) muda.
    // Ex: mudança de fração, largura da coluna.
    // O cálculo do `padrãoBatida` foi removido do FracaoModel.
    notifyListeners();
    print("RitmoProvider: Mudanças visuais notificadas. subdivisoesPorColunaVisual: $_subdivisoesPorColunaVisual");
  }


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
        // Adicionar uma verificação para numerador <= denominador se fizer sentido para o seu app
        // if (numTemp <= denTemp) {
        fracao.numerador = numTemp;
        fracao.denominador = denTemp;
        // } else {
        //   fracao.numerador = null;
        //   fracao.denominador = null;
        // }
      } else {
        fracao.numerador = null;
        fracao.denominador = null;
      }
    } else {
      fracao.numerador = null;
      fracao.denominador = null;
    }

    _notificarMudancasVisuais();

    if (fracao.estaTocando && (fracao.numerador == null || fracao.denominador == null)) {
        fracao.estaTocando = false;
        if (estaTocandoGlobalmente && !_fracoes.any((f) => f.estaTocando)) {
            pararReproducao();
        }
    }
  }
  
  void atualizarLarguraColuna(int novaLargura) {
    _subdivisoesPorColunaVisual = novaLargura.clamp(20, 200); // Mínimo de 1 tick por coluna
    _notificarMudancasVisuais();
    if (estaTocandoGlobalmente) { // Reinicia a reprodução para aplicar nova duração de tick
        pararReproducao();
        iniciarOuPausarReproducaoGlobal();
    }
  }

  void excluirValorFracao(String id) {
    atualizarValorFracao(id, "");
  }

  void toggleSelecaoFaixa(String idFaixa) {
    final fracao = _fracoes.firstWhere((f) => f.id == idFaixa);
    fracao.estaSelecionada = !fracao.estaSelecionada;

    if (estaTocandoGlobalmente) {
      if (fracao.estaSelecionada && fracao.numerador != null && fracao.denominador != null) {
        fracao.estaTocando = true;
      } else {
        fracao.estaTocando = false;
      }
      if (!_fracoes.any((f) => f.estaTocando)) {
        pararReproducao();
      }
    }
    notifyListeners();
  }




 void iniciarOuPausarReproducaoGlobal() {
    if (estaTocandoGlobalmente) {
      pararReproducao();
      return;
    }

    bool algumaSelecionadaValida = false;
    for (var f in _fracoes) {
      f.estaTocando = f.estaSelecionada && f.numerador != null && f.denominador != null && f.denominador! > 0;
      if (f.estaTocando) algumaSelecionadaValida = true;
    }

    if (!algumaSelecionadaValida) {
      // Se nada válido está selecionado para tocar, apenas notifica e retorna.
      // Isso pode acontecer se o usuário desmarcar tudo ou limpar os valores.
      // Se já estava tocando, o pararReproducao() acima já lidou com isso.
      // Se não estava tocando, não há nada a iniciar.
      notifyListeners(); // Para atualizar o estado do botão play/stop se necessário
      return;
    }

    // **ZERAR O CONTADOR DE BOLINHAS PARA CADA FRAÇÃO** antes de iniciar
    _bolinhasMostradas.clear();
    for (var f in _fracoes.where((f) => f.estaTocando)) {
      _bolinhasMostradas[f.id] = 0;
    }
    _batidaAtual = -1; /////mudei aqui
    _timerReproducao?.cancel();

    final msPorTick = ((60.0 / _tempoBPM) / _subdivisoesPorColunaVisual) * 1000;
    if (msPorTick <= 0) return; // Evita erro se _subdivisoesPorColunaVisual for 0 ou BPM muito alto

    _timerReproducao = Timer.periodic(
      
      Duration(milliseconds: msPorTick.round()),
      (timer) {
        // Verifica se ainda há algo para tocar, senão para o timer.
        // Isso é uma segurança caso as frações se tornem inválidas durante a reprodução.
        bool aindaTemOQueTocar = false;
        for (var f in _fracoes) {
          if (f.estaTocando && f.numerador != null && f.denominador != null && f.denominador! > 0) {
            aindaTemOQueTocar = true;
            break;
          }
        }
        if (!aindaTemOQueTocar) {
          pararReproducao(); // Para tudo e reseta
          return;
        }

        // 1. Avança o estado do tempo/scanner para o PRÓXIMO tick
        final totalColunasVisuais = 20; // Conforme usado para o ciclo do _batidaAtual
        final totalTicksGlobaisNoCicloVisual = totalColunasVisuais * _subdivisoesPorColunaVisual;
        _batidaAtual = (_batidaAtual + 1) % totalTicksGlobaisNoCicloVisual;

        // 2. Calcula a posição do scanner dentro da coluna visual ATUAL
        final int tickDentroDaColunaAtual = _batidaAtual % _subdivisoesPorColunaVisual;

         // 4. Para cada fração ativa, verifica se deve disparar um evento (tocar som + "aparecer bolinha")
    bool notificar = false; // se alguma bolinha foi incrementada, então notificamos
    for (var f in _fracoes.where((f) => f.estaTocando)) {
      final N = f.numerador!;
      final D = f.denominador!;

          // Para cada um dos N eventos (k de 0 a N-1)
          for (int k = 0; k < N; k++) {
            // Calcula em qual tick DENTRO DE UMA COLUNA VISUAL este evento k deve soar.
            // Esta é a fórmula que você estava usando, interpretada como:
            // N eventos, onde o k-ésimo evento ocorre no início da k-ésima
            // "fatia" de tamanho (1/D) da duração da coluna.
            final tickEvento = ((k * _subdivisoesPorColunaVisual) / D).floor();

            if (tickDentroDaColunaAtual == tickEvento) {
              final player = _players[f.id];
              ////Toca a musica
              if (player != null) {
                player.seek(Duration.zero);
                player.play().catchError((e) {
                  // Adicionar tratamento de erro se o play falhar
                  print("Erro ao tocar som para ${f.id}: $e");
                });
                // print("Som: ${f.id} (Evento $k) @ _batidaAtual: $_batidaAtual (tickNaColuna: $tickDentroDaColunaAtual == tickEvento: $tickEvento)");
              }
          // **Incrementa o contador de bolinhas dessa fração** 
          // (garantindo que a chave exista; se por algum motivo não existir, inicializa em zero)
          _bolinhasMostradas[f.id] = (_bolinhasMostradas[f.id] ?? 0) + 1;
          notificar = true;


            }
          }
        }

        // 4. Notifica a UI para redesenhar com o _batidaAtual NOVO (que agora é o atual)
        if (notificar) {
      notifyListeners();
    }
      },
    );

    // Notifica para atualizar o ícone de play/stop e estado inicial
    notifyListeners();
  }

 void pararReproducao() {
  _timerReproducao?.cancel();
  _timerReproducao = null;
  for (var fracao in _fracoes) {
    fracao.estaTocando = false;
  }
  // _batidaAtual = 0; 
   _batidaAtual = -1; /////mudei aqui
  _players.values.forEach((player) => player.stop());

  // **ZERAR CONTADOR DE BOLINHAS** (opcional, se você quiser que a tela volte imediatamente ao estado sem nenhuma bolinha)
  _bolinhasMostradas.clear();

  notifyListeners();
}

  Future<void> salvarConjuntoAtual(String nome) async {
    // ... (código existente)
    // A criação de FracaoModel para salvar não precisa mais de padraoBatida
    if (nome.isEmpty) return;
    bool temValores = _fracoes.any((f) => f.numerador != null && f.denominador != null);
    if (!temValores) return;

    final novoConjunto = ConjuntoRitmoModel(
        nome: nome,
        fracoes: _fracoes.map((f) => FracaoModel( // Salva o estado essencial
            id: f.id,
            numerador: f.numerador,
            denominador: f.denominador,
            cor: f.cor,
            assetSom: f.assetSom
            // não salva estaTocando, estaSelecionada
            )).toList());

    _conjuntosSalvos.removeWhere((conjunto) => conjunto.nome == nome);
    _conjuntosSalvos.add(novoConjunto);
    await _persistirConjuntosSalvos();
    notifyListeners();
  }

  Future<void> _persistirConjuntosSalvos() async {
    // ... (código existente)
     final prefs = await SharedPreferences.getInstance();
    List<String> conjuntosJson = _conjuntosSalvos.map((conjunto) => jsonEncode(conjunto.toJson())).toList();
    await prefs.setStringList('conjuntosRitmoSalvos', conjuntosJson);
  }

  Future<void> carregarConjuntosSalvos() async {
    // ... (código existente)
    final prefs = await SharedPreferences.getInstance();
    List<String>? conjuntosJson = prefs.getStringList('conjuntosRitmoSalvos');
    if (conjuntosJson != null) {
      _conjuntosSalvos = conjuntosJson.map((s) => ConjuntoRitmoModel.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
    }
    // Não chama notifyListeners aqui, _notificarMudancasVisuais fará isso se necessário no construtor.
  }

  void aplicarConjuntoSalvo(ConjuntoRitmoModel conjunto) {
    pararReproducao();
    for (int i = 0; i < _fracoes.length; i++) {
      if (i < conjunto.fracoes.length) {
        _fracoes[i].numerador = conjunto.fracoes[i].numerador;
        _fracoes[i].denominador = conjunto.fracoes[i].denominador;
      } else {
        _fracoes[i].numerador = null;
        _fracoes[i].denominador = null;
      }
      _fracoes[i].estaSelecionada = false; // Resetar seleção ao carregar
      _fracoes[i].estaTocando = false;
    }
    _notificarMudancasVisuais();
  }

  void excluirConjuntoSalvo(String nome) {
    // ... (código existente)
     _conjuntosSalvos.removeWhere((conjunto) => conjunto.nome == nome);
    _persistirConjuntosSalvos();
    notifyListeners();
  }

  void definirTempo(double novoTempo) {
    _tempoBPM = novoTempo.clamp(30.0, 240.0);
    if (estaTocandoGlobalmente) {
      pararReproducao();
      iniciarOuPausarReproducaoGlobal();
    } else {
      notifyListeners();
    }
  }

  void definirOffsetHorizontalScroll(double novoOffsetTicks) {
    // O maxOffset é conceitualmente infinito para o conteúdo, mas o slider precisa de um limite.
    // O clamp aqui pode ser para o limite prático do slider.
    _offsetHorizontalScroll = novoOffsetTicks; // Permitir valores negativos se o slider permitir
    notifyListeners();
  }

  @override
  void dispose() {
    _timerReproducao?.cancel();
    _playerB1.dispose();
    _playerB2.dispose();
    _playerB3.dispose();
    super.dispose();
  }
}