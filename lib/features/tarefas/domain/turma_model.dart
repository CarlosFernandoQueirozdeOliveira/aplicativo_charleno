import 'package:json_annotation/json_annotation.dart';

part 'turma_model.g.dart';

@JsonSerializable()
class TurmaModel {
  final String id;
  final String nome;
  @JsonKey(name: 'criada_em')
  final DateTime criadaEm;

  TurmaModel({
    required this.id,
    required this.nome,
    required this.criadaEm,
  });

  factory TurmaModel.fromJson(Map<String, dynamic> json) =>
      _$TurmaModelFromJson(json);

  Map<String, dynamic> toJson() => _$TurmaModelToJson(this);
}
