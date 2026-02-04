// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarefa_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TarefaModel _$TarefaModelFromJson(Map<String, dynamic> json) => TarefaModel(
      id: json['id'] as String,
      alunoId: json['aluno_id'] as String,
      disciplinaId: json['disciplina_id'] as String,
      professorId: json['professor_id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      tipo: $enumDecode(_$TipoTarefaEnumMap, json['tipo']),
      status: $enumDecode(_$StatusTarefaEnumMap, json['status']),
      pontos: (json['pontos'] as num).toInt(),
      dataEntrega: DateTime.parse(json['data_entrega'] as String),
      iniciadaEm: json['iniciada_em'] == null
          ? null
          : DateTime.parse(json['iniciada_em'] as String),
      concluidaEm: json['concluida_em'] == null
          ? null
          : DateTime.parse(json['concluida_em'] as String),
      criadaEm: DateTime.parse(json['criada_em'] as String),
      atualizadaEm: DateTime.parse(json['atualizada_em'] as String),
    );

Map<String, dynamic> _$TarefaModelToJson(TarefaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'aluno_id': instance.alunoId,
      'disciplina_id': instance.disciplinaId,
      'professor_id': instance.professorId,
      'titulo': instance.titulo,
      'descricao': instance.descricao,
      'tipo': _$TipoTarefaEnumMap[instance.tipo]!,
      'status': _$StatusTarefaEnumMap[instance.status]!,
      'pontos': instance.pontos,
      'data_entrega': instance.dataEntrega.toIso8601String(),
      'iniciada_em': instance.iniciadaEm?.toIso8601String(),
      'concluida_em': instance.concluidaEm?.toIso8601String(),
      'criada_em': instance.criadaEm.toIso8601String(),
      'atualizada_em': instance.atualizadaEm.toIso8601String(),
    };

const _$TipoTarefaEnumMap = {
  TipoTarefa.atividade: 'ATIVIDADE',
  TipoTarefa.projeto: 'PROJETO',
};

const _$StatusTarefaEnumMap = {
  StatusTarefa.pendente: 'PENDENTE',
  StatusTarefa.emAndamento: 'EM_ANDAMENTO',
  StatusTarefa.concluida: 'CONCLUIDA',
};

Map<String, dynamic> _$TarefaCreateDtoToJson(TarefaCreateDto instance) =>
    <String, dynamic>{
      'tipo': _$TipoTarefaEnumMap[instance.tipo]!,
      'titulo': instance.titulo,
      'descricao': instance.descricao,
      'pontos': instance.pontos,
      'data_entrega': instance.dataEntrega.toIso8601String(),
      'aluno_id': instance.alunoId,
      'disciplina_id': instance.disciplinaId,
      'professor_id': instance.professorId,
    };

Map<String, dynamic> _$TarefaUpdateDtoToJson(TarefaUpdateDto instance) =>
    <String, dynamic>{
      if (_$TipoTarefaEnumMap[instance.tipo] case final value?) 'tipo': value,
      if (instance.titulo case final value?) 'titulo': value,
      if (instance.descricao case final value?) 'descricao': value,
      if (instance.pontos case final value?) 'pontos': value,
      if (instance.dataEntrega?.toIso8601String() case final value?)
        'data_entrega': value,
      if (_$StatusTarefaEnumMap[instance.status] case final value?)
        'status': value,
    };
