import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/http/api_client.dart';
import '../../../core/config/api_config.dart';
import '../../auth/data/auth_service.dart';
import '../domain/turma_model.dart';

part 'turma_service.g.dart';

@riverpod
TurmaService turmaService(Ref ref) {
  return TurmaService(ref.watch(apiClientProvider));
}

class TurmaService {
  final ApiClient _client;

  TurmaService(this._client);

  Future<List<TurmaModel>> getTurmas({int skip = 0, int limit = 100}) async {
    if (!ApiConfig.isApiEnabled) {
      // Mock Data
      return [
        TurmaModel(
          id: '1',
          nome: 'ADS 2024.1',
          criadaEm: DateTime(2024, 2, 1),
        ),
        TurmaModel(
          id: '2',
          nome: 'ADS 2024.2',
          criadaEm: DateTime(2024, 8, 1),
        ),
      ];
    }

    final response = await _client.dio.get('/turmas/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });

    return (response.data as List)
        .map((e) => TurmaModel.fromJson(e))
        .toList();
  }

  Future<TurmaModel> getTurma(String id) async {
    if (!ApiConfig.isApiEnabled) {
      return TurmaModel(
        id: id,
        nome: 'ADS 2024.1',
        criadaEm: DateTime(2024, 2, 1),
      );
    }

    final response = await _client.dio.get('/turmas/$id');
    return TurmaModel.fromJson(response.data);
  }

  Future<TurmaModel> createTurma(String nome) async {
    final response = await _client.dio.post('/turmas/', data: {
      'nome': nome,
    });
    return TurmaModel.fromJson(response.data);
  }

  Future<TurmaModel> updateTurma(String id, String nome) async {
    final response = await _client.dio.put('/turmas/$id', data: {
      'nome': nome,
    });
    return TurmaModel.fromJson(response.data);
  }

  Future<void> deleteTurma(String id) async {
    await _client.dio.delete('/turmas/$id');
  }
}
