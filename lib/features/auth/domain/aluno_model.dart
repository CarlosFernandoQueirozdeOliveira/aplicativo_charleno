import 'package:json_annotation/json_annotation.dart';

part 'aluno_model.g.dart';

@JsonSerializable()
class AlunoModel {
  final String id;
  final String nome;
  final String email;
  @JsonKey(name: 'turma_id')
  final String turmaId;
  @JsonKey(name: 'criado_em')
  final DateTime criadoEm;
  @JsonKey(name: 'atualizado_em')
  final DateTime atualizadoEm;

  AlunoModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.turmaId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory AlunoModel.fromJson(Map<String, dynamic> json) =>
      _$AlunoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlunoModelToJson(this);
}
