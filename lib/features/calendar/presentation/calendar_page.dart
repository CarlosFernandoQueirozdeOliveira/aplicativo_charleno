
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../tarefas/data/tarefa_service.dart';
import '../../tarefas/domain/tarefa_model.dart';
import '../../tarefas/presentation/tarefas_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _selectedDate;

  final List<String> _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _nextMonth() {
    setState(() {
      int nextMonth = _selectedDate.month + 1;
      int nextYear = _selectedDate.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      _selectedDate = DateTime(nextYear, nextMonth, _selectedDate.day > 28 ? 28 : _selectedDate.day);
    });
  }

  void _prevMonth() {
    setState(() {
      int prevMonth = _selectedDate.month - 1;
      int prevYear = _selectedDate.year;
      if (prevMonth < 1) {
        prevMonth = 12;
        prevYear--;
      }
      _selectedDate = DateTime(prevYear, prevMonth, _selectedDate.day > 28 ? 28 : _selectedDate.day);
    });
  }

  // Get tasks for a specific day
  List<TarefaModel> _getTasksForDay(List<TarefaModel> tarefas, DateTime day) {
    return tarefas.where((t) => 
      t.dataEntrega.year == day.year &&
      t.dataEntrega.month == day.month &&
      t.dataEntrega.day == day.day
    ).toList();
  }

  // Check if a day has tasks
  bool _dayHasTasks(List<TarefaModel> tarefas, int day) {
    final date = DateTime(_selectedDate.year, _selectedDate.month, day);
    return tarefas.any((t) => 
      t.dataEntrega.year == date.year &&
      t.dataEntrega.month == date.month &&
      t.dataEntrega.day == date.day
    );
  }

  // Get the dot color for a day based on task status
  // 🟢 Green = All tasks delivered
  // 🔵 Blue = Pending but not overdue
  // 🔴 Red = Overdue (past due and not delivered)
  Color? _getDayDotColor(List<TarefaModel> tarefas, int day) {
    final date = DateTime(_selectedDate.year, _selectedDate.month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    
    final dayTasks = tarefas.where((t) => 
      t.dataEntrega.year == date.year &&
      t.dataEntrega.month == date.month &&
      t.dataEntrega.day == date.day
    ).toList();
    
    if (dayTasks.isEmpty) return null;
    
    // Check if ALL tasks are delivered
    final allDelivered = dayTasks.every((t) => t.status == StatusTarefa.concluida);
    if (allDelivered) return Colors.green;
    
    // Check if any pending task is overdue
    final hasOverdue = dayTasks.any((t) => 
      t.status != StatusTarefa.concluida && checkDate.isBefore(today)
    );
    if (hasOverdue) return Colors.red;
    
    // Check if it's today with pending tasks
    final isToday = checkDate.isAtSameMomentAs(today);
    final hasPendingToday = dayTasks.any((t) => t.status != StatusTarefa.concluida);
    if (isToday && hasPendingToday) return Colors.orange;
    
    // Future pending tasks
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final tarefasAsync = ref.watch(tarefasProvider);

    // Calendar calculation logic
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 for Sunday, 1 for Monday

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Calendário Acadêmico', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.white), 
            onPressed: () {
              setState(() => _selectedDate = DateTime.now());
            },
          ),
        ],
        elevation: 4,
      ),
      body: tarefasAsync.when(
        data: (tarefas) => _buildContent(context, tarefas, startWeekday, daysInMonth, primaryColor),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TarefaModel> tarefas, int startWeekday, int daysInMonth, Color primaryColor) {
    final selectedDayTasks = _getTasksForDay(tarefas, _selectedDate);
    final dateFormat = DateFormat('HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month Widget
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_months[_selectedDate.month - 1]} ${_selectedDate.year}', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: Colors.grey.shade400),
                          onPressed: _prevMonth,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                          onPressed: _nextMonth,
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DayLabel('Dom'), _DayLabel('Seg'), _DayLabel('Ter'), _DayLabel('Qua'), 
                    _DayLabel('Qui'), _DayLabel('Sex'), _DayLabel('Sáb'),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Dynamic Grid
                ..._buildCalendarGrid(context, startWeekday, daysInMonth, tarefas),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dia ${_selectedDate.day} de ${_months[_selectedDate.month - 1]}', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                selectedDayTasks.isEmpty ? 'Sem tarefas' : '${selectedDayTasks.length} Tarefa${selectedDayTasks.length > 1 ? 's' : ''}', 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Task timeline
          if (selectedDayTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Nenhuma entrega neste dia', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          else
            ...selectedDayTasks.map((tarefa) => _buildTimelineItem(
              context, 
              time: dateFormat.format(tarefa.dataEntrega), 
              title: tarefa.titulo, 
              subtitle: '${tarefa.tipo == TipoTarefa.atividade ? 'Atividade' : 'Projeto'} • ${tarefa.pontos} pontos',
              color: _getTaskColor(tarefa),
              daysRemaining: tarefa.dataEntrega.difference(DateTime.now()).inDays,
              isCompleted: tarefa.status == StatusTarefa.concluida,
            )),
           
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Color _getTaskColor(TarefaModel tarefa) {
    if (tarefa.status == StatusTarefa.concluida) return Colors.green;
    final daysRemaining = tarefa.dataEntrega.difference(DateTime.now()).inDays;
    if (daysRemaining < 0) return Colors.red;
    if (daysRemaining <= 2) return Colors.orange;
    return Colors.blue;
  }

  List<Widget> _buildCalendarGrid(BuildContext context, int startWeekday, int daysInMonth, List<TarefaModel> tarefas) {
    List<Widget> rows = [];
    List<Widget> currentDayWidgets = [];
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Add empty spaces for the first week
    for (int i = 0; i < startWeekday; i++) {
      currentDayWidgets.add(const Expanded(child: SizedBox(height: 48)));
    }

    // Add actual days
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = _selectedDate.day == day;
      final dotColor = _getDayDotColor(tarefas, day);
      final hasTasks = dotColor != null;
      
      currentDayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
              });
            },
            child: Container(
              height: 48,
              decoration: isSelected ? BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ) : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : (dotColor == Colors.red ? Colors.red : Colors.black87),
                      fontWeight: isSelected || hasTasks ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (hasTasks && !isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
      );

      if (currentDayWidgets.length == 7) {
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: currentDayWidgets),
        ));
        currentDayWidgets = [];
      }
    }

    // Fill remaining spaces in the last week
    if (currentDayWidgets.isNotEmpty) {
      while (currentDayWidgets.length < 7) {
        currentDayWidgets.add(const Expanded(child: SizedBox(height: 48)));
      }
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: currentDayWidgets),
      ));
    }

    return rows;
  }

  Widget _buildTimelineItem(BuildContext context, {
    required String time, 
    required String title, 
    required String subtitle, 
    required Color color,
    required int daysRemaining,
    required bool isCompleted,
  }) {
    String statusText;
    if (isCompleted) {
      statusText = '✓ Entregue';
    } else if (daysRemaining < 0) {
      statusText = '⚠ Atrasado ${-daysRemaining} dia${-daysRemaining > 1 ? 's' : ''}';
    } else if (daysRemaining == 0) {
      statusText = '⏰ Entrega hoje!';
    } else {
      statusText = '$daysRemaining dia${daysRemaining > 1 ? 's' : ''} restante${daysRemaining > 1 ? 's' : ''}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 12)),
          ),
          Column(
            children: [
              Container(
                width: 12, 
                height: 12, 
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.white, 
                  shape: BoxShape.circle, 
                  border: Border.fromBorderSide(BorderSide(color: color, width: 2)),
                ),
                child: isCompleted ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
              ),
              Container(width: 2, height: 60, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: color, width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
