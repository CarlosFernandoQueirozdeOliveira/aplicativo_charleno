
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/tarefa_service.dart';
import '../domain/tarefa_model.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_page.dart';  
import 'tarefa_detalhes_page.dart';
import 'nova_tarefa_page.dart';

part 'tarefas_page.g.dart';

// Provider to fetch tasks
@riverpod
Future<List<TarefaModel>> tarefas(Ref ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  final alunoId = await secureStorage.getUserId();
  
  if (alunoId == null) {
      print("DEBUG: Aluno ID is null. User needs to login.");
      throw Exception('Sessão inválida ou expirada. Faça login novamente.');
  }

  print("DEBUG: Fetching tasks for Aluno ID: $alunoId");
  return ref.watch(tarefaServiceProvider).getTarefas(alunoId: alunoId);
}

class TarefasPage extends ConsumerStatefulWidget {
  const TarefasPage({super.key});

  @override
  ConsumerState<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends ConsumerState<TarefasPage> {
  String _selectedFilter = 'Todas';
  String? _expandedTaskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
         _buildHeader(context, ref),
         
         // Horizontal Filter
         _buildFilters(context),
         
         // List
         Expanded(
           child: _buildTaskList(ref),
         ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tarefas_fab',
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NovaTarefaPage()),
          );
          if (created == true) {
            ref.invalidate(tarefasProvider);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Minhas Tarefas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildFilterChip(context, 'Todas'),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'Atrasadas'),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'Em Andamento'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final isSelected = _selectedFilter == label;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTaskList(WidgetRef ref) {
     final tarefasAsync = ref.watch(tarefasProvider);
     
     return tarefasAsync.when(
        data: (tarefas) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final filteredTarefas = tarefas.where((t) {
            final dueDate = DateTime(t.dataEntrega.year, t.dataEntrega.month, t.dataEntrega.day);
            final isNotCompleted = t.status != StatusTarefa.concluida;
            final isOverdue = dueDate.isBefore(today); // Passou do prazo
            final isWithinDeadline = !isOverdue; // Ainda no prazo
            
            if (_selectedFilter == 'Todas') return true;
            if (_selectedFilter == 'Atrasadas') {
              // Mostra tarefas ATRASADAS (passou do prazo e não entregues)
              return isNotCompleted && isOverdue;
            }
            if (_selectedFilter == 'Em Andamento') {
              // Mostra tarefas no prazo que ainda podem ser entregues
              return isNotCompleted && isWithinDeadline;
            }
            return true;
          }).toList();

          if (filteredTarefas.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada para este filtro.'));
          }

          // Expand the first item if none is expanded
          if (_expandedTaskId == null && filteredTarefas.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _expandedTaskId = filteredTarefas.first.id);
            });
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTarefas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final tarefa = filteredTarefas[index];
              final isExpanded = _expandedTaskId == tarefa.id;
              
              return _TarefaCard(
                tarefa: tarefa, 
                isExpanded: isExpanded,
                onTap: () => setState(() => _expandedTaskId = tarefa.id),
                onReturnFromDetails: () => ref.invalidate(tarefasProvider),
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('Erro: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
     );
  }
}

class _TarefaCard extends StatelessWidget {
  final TarefaModel tarefa;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onReturnFromDetails;

  const _TarefaCard({
    required this.tarefa, 
    required this.isExpanded,
    required this.onTap,
    this.onReturnFromDetails,
  });

  Color _getStatusColor(StatusTarefa status) {
    switch (status) {
      case StatusTarefa.pendente: return Colors.orange.shade700;
      case StatusTarefa.emAndamento: return Colors.blue.shade700;
      case StatusTarefa.concluida: return Colors.green.shade700;
    }
  }
  
  Color _getStatusBg(StatusTarefa status) {
    switch (status) {
      case StatusTarefa.pendente: return Colors.orange.shade50;
      case StatusTarefa.emAndamento: return Colors.blue.shade50;
      case StatusTarefa.concluida: return Colors.green.shade50;
    }
  }

  String _getStatusLabel(StatusTarefa status) {
    switch (status) {
      case StatusTarefa.pendente: return 'Pendente';
      case StatusTarefa.emAndamento: return 'Em Andamento';
      case StatusTarefa.concluida: return 'Concluída';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'pt_BR');
    
    // Exact images from the HTML/Image provided
    String imageUrl = '';
    if (tarefa.titulo.contains('Cálculo')) {
      imageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuAKTO5nZZSNWLMynEy4x0-RyKhw-GZwyicT2C_nBsPxwkF0kWrYH19RhhNXjSTPsFf1GDP6rKUDe5fjFCpmHf7dMl9VwmpSuBpqF2UM0oMTntVayRgk7z9ZwZyOLWHhFB70MpZXrSv3BrrAyFggDB07O_1b1S_znmTTre3AUR2kN4yZUvMYzTAiGqgMaQ4LCbjOe9yks49XaT-C_G2u7Bt6KQbCGA4vTM7JxO4dvW6iftKWPu2chQO4ZqovRgJfeC9PV1JHYzyAtzQ';
    } else if (tarefa.titulo.contains('Física')) {
       imageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBJ4vp0RRvDIaPpudAJbRIiU4upUDGWYaWpa5Xbd2nbIf7XD7vMvIHExB7EHUug79jPtZH3jg4PmzCS0sXuRxXk4osf2XipnoNKlzReLaOBDH2rQWyyDKiJQ7yjnrTSWg_84tInNAxBGoTkwZM-zlsMlwY3yLHe91_5rRAfCnSEvmrB_wzY152U_heU33ai0_eNLAJ4moXp_-IZhT0qdDPq5FITU9WQgkhYT6eiR0IBKHmALJ4ZZe2pFT8gZBQRNp0KgQx1ggwVBZs';
    } else if (tarefa.titulo.contains('Arte')) {
       imageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBL3NgfnLinObywX8Z1BwduOtYgjCIJ1TElTPARqKZkNd0BAwjYtF23kVKBrQBs95PX6VlI_UNNS_CDjphLwBen9OiwI5LBEDYuZ6kJ3QrDGVdr9fitqVqs4UHLJqFlA3rCVn1aoFRcFFmPNC4fsXfaKrZfE-cmnqXX5ldCrWLtjQ5XJ0lNxh87QO15tlp7FW8SMN3JA3pgcVoxZ0yYQ621R-EH-OvHNnQaDzRBjCV0AiMIyEWVNyXrlGoKBCXo95346A9Ghp8RZVk';
    } else {
       imageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuADxaOTh1sNlJ0wrZgQ8TKEvn6ILQGS1a6X0On8iVBJU99_osLXxdbIR44hiVIwPbWPyg1KjloCe3Qp2LadunT1VuVtZVTyu5vdA_Nr_JdtVzVk7Sx0PmMDf3LIAj93PBnUzt2K1Hlh-4sczKRlyvZJyKjSeK-FjgpkfaIFGfcCB_ZW-7FdZm4rsW60aX5Lz7uh3YsojN89rJBTSw3Ek7UDHLEGnbroNV2jOoK_FUvZrOe7KH1Fr8G0uXCKNO2B0I5hTjAAnlueMOQ';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: isExpanded ? _buildExpandedLayout(context, imageUrl, dateFormat) : _buildCollapsedLayout(context, imageUrl),
      ),
    );
  }

  Widget _buildExpandedLayout(BuildContext context, String imageUrl, DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Large Image
        SizedBox(
          height: 140,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey.shade100),
            errorWidget: (context, url, error) => Container(color: Colors.grey.shade100, child: const Icon(Icons.error)),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBg(tarefa.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(tarefa.status),
                      style: TextStyle(
                        color: _getStatusColor(tarefa.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(tarefa.dataEntrega),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tarefa.titulo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111218)),
              ),
              const SizedBox(height: 4),
              Text(
                tarefa.descricao ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () async {
                    final delivered = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => TarefaDetalhesPage(tarefa: tarefa)),
                    );
                    if (delivered == true) {
                      onReturnFromDetails?.call();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Ver Detalhes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedLayout(BuildContext context, String imageUrl) {
    String bottomInfo = '';
    IconData? bottomIcon;
    Color? iconColor;
    String actionText = 'Abrir';
    IconData actionIcon = Icons.chevron_right;

    if (tarefa.status == StatusTarefa.concluida) {
      bottomInfo = 'Entregue em 15 Out';
      bottomIcon = Icons.check_circle;
      iconColor = Theme.of(context).colorScheme.primary;
      actionText = 'Revisar';
      actionIcon = Icons.visibility;
    } else if (tarefa.status == StatusTarefa.emAndamento) {
      bottomInfo = 'Expira em 2 dias';
      bottomIcon = Icons.schedule;
    } else {
       bottomInfo = 'Entrega: ${DateFormat('dd Out').format(tarefa.dataEntrega)}';
       bottomIcon = Icons.event;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusBg(tarefa.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(tarefa.status),
                        style: TextStyle(
                          color: _getStatusColor(tarefa.status),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tarefa.titulo,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111218)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tarefa.descricao ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(image: CachedNetworkImageProvider(imageUrl), fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(bottomIcon, size: 16, color: iconColor ?? Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    bottomInfo,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    actionText,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: actionText == 'Revisar' ? Colors.grey : Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(actionIcon, size: 16, color: actionText == 'Revisar' ? Colors.grey : Theme.of(context).colorScheme.primary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
