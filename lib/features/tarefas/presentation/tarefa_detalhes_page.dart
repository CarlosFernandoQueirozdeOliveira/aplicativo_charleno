
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/tarefa_model.dart';
import '../data/tarefa_service.dart';

class TarefaDetalhesPage extends ConsumerStatefulWidget {
  final TarefaModel tarefa;

  const TarefaDetalhesPage({super.key, required this.tarefa});

  @override
  ConsumerState<TarefaDetalhesPage> createState() => _TarefaDetalhesPageState();
}

class _TarefaDetalhesPageState extends ConsumerState<TarefaDetalhesPage> {
  bool _isDelivering = false;
  late StatusTarefa _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.tarefa.status;
  }

  bool get _isDelivered => _currentStatus == StatusTarefa.concluida;

  void _entregarTarefa() async {
    setState(() => _isDelivering = true);
    
    try {
      // Debug log
      print('🔵 Entregando tarefa: ${widget.tarefa.id}');
      
      // Chamar API real para atualizar status
      final dto = TarefaUpdateDto(status: StatusTarefa.concluida);
      print('🔵 DTO: ${dto.toJson()}');
      
      await ref.read(tarefaServiceProvider).updateTarefa(widget.tarefa.id, dto);
      
      print('✅ Tarefa entregue com sucesso!');
      
      if (mounted) {
        setState(() {
          _currentStatus = StatusTarefa.concluida;
          _isDelivering = false;
        });
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Tarefa Entregue!'),
            content: const Text('Sua tarefa foi entregue com sucesso e está aguardando avaliação.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha dialog
                  Navigator.of(context).pop(true); // Volta para lista com refresh
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDelivering = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao entregar tarefa: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarefa = widget.tarefa;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final dateFormat = DateFormat("d 'de' MMMM, HH:mm", 'pt_BR');

    final isExpired = DateTime.now().isAfter(tarefa.dataEntrega);
    final daysRemaining = tarefa.dataEntrega.difference(DateTime.now()).inDays;
    final isDelivered = _isDelivered;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
             icon: Icon(Icons.chevron_left, size: 30, color: primaryColor),
             onPressed: () => Navigator.of(context).pop(),
             style: IconButton.styleFrom(
               backgroundColor: primaryColor.withValues(alpha: 0.1),
               shape: const CircleBorder(),
             ),
          ),
        ),
        title: const Text('Detalhes da Tarefa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tarefa.tipo == TipoTarefa.atividade ? 'Atividade' : 'Projeto',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isDelivered) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Entregue',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tarefa.titulo,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.stars,
                          label: 'Pontuação',
                          value: '${tarefa.pontos} pontos',
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.person,
                          label: 'Tipo',
                          value: 'Individual', // Hardcoded as per design example
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isExpired ? Colors.red.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.calendar_today, color: Colors.red.shade600),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DATA DE ENTREGA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                dateFormat.format(tarefa.dataEntrega),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                             isExpired ? 'Expirado' : '$daysRemaining dias restantes',
                             style: TextStyle(
                               fontSize: 11,
                               fontWeight: FontWeight.w600,
                               color: Colors.red.shade600,
                             ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Descrição',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarefa.descricao ?? 'Sem descrição disponível.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                         const Text(
                          'Anexos (1)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Baixando anexo: guia_estudo.pdf')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text('guia_estudo.pdf', style: TextStyle(fontSize: 14)),
                                ),
                                Icon(Icons.download, color: Colors.grey.shade400, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white.withValues(alpha: 0.95),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isDelivering || isDelivered) ? null : _entregarTarefa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDelivered ? Colors.green : primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDelivered ? Colors.green.shade300 : null,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: isDelivered ? 0 : 4,
                  ),
                  child: _isDelivering 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : isDelivered
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle),
                            SizedBox(width: 8),
                            Text('Tarefa Entregue'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file),
                            SizedBox(width: 8),
                            Text('Entregar Tarefa'),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configurações da tarefa em desenvolvimento.')),
                    );
                  },
                  icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
