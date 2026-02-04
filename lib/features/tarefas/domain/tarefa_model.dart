import 'package:json_annotation/json_annotation.dart';

part 'tarefa_model.g.dart';

enum TipoTarefa {
  @JsonValue('ATIVIDADE') atividade,
  @JsonValue('PROJETO') projeto,
}

enum StatusTarefa {
  @JsonValue('PENDENTE') pendente,
  @JsonValue('EM_ANDAMENTO') emAndamento,
  @JsonValue('CONCLUIDA') concluida,
}

@JsonSerializable()
class TarefaModel {
  final String id;
  @JsonKey(name: 'aluno_id')
  final String alunoId;
  @JsonKey(name: 'disciplina_id')
  final String disciplinaId;
  @JsonKey(name: 'professor_id')
  final String professorId;
  final String titulo;
  final String? descricao;
  final TipoTarefa tipo;
  final StatusTarefa status;
  final int pontos;
  @JsonKey(name: 'data_entrega')
  final DateTime dataEntrega;
  @JsonKey(name: 'iniciada_em')
  final DateTime? iniciadaEm;
  @JsonKey(name: 'concluida_em')
  final DateTime? concluidaEm;
  @JsonKey(name: 'criada_em')
  final DateTime criadaEm;
  @JsonKey(name: 'atualizada_em')
  final DateTime atualizadaEm;

  TarefaModel({
    required this.id,
    required this.alunoId,
    required this.disciplinaId,
    required this.professorId,
    required this.titulo,
    this.descricao,
    required this.tipo,
    required this.status,
    required this.pontos,
    required this.dataEntrega,
    this.iniciadaEm,
    this.concluidaEm,
    required this.criadaEm,
    required this.atualizadaEm,
  });

  factory TarefaModel.fromJson(Map<String, dynamic> json) =>
      _$TarefaModelFromJson(json);

  Map<String, dynamic> toJson() => _$TarefaModelToJson(this);
}

/// DTO para criar uma nova tarefa
@JsonSerializable(createFactory: false)
class TarefaCreateDto {
  final TipoTarefa tipo;
  final String titulo;
  final String? descricao;
  final int pontos;
  @JsonKey(name: 'data_entrega')
  final DateTime dataEntrega;
  @JsonKey(name: 'aluno_id')
  final String alunoId;
  @JsonKey(name: 'disciplina_id')
  final String disciplinaId;
  @JsonKey(name: 'professor_id')
  final String professorId;

  TarefaCreateDto({
    required this.tipo,
    required this.titulo,
    this.descricao,
    required this.pontos,
    required this.dataEntrega,
    required this.alunoId,
    required this.disciplinaId,
    required this.professorId,
  });

  Map<String, dynamic> toJson() => _$TarefaCreateDtoToJson(this);
}

/// DTO para atualizar uma tarefa
@JsonSerializable(createFactory: false, includeIfNull: false)
class TarefaUpdateDto {
  final TipoTarefa? tipo;
  final String? titulo;
  final String? descricao;
  final int? pontos;
  @JsonKey(name: 'data_entrega')
  final DateTime? dataEntrega;
  final StatusTarefa? status;

  TarefaUpdateDto({
    this.tipo,
    this.titulo,
    this.descricao,
    this.pontos,
    this.dataEntrega,
    this.status,
  });

  Map<String, dynamic> toJson() => _$TarefaUpdateDtoToJson(this);
}
