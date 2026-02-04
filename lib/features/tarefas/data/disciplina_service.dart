import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/http/api_client.dart';
import '../../../core/config/api_config.dart';
import '../../auth/data/auth_service.dart';
import '../domain/disciplina_model.dart';

part 'disciplina_service.g.dart';

@riverpod
DisciplinaService disciplinaService(Ref ref) {
  return DisciplinaService(ref.watch(apiClientProvider));
}

class DisciplinaService {
  final ApiClient _client;

  DisciplinaService(this._client);

  Future<List<DisciplinaModel>> getDisciplinas({int skip = 0, int limit = 100}) async {
    if (!ApiConfig.isApiEnabled) {
      // Mock Data
      return [
        DisciplinaModel(
          id: '1',
          nome: 'Cálculo I',
          codigo: 'MAT101',
          criadaEm: DateTime(2024, 1, 15),
        ),
        DisciplinaModel(
          id: '2',
          nome: 'Física Geral',
          codigo: 'FIS101',
          criadaEm: DateTime(2024, 1, 15),
        ),
        DisciplinaModel(
          id: '3',
          nome: 'Programação Estruturada',
          codigo: 'COMP101',
          criadaEm: DateTime(2024, 1, 15),
        ),
        DisciplinaModel(
          id: '4',
          nome: 'História da Arte',
          codigo: 'ART101',
          criadaEm: DateTime(2024, 1, 15),
        ),
      ];
    }

    final response = await _client.dio.get('/disciplinas/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });

    return (response.data as List)
        .map((e) => DisciplinaModel.fromJson(e))
        .toList();
  }

  Future<DisciplinaModel> getDisciplina(String id) async {
    if (!ApiConfig.isApiEnabled) {
      return DisciplinaModel(
        id: id,
        nome: 'Cálculo I',
        codigo: 'MAT101',
        criadaEm: DateTime(2024, 1, 15),
      );
    }

    final response = await _client.dio.get('/disciplinas/$id');
    return DisciplinaModel.fromJson(response.data);
  }

  Future<DisciplinaModel> createDisciplina({
    required String nome,
    String? codigo,
  }) async {
    final response = await _client.dio.post('/disciplinas/', data: {
      'nome': nome,
      if (codigo != null) 'codigo': codigo,
    });
    return DisciplinaModel.fromJson(response.data);
  }

  Future<DisciplinaModel> updateDisciplina(String id, {
    String? nome,
    String? codigo,
  }) async {
    final response = await _client.dio.put('/disciplinas/$id', data: {
      if (nome != null) 'nome': nome,
      if (codigo != null) 'codigo': codigo,
    });
    return DisciplinaModel.fromJson(response.data);
  }

  Future<void> deleteDisciplina(String id) async {
    await _client.dio.delete('/disciplinas/$id');
  }
}
