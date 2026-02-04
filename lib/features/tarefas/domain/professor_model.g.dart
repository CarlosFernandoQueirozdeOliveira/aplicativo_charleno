// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfessorModel _$ProfessorModelFromJson(Map<String, dynamic> json) =>
    ProfessorModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String?,
      criadoEm: DateTime.parse(json['criado_em'] as String),
    );

Map<String, dynamic> _$ProfessorModelToJson(ProfessorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'email': instance.email,
      'criado_em': instance.criadoEm.toIso8601String(),
    };
