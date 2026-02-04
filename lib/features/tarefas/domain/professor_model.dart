import 'package:json_annotation/json_annotation.dart';

part 'professor_model.g.dart';

@JsonSerializable()
class ProfessorModel {
  final String id;
  final String nome;
  final String? email;
  @JsonKey(name: 'criado_em')
  final DateTime criadoEm;

  ProfessorModel({
    required this.id,
    required this.nome,
    this.email,
    required this.criadoEm,
  });

  factory ProfessorModel.fromJson(Map<String, dynamic> json) =>
      _$ProfessorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessorModelToJson(this);
}
