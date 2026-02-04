// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turma_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurmaModel _$TurmaModelFromJson(Map<String, dynamic> json) => TurmaModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      criadaEm: DateTime.parse(json['criada_em'] as String),
    );

Map<String, dynamic> _$TurmaModelToJson(TurmaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'criada_em': instance.criadaEm.toIso8601String(),
    };
