// models/fracao_model.dart

import 'package:flutter/material.dart';
// import 'package:collection/collection.dart'; // Não mais necessário para ListEquality em padraoBatida
// import 'dart:math'; // Não mais necessário para gerarPadraoBatida

class FracaoModel {
  String id;
  int? numerador;
  int? denominador;
  Color cor;
  String assetSom;
  bool estaTocando; // Se esta faixa está ATIVA para tocar (não se está selecionada na UI)
  bool estaSelecionada; // Se está selecionada na UI para ser incluída na reprodução
  // int get subdivisoesPorUnidade => denominador ?? 1; // Não mais usado dessa forma


  FracaoModel({
    required this.id,
    this.numerador,
    this.denominador,
    required this.cor,
    required this.assetSom,
    this.estaTocando = false,
    this.estaSelecionada = false,
  });

  String get valorExibicao {
    if (numerador != null && denominador != null) {
      return "$numerador:$denominador";
    }
    return "";
  }

  // REMOVIDO: gerarPadraoBatida
  // REMOVIDO: pontoFinalDaPrimeiraOcorrenciaDoPadrao

  Map<String, dynamic> toJson() => {
    'id': id,
    'numerador': numerador,
    'denominador': denominador,
    'cor': cor.value,
    'assetSom': assetSom,
    // Não salvamos estaTocando ou estaSelecionada
  };

  factory FracaoModel.fromJson(Map<String, dynamic> json) => FracaoModel(
    id: json['id'],
    numerador: json['numerador'],
    denominador: json['denominador'],
    cor: Color(json['cor']),
    assetSom: json['assetSom'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FracaoModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          numerador == other.numerador &&
          denominador == other.denominador &&
          cor == other.cor &&
          estaTocando == other.estaTocando && // Comparar se necessário, mas geralmente não para identidade
          estaSelecionada == other.estaSelecionada;

  @override
  int get hashCode =>
      id.hashCode ^
      numerador.hashCode ^
      denominador.hashCode ^
      cor.hashCode ^
      estaTocando.hashCode ^
      estaSelecionada.hashCode;
}