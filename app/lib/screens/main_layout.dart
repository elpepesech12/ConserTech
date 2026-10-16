import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../core/theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'visitas_screen.dart';
import 'estacionamientos_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1; // Inicia en Visitas por defecto

  final List<Widget> _screens = const [
    DashboardScreen(),
    VisitasScreen(),
    EstacionamientosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      // Restauramos la barra superior con el menú hamburguesa
      appBar: AppBar(
        title: const Text('ConserTech - Panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Configuramos el Sidebar como un menú desplegable transparente para mantener tu diseño de cápsula
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Sidebar(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            Navigator.pop(context); // Cierra el menú automáticamente al hacer clic
          },
        ),
      ),
      // El contenido ocupará todo el ancho disponible
      body: _screens[_currentIndex],
    );
  }
}