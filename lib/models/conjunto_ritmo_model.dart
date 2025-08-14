import './fracao_model.dart';

class ConjuntoRitmoModel {
  String nome; 
  List<FracaoModel> fracoes; 

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