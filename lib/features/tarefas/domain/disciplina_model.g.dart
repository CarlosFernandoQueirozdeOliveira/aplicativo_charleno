// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disciplina_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisciplinaModel _$DisciplinaModelFromJson(Map<String, dynamic> json) =>
    DisciplinaModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      codigo: json['codigo'] as String?,
      criadaEm: DateTime.parse(json['criada_em'] as String),
    );

Map<String, dynamic> _$DisciplinaModelToJson(DisciplinaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'codigo': instance.codigo,
      'criada_em': instance.criadaEm.toIso8601String(),
    };
