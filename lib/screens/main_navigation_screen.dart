import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';
import 'appointments_screen.dart';
import 'calendar_screen.dart';
import 'doctor_availability_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  UserModel? _currentUser;

  List<Widget> get _screens {
    if (_currentUser?.role == 'doctor') {
      return [
        const HomeScreen(),
        const AppointmentsScreen(),
        const CalendarScreen(),
        const DoctorAvailabilityScreen(),
        const MessagesScreen(),
        const SettingsScreen(),
      ];
    } else {
      return [
        const HomeScreen(),
        const AppointmentsScreen(),
        const CalendarScreen(),
        const MessagesScreen(),
        const SettingsScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> get _bottomNavItems {
    if (_currentUser?.role == 'doctor') {
      return [
        BottomNavigationBarItem(
          icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(_currentIndex == 1 ? Icons.event : Icons.event_outlined),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 2
                ? Icons.calendar_month
                : Icons.calendar_month_outlined,
          ),
          label: 'Calendario',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 3 ? Icons.schedule : Icons.schedule_outlined,
          ),
          label: 'Disponibilidad',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 4 ? Icons.message : Icons.message_outlined,
          ),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 5 ? Icons.settings : Icons.settings_outlined,
          ),
          label: 'Configuración',
        ),
      ];
    } else {
      return [
        BottomNavigationBarItem(
          icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(_currentIndex == 1 ? Icons.event : Icons.event_outlined),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 2
                ? Icons.calendar_month
                : Icons.calendar_month_outlined,
          ),
          label: 'Calendario',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 3 ? Icons.message : Icons.message_outlined,
          ),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 4 ? Icons.settings : Icons.settings_outlined,
          ),
          label: 'Configuración',
        ),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final user = await authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF667EEA),
          unselectedItemColor: const Color(0xFF718096),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: _bottomNavItems,
        ),
      ),
    );
  }
}
