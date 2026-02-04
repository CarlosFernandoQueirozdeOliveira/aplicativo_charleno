// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aluno_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlunoModel _$AlunoModelFromJson(Map<String, dynamic> json) => AlunoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      turmaId: json['turma_id'] as String,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      atualizadoEm: DateTime.parse(json['atualizado_em'] as String),
    );

Map<String, dynamic> _$AlunoModelToJson(AlunoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'email': instance.email,
      'turma_id': instance.turmaId,
      'criado_em': instance.criadoEm.toIso8601String(),
      'atualizado_em': instance.atualizadoEm.toIso8601String(),
    };
