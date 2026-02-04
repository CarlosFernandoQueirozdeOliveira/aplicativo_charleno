import 'package:json_annotation/json_annotation.dart';

part 'disciplina_model.g.dart';

@JsonSerializable()
class DisciplinaModel {
  final String id;
  final String nome;
  final String? codigo;
  @JsonKey(name: 'criada_em')
  final DateTime criadaEm;

  DisciplinaModel({
    required this.id,
    required this.nome,
    this.codigo,
    required this.criadaEm,
  });

  factory DisciplinaModel.fromJson(Map<String, dynamic> json) =>
      _$DisciplinaModelFromJson(json);

  Map<String, dynamic> toJson() => _$DisciplinaModelToJson(this);
}
