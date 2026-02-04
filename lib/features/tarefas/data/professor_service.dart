import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/http/api_client.dart';
import '../../../core/config/api_config.dart';
import '../../auth/data/auth_service.dart';
import '../domain/professor_model.dart';

part 'professor_service.g.dart';

@riverpod
ProfessorService professorService(Ref ref) {
  return ProfessorService(ref.watch(apiClientProvider));
}

class ProfessorService {
  final ApiClient _client;

  ProfessorService(this._client);

  Future<List<ProfessorModel>> getProfessores({int skip = 0, int limit = 100}) async {
    if (!ApiConfig.isApiEnabled) {
      // Mock Data
      return [
        ProfessorModel(
          id: '1',
          nome: 'Prof. Carlos Silva',
          email: 'carlos.silva@univ.edu',
          criadoEm: DateTime(2024, 1, 10),
        ),
        ProfessorModel(
          id: '2',
          nome: 'Profa. Maria Santos',
          email: 'maria.santos@univ.edu',
          criadoEm: DateTime(2024, 1, 10),
        ),
        ProfessorModel(
          id: '3',
          nome: 'Prof. João Oliveira',
          email: 'joao.oliveira@univ.edu',
          criadoEm: DateTime(2024, 1, 10),
        ),
      ];
    }

    final response = await _client.dio.get('/professores/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });

    return (response.data as List)
        .map((e) => ProfessorModel.fromJson(e))
        .toList();
  }

  Future<ProfessorModel> getProfessor(String id) async {
    if (!ApiConfig.isApiEnabled) {
      return ProfessorModel(
        id: id,
        nome: 'Prof. Carlos Silva',
        email: 'carlos.silva@univ.edu',
        criadoEm: DateTime(2024, 1, 10),
      );
    }

    final response = await _client.dio.get('/professores/$id');
    return ProfessorModel.fromJson(response.data);
  }

  Future<ProfessorModel> createProfessor({
    required String nome,
    String? email,
  }) async {
    final response = await _client.dio.post('/professores/', data: {
      'nome': nome,
      if (email != null) 'email': email,
    });
    return ProfessorModel.fromJson(response.data);
  }

  Future<ProfessorModel> updateProfessor(String id, {
    String? nome,
    String? email,
  }) async {
    final response = await _client.dio.put('/professores/$id', data: {
      if (nome != null) 'nome': nome,
      if (email != null) 'email': email,
    });
    return ProfessorModel.fromJson(response.data);
  }

  Future<void> deleteProfessor(String id) async {
    await _client.dio.delete('/professores/$id');
  }
}
