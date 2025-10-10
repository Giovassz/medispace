import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  UserModel? _currentUser;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const AppointmentsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final user = await authService.getCurrentUserData();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 1 ? Icons.calendar_month : Icons.calendar_month_outlined),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 2 ? Icons.event_note : Icons.event_note_outlined),
            label: _currentUser!.role == 'doctor' ? 'Mis Citas' : 'Mis Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 3 ? Icons.person : Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
