
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(top: 48, bottom: 80, left: 24, right: 24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('A navegação entre abas é feita pela barra inferior.')),
                          );
                        }, // Handled by Main Navigation switch usually
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1), 
                          padding: const EdgeInsets.all(8)
                        ),
                      ),
                      const Text(
                        'Perfil do Aluno',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edição de perfil em desenvolvimento.')),
                          );
                        },
                        style: IconButton.styleFrom(
                           backgroundColor: Colors.white.withValues(alpha: 0.1),
                           padding: const EdgeInsets.all(8)
                        ),
                      ),
                    ],
                   ),
                   const SizedBox(height: 24),
                   Stack(
                     alignment: Alignment.bottomRight,
                     children: [
                       Container(
                         width: 128,
                         height: 128,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white, width: 4),
                           image: const DecorationImage(
                             image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAZNkObTSydl1mu4U79sLkriyJ_XC11akv39PVkTWXDw64Wt_jJIprZOMMmKCnb0LiOZKIxEbS6vaWTXv_Hg7Die80zbp0rclncRgJjrOarY1Ex1sHMHc4Xv8geRgFP0nTGGPAL4LfwtF401jy7M5yTtsrs18Cekxy24__aNU-UUN_5wiYzmiI0Codld5dfxTIXhPm6dBfSzqmX8p55uxlCNMakYJPpeSgIVANIXLbfK1_BOIlmhGTkbqGRjoxucv1Ff-VkWtehwWs'),
                             fit: BoxFit.cover,
                           ),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black26,
                               blurRadius: 10,
                               offset: Offset(0, 4),
                             )
                           ]
                         ),
                       ),
                       Container(
                         padding: const EdgeInsets.all(6),
                         decoration: const BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                         ),
                         child: Icon(Icons.verified, color: primaryColor, size: 20),
                       )
                     ],
                   ),
                   const SizedBox(height: 16),
                   const Text(
                     'Carlos Silva',
                     style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                   ),
                   const Text(
                     'Engenharia de Software',
                     style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                   ),
                   const SizedBox(height: 4),
                   const Text(
                     'Matrícula: 20230102',
                     style: TextStyle(color: Colors.white60, fontSize: 12),
                   ),
                ],
              ),
            ),

            // Stats Card (Overlapping)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, '8.5', 'CR'),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      _buildStatItem(context, '90%', 'Presença'),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      _buildStatItem(context, '5', 'Pendentes'),
                    ],
                  ),
                ),
              ),
            ),

            // Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Acadêmico'),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(context, Icons.person, 'Meus Dados', isFirst: true, onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Página de dados pessoais em desenvolvimento.')),
                          );
                        }),
                        _buildDivider(),
                        _buildMenuItem(context, Icons.description, 'Histórico Escolar', onTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Download do histórico em desenvolvimento.')),
                          );
                        }),
                        _buildDivider(),
                        _buildMenuItem(context, Icons.settings, 'Configurações', isLast: true, onTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Página de configurações em desenvolvimento.')),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Sessão'),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: _buildMenuItem(
                      context, 
                      Icons.logout, 
                      'Sair da Conta', 
                      isDestructive: true,
                      onTap: () async {
                         await ref.read(authServiceProvider).logout();
                         if (context.mounted) {
                           Navigator.of(context).pushReplacement(
                             MaterialPageRoute(builder: (_) => const LoginPage()),
                           );
                         }
                      },
                      isFirst: true,
                      isLast: true
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
           value,
           style: TextStyle(
             color: Theme.of(context).colorScheme.primary,
             fontSize: 20,
             fontWeight: FontWeight.bold,
           ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {
    bool isDestructive = false, 
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false
  }) {
    final color = isDestructive ? Colors.red : Colors.grey.shade700;
    final iconColor = isDestructive ? Colors.red.shade500 : Theme.of(context).colorScheme.primary;
    final bgIcon = isDestructive ? Colors.red.shade50 : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
         padding: const EdgeInsets.all(16),
         child: Row(
           children: [
             Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 color: bgIcon,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Icon(icon, color: iconColor, size: 20),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Text(
                 title,
                 style: TextStyle(
                   color: color,
                   fontWeight: FontWeight.w600,
                   fontSize: 14
                 ),
               ),
             ),
             Icon(
               Icons.chevron_right, 
               color: isDestructive ? Colors.red.shade200 : Colors.grey.shade300,
               size: 20,
             ),
           ],
         ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 72, endIndent: 24);
  }
}
