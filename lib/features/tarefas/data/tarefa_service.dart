import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/http/api_client.dart';
import '../../../core/config/api_config.dart';
import '../../auth/data/auth_service.dart';
import '../domain/tarefa_model.dart';

part 'tarefa_service.g.dart';

@riverpod
TarefaService tarefaService(Ref ref) {
  return TarefaService(ref.watch(apiClientProvider));
}

class TarefaService {
  final ApiClient _client;

  TarefaService(this._client);

  Future<List<TarefaModel>> getTarefas({String? alunoId, int skip = 0, int limit = 100}) async {
    if (!ApiConfig.isApiEnabled) {
      // Mock Data
      final now = DateTime.now();
      return [
        TarefaModel(
          id: '1',
          alunoId: 'aluno-1',
          disciplinaId: 'disc-1',
          professorId: 'prof-1',
          titulo: 'Cálculo I - Lista 2',
          descricao: 'Exercícios de 1 a 10 sobre Derivadas e limites laterais.',
          tipo: TipoTarefa.atividade,
          status: StatusTarefa.pendente,
          pontos: 15,
          dataEntrega: DateTime(2023, 10, 20),
          iniciadaEm: null,
          concluidaEm: null,
          criadaEm: now.subtract(const Duration(days: 10)),
          atualizadaEm: now.subtract(const Duration(days: 10)),
        ),
        TarefaModel(
          id: '2',
          alunoId: 'aluno-1',
          disciplinaId: 'disc-2',
          professorId: 'prof-2',
          titulo: 'Física Geral - Lab',
          descricao: 'Relatório final de mecânica clássica e análise de vetores.',
          tipo: TipoTarefa.atividade,
          status: StatusTarefa.emAndamento,
          pontos: 20,
          dataEntrega: now.add(const Duration(days: 2)),
          iniciadaEm: now.subtract(const Duration(days: 3)),
          concluidaEm: null,
          criadaEm: now.subtract(const Duration(days: 7)),
          atualizadaEm: now.subtract(const Duration(days: 3)),
        ),
        TarefaModel(
          id: '3',
          alunoId: 'aluno-1',
          disciplinaId: 'disc-4',
          professorId: 'prof-3',
          titulo: 'História da Arte',
          descricao: 'Resenha sobre o Renascimento e suas influências.',
          tipo: TipoTarefa.atividade,
          status: StatusTarefa.concluida,
          pontos: 10,
          dataEntrega: DateTime(2023, 10, 15),
          iniciadaEm: DateTime(2023, 10, 10),
          concluidaEm: DateTime(2023, 10, 15),
          criadaEm: now.subtract(const Duration(days: 20)),
          atualizadaEm: DateTime(2023, 10, 15),
        ),
        TarefaModel(
          id: '4',
          alunoId: 'aluno-1',
          disciplinaId: 'disc-3',
          professorId: 'prof-1',
          titulo: 'Programação Estruturada',
          descricao: 'Implementação de algoritmos de ordenação em C.',
          tipo: TipoTarefa.projeto,
          status: StatusTarefa.pendente,
          pontos: 40,
          dataEntrega: DateTime(2023, 10, 25),
          iniciadaEm: null,
          concluidaEm: null,
          criadaEm: now.subtract(const Duration(days: 5)),
          atualizadaEm: now.subtract(const Duration(days: 5)),
        ),
      ];
    }

    final queryParams = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };
    if (alunoId != null) {
      queryParams['aluno_id'] = alunoId;
    }

    final response = await _client.dio.get('/tarefas/', queryParameters: queryParams);

    return (response.data as List)
        .map((e) => TarefaModel.fromJson(e))
        .toList();
  }

  Future<TarefaModel> getTarefa(String id) async {
    final response = await _client.dio.get('/tarefas/$id');
    return TarefaModel.fromJson(response.data);
  }

  Future<TarefaModel> createTarefa(TarefaCreateDto dto) async {
    final response = await _client.dio.post('/tarefas/', data: dto.toJson());
    return TarefaModel.fromJson(response.data);
  }

  Future<TarefaModel> updateTarefa(String id, TarefaUpdateDto dto) async {
    final response = await _client.dio.put('/tarefas/$id', data: dto.toJson());
    return TarefaModel.fromJson(response.data);
  }

  Future<void> deleteTarefa(String id) async {
    await _client.dio.delete('/tarefas/$id');
  }
}
