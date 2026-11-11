import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'admin_usuarios_screen.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import 'admin_bitacora_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;

  // Las pantallas exclusivas del admin que se mostrarán al hacer clic en el menú
  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminUsuariosScreen(),
    const AdminBitacoraScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menú lateral izquierdo
          _buildAdminSidebar(),
          // Contenedor principal derecho (cambia según el menú)
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildAdminSidebar() {
    return Container(
      width: 250,
      color: AppColors.primaryDark,
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
          const SizedBox(height: 10),
          const Text(
            'ADMINISTRACIÓN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildNavItem(Icons.dashboard, 'Dashboard', 0),
          _buildNavItem(Icons.people, 'Gestión de Personal', 1),
          _buildNavItem(Icons.menu_book_outlined, 'Bitácora', 2),

          const Spacer(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              AuthService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white54),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
