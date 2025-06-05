import './fracao_model.dart';

class ConjuntoRitmoModel {
  String nome; // Nome definido pelo usuário para o conjunto
  List<FracaoModel> fracoes; // Lista de 3 instâncias de FracaoModel

  ConjuntoRitmoModel({required this.nome, required this.fracoes});

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'fracoes': fracoes.map((f) => f.toJson()).toList(),
  };

  factory ConjuntoRitmoModel.fromJson(Map<String, dynamic> json) => ConjuntoRitmoModel(
    nome: json['nome'],
    fracoes: (json['fracoes'] as List)
        .map((item) => FracaoModel.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}