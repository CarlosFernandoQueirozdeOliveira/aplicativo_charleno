import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/tarefa_service.dart';
import '../data/disciplina_service.dart';
import '../data/professor_service.dart';
import '../domain/tarefa_model.dart';
import '../domain/disciplina_model.dart';
import '../domain/professor_model.dart';
import '../../auth/data/auth_service.dart';

class NovaTarefaPage extends ConsumerStatefulWidget {
  const NovaTarefaPage({super.key});

  @override
  ConsumerState<NovaTarefaPage> createState() => _NovaTarefaPageState();
}

class _NovaTarefaPageState extends ConsumerState<NovaTarefaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _pontosController = TextEditingController(text: '10');
  
  TipoTarefa _tipo = TipoTarefa.atividade;
  String? _selectedDisciplinaId;
  String? _selectedProfessorId;
  DateTime _dataEntrega = DateTime.now().add(const Duration(days: 7));
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _pontosController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataEntrega,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dataEntrega = picked);
    }
  }

  Future<void> _createTarefa() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDisciplinaId == null) {
      setState(() => _errorMessage = 'Selecione uma disciplina');
      return;
    }
    if (_selectedProfessorId == null) {
      setState(() => _errorMessage = 'Selecione um professor');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obter alunoId do storage
      final secureStorage = ref.read(secureStorageProvider);
      final alunoId = await secureStorage.getUserId();
      
      if (alunoId == null) {
        throw Exception('Sessão inválida. Faça login novamente.');
      }

      final dto = TarefaCreateDto(
        tipo: _tipo,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty 
            ? null 
            : _descricaoController.text.trim(),
        pontos: int.tryParse(_pontosController.text) ?? 10,
        dataEntrega: _dataEntrega,
        alunoId: alunoId,
        disciplinaId: _selectedDisciplinaId!,
        professorId: _selectedProfessorId!,
      );

      await ref.read(tarefaServiceProvider).createTarefa(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retorna true para indicar sucesso
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Nova Tarefa'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text('Título *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Lista de exercícios - Cap. 3',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Título é obrigatório';
                    }
                    if (value.trim().length < 2) {
                      return 'Título deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descrição
                const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    hintText: 'Detalhes da tarefa (opcional)',
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Tipo
                const Text('Tipo *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                DropdownButtonFormField<TipoTarefa>(
                  value: _tipo,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: TipoTarefa.atividade, child: Text('Atividade')),
                    DropdownMenuItem(value: TipoTarefa.projeto, child: Text('Projeto')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _tipo = value);
                  },
                ),
                const SizedBox(height: 16),

                // Disciplina
                const Text('Disciplina *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                FutureBuilder<List<DisciplinaModel>>(
                  future: ref.watch(disciplinaServiceProvider).getDisciplinas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 12));
                    }
                    final disciplinas = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _selectedDisciplinaId,
                      decoration: const InputDecoration(hintText: 'Selecione'),
                      items: disciplinas.map((d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.nome),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedDisciplinaId = value),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Professor
                const Text('Professor *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                FutureBuilder<List<ProfessorModel>>(
                  future: ref.watch(professorServiceProvider).getProfessores(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 12));
                    }
                    final professores = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _selectedProfessorId,
                      decoration: const InputDecoration(hintText: 'Selecione'),
                      items: professores.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.nome),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedProfessorId = value),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Pontos e Data em Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pontos *', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pontosController,
                            decoration: const InputDecoration(hintText: '10'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final pontos = int.tryParse(value ?? '');
                              if (pontos == null || pontos < 0) {
                                return 'Inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data de Entrega *', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy').format(_dataEntrega)),
                                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),

                // Submit Button
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _createTarefa,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Criar Tarefa'),
                        SizedBox(width: 8),
                        Icon(Icons.add_task, size: 20),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
