
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../tarefas/data/tarefa_service.dart';
import '../../tarefas/domain/tarefa_model.dart';
import '../../tarefas/presentation/tarefas_page.dart';
import '../../tarefas/presentation/tarefa_detalhes_page.dart';

class NoticesPage extends ConsumerStatefulWidget {
  const NoticesPage({super.key});

  @override
  ConsumerState<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends ConsumerState<NoticesPage> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final tarefasAsync = ref.watch(tarefasProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Avisos', 
          style: TextStyle(color: Color(0xFF111218), fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(tarefasProvider),
            icon: const Icon(Icons.refresh, color: Colors.grey),
          )
        ],
      ),
      body: Column(
        children: [
           // Filters
           SizedBox(
             height: 60,
             child: ListView(
               scrollDirection: Axis.horizontal,
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               children: [
                 _buildFilterChip(context, 'Todos'),
                 const SizedBox(width: 8),
                 _buildFilterChip(context, 'Urgentes'),
                 const SizedBox(width: 8),
                 _buildFilterChip(context, 'Próximos'),
                 const SizedBox(width: 8),
                 _buildFilterChip(context, 'Atrasados'),
               ],
             ),
           ),
           
           Expanded(
             child: tarefasAsync.when(
               data: (tarefas) => _buildNoticesList(context, tarefas),
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (e, _) => Center(child: Text('Erro: $e')),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildNoticesList(BuildContext context, List<TarefaModel> tarefas) {
    final now = DateTime.now();
    
    // Generate notices from tasks
    List<_NoticeData> notices = [];
    
    for (var tarefa in tarefas) {
      // Skip completed tasks
      if (tarefa.status == StatusTarefa.concluida) continue;
      
      final daysRemaining = tarefa.dataEntrega.difference(now).inDays;
      final hoursRemaining = tarefa.dataEntrega.difference(now).inHours;
      
      NoticeType type;
      String timeText;
      String description;
      
      if (daysRemaining < 0) {
        // Overdue
        type = NoticeType.overdue;
        timeText = 'Atrasado há ${-daysRemaining} dia${-daysRemaining > 1 ? 's' : ''}';
        description = 'Esta tarefa está atrasada! Entregue o mais rápido possível para evitar perder pontos.';
      } else if (daysRemaining == 0) {
        // Due today
        type = NoticeType.urgent;
        timeText = hoursRemaining > 0 ? 'Faltam $hoursRemaining horas!' : 'Vence agora!';
        description = 'Entrega prevista para hoje! Não se esqueça de entregar antes do prazo.';
      } else if (daysRemaining <= 2) {
        // Due soon
        type = NoticeType.urgent;
        timeText = 'Faltam $daysRemaining dia${daysRemaining > 1 ? 's' : ''}';
        description = 'Prazo se aproximando! Finalize sua tarefa para garantir a entrega no prazo.';
      } else if (daysRemaining <= 7) {
        // Coming up
        type = NoticeType.upcoming;
        timeText = 'Em $daysRemaining dias';
        description = 'Você ainda tem tempo, mas é bom começar a se organizar para esta entrega.';
      } else {
        // Far away - skip these
        continue;
      }
      
      notices.add(_NoticeData(
        tarefa: tarefa,
        type: type,
        timeText: timeText,
        description: description,
        daysRemaining: daysRemaining,
      ));
    }
    
    // Sort by urgency (most urgent first)
    notices.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    
    // Apply filter
    final filtered = notices.where((n) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Urgentes') return n.type == NoticeType.urgent || n.type == NoticeType.overdue;
      if (_selectedFilter == 'Próximos') return n.type == NoticeType.upcoming;
      if (_selectedFilter == 'Atrasados') return n.type == NoticeType.overdue;
      return true;
    }).toList();
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'Todos' 
                ? 'Nenhum aviso pendente!\nTodas as tarefas estão em dia 🎉'
                : 'Nenhum aviso para este filtro',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == filtered.length) return const SizedBox(height: 80);
        return _buildNoticeCard(context, filtered[index]);
      },
    );
  }

  Widget _buildNoticeCard(BuildContext context, _NoticeData notice) {
    final colorScheme = Theme.of(context).colorScheme;
    final tarefa = notice.tarefa;
    final dateFormat = DateFormat("d 'de' MMMM, HH:mm", 'pt_BR');
    
    Color cardColor;
    Color accentColor;
    IconData icon;
    
    switch (notice.type) {
      case NoticeType.overdue:
        cardColor = Colors.red.shade50;
        accentColor = Colors.red;
        icon = Icons.warning_amber_rounded;
        break;
      case NoticeType.urgent:
        cardColor = Colors.orange.shade50;
        accentColor = Colors.orange;
        icon = Icons.schedule;
        break;
      case NoticeType.upcoming:
        cardColor = Colors.blue.shade50;
        accentColor = Colors.blue;
        icon = Icons.event;
        break;
    }
    
    return GestureDetector(
      onTap: () async {
        final delivered = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => TarefaDetalhesPage(tarefa: tarefa)),
        );
        if (delivered == true) {
          ref.invalidate(tarefasProvider);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
               color: Colors.black.withValues(alpha: 0.04),
               blurRadius: 8,
               offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Container(
                   width: 44,
                   height: 44,
                   decoration: BoxDecoration(
                     color: cardColor,
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Icon(icon, color: accentColor, size: 24),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                             decoration: BoxDecoration(
                               color: accentColor.withValues(alpha: 0.1),
                               borderRadius: BorderRadius.circular(10),
                             ),
                             child: Text(
                               notice.timeText.toUpperCase(),
                               style: TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                                 color: accentColor,
                               ),
                             ),
                           ),
                           Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                         ],
                       ),
                       const SizedBox(height: 4),
                       Text(
                         tarefa.titulo,
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111218)),
                       ),
                     ],
                   ),
                 )
               ],
             ),
             
             const SizedBox(height: 12),
             Text(
               notice.description,
               style: const TextStyle(fontSize: 13, color: Color(0xFF5D6389), height: 1.4),
             ),
             
             const SizedBox(height: 12),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Row(
                   children: [
                     Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                     const SizedBox(width: 6),
                     Text(
                       dateFormat.format(tarefa.dataEntrega),
                       style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                     ),
                   ],
                 ),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(
                     color: colorScheme.primary.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Text(
                     tarefa.tipo == TipoTarefa.atividade ? 'ATIVIDADE' : 'PROJETO',
                     style: TextStyle(
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       color: colorScheme.primary,
                     ),
                   ),
                 ),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final isActive = _selectedFilter == label;
    final colorScheme = Theme.of(context).colorScheme;
    
    Color chipColor;
    if (label == 'Atrasados') {
      chipColor = Colors.red;
    } else if (label == 'Urgentes') {
      chipColor = Colors.orange;
    } else {
      chipColor = colorScheme.primary;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

enum NoticeType { urgent, overdue, upcoming }

class _NoticeData {
  final TarefaModel tarefa;
  final NoticeType type;
  final String timeText;
  final String description;
  final int daysRemaining;

  _NoticeData({
    required this.tarefa,
    required this.type,
    required this.timeText,
    required this.description,
    required this.daysRemaining,
  });
}
