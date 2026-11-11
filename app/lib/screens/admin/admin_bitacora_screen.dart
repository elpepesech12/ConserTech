import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class AdminBitacoraScreen extends StatefulWidget {
  const AdminBitacoraScreen({super.key});

  @override
  State<AdminBitacoraScreen> createState() => _AdminBitacoraScreenState();
}

class _AdminBitacoraScreenState extends State<AdminBitacoraScreen> {
  List<dynamic> _novedades = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarBitacora();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cargarBitacora(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarBitacora() async {
    try {
      final novedades = await ApiService.getBitacora();

      if (!mounted) return;

      setState(() {
        _novedades = novedades;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando bitácora: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _colorCategoria(String categoria) {
    switch (categoria) {
      case 'SEGURIDAD':
        return AppColors.red;
      case 'MANTENCION':
        return AppColors.orange;
      case 'RECLAMO':
        return Colors.purple;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _fecha(dynamic valor) {
    if (valor == null) return '-';

    try {
      final fecha = DateTime.parse(valor.toString()).toLocal();

      return '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year} '
          '${fecha.hour.toString().padLeft(2, '0')}:'
          '${fecha.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de Novedades'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarBitacora,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _novedades.isEmpty
          ? const Center(child: Text('No hay novedades registradas'))
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _novedades.length,
              itemBuilder: (context, index) {
                final novedad = _novedades[index];
                final categoria = '${novedad['categoria'] ?? 'GENERAL'}';
                final color = _colorCategoria(categoria);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(Icons.article_outlined, color: color),
                    ),
                    title: Text(
                      '${novedad['titulo'] ?? 'Sin título'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${novedad['descripcion'] ?? ''}\n\n'
                        'Conserje: ${novedad['conserjeNombre'] ?? '-'}\n'
                        'Turno: ${novedad['turno'] ?? '-'}\n'
                        'Fecha: ${_fecha(novedad['fechaRegistro'])}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(
                        categoria,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: color.withOpacity(0.12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
