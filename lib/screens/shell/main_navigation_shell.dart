import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state.dart';
import '../home/beranda_screen.dart';
import '../jobs/job_list_screen.dart';
import '../reports/report_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    BerandaScreen(),
    JobListScreen(),
    ReportScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex != 0 ? widget.initialIndex : AppState.instance.selectedNavIndex;
    if (widget.initialIndex != 0) {
      AppState.instance.switchNavigation(widget.initialIndex);
    }
    AppState.instance.addListener(_onStateChange);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted && _currentIndex != AppState.instance.selectedNavIndex) {
      setState(() {
        _currentIndex = AppState.instance.selectedNavIndex;
      });
    }
  }

  void switchTab(int index) {
    AppState.instance.switchNavigation(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => AppState.instance.switchNavigation(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Job',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

