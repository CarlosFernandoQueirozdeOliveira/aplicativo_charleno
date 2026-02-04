
import 'package:flutter/material.dart';
import '../../tarefas/presentation/tarefas_page.dart';
import '../../calendar/presentation/calendar_page.dart';
import '../../notices/presentation/notices_page.dart';
import '../../profile/presentation/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TarefasPage(),
    CalendarPage(),
    NoticesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.05),
               blurRadius: 10,
               offset: const Offset(0, -5),
             )
          ]
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70, // Slightly taller for more space
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Colors.grey.shade400),
              selectedIcon: Icon(Icons.assignment, color: Theme.of(context).colorScheme.primary),
              label: 'Tarefas',
            ),
            NavigationDestination(
               icon: Icon(Icons.calendar_today_outlined, color: Colors.grey.shade400),
               selectedIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
               label: 'Calendário',
            ),
            NavigationDestination(
               icon: Icon(Icons.notifications_none_outlined, color: Colors.grey.shade400),
               selectedIcon: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
               label: 'Avisos',
            ),
            NavigationDestination(
               icon: Icon(Icons.person_outline, color: Colors.grey.shade400),
               selectedIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
               label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
