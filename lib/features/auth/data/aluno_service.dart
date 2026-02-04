import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/http/api_client.dart';
import '../../../core/config/api_config.dart';
import 'auth_service.dart';

part 'aluno_service.g.dart';

@riverpod
AlunoService alunoService(Ref ref) {
  return AlunoService(ref.watch(apiClientProvider));
}

class AlunoService {
  final ApiClient _client;

  AlunoService(this._client);

  /// Cria um novo aluno (registro)
  /// Retorna o ID do aluno criado em caso de sucesso
  Future<String> createAluno({
    required String nome,
    required String email,
    required String password,
    required String turmaId,
  }) async {
    if (!ApiConfig.isApiEnabled) {
      // Mock mode - simula criação
      await Future.delayed(const Duration(seconds: 1));
      return 'mock-aluno-id';
    }

    try {
      final response = await _client.dio.post('/alunos/', data: {
        'nome': nome,
        'email': email,
        'password': password,
        'turma_id': turmaId,
      });
      
      return response.data['id'].toString();
    } on DioException catch (e) {
      // Tratar erros específicos da API
      if (e.response?.statusCode == 400) {
        final detail = e.response?.data['detail'];
        if (detail != null) {
          throw Exception(detail);
        }
      }
      if (e.response?.statusCode == 422) {
        throw Exception('Dados inválidos. Verifique os campos e tente novamente.');
      }
      throw Exception('Erro ao cadastrar. Tente novamente mais tarde.');
    }
  }
}
