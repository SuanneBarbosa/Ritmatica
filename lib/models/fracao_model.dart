import 'package:flutter/material.dart';

class FracaoModel {
  String id;
  int? numerador;
  int? denominador;
  Color cor;
  String assetSom;
  bool estaTocando; 
  bool estaSelecionada; 
 
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'numerador': numerador,
    'denominador': denominador,
    'cor': cor.value,
    'assetSom': assetSom,
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
          estaTocando == other.estaTocando && 
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