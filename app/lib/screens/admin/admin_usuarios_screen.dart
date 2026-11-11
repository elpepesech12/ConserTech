import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  List<dynamic> _usuarios = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cargarUsuarios(esRefresco: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarUsuarios({bool esRefresco = false}) async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final usuarios = await ApiService.getUsuarios();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      debugPrint('Error cargando usuarios: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _cambiarEstado(dynamic usuario) async {
    final id = usuario['id'];

    if (id == null) return;

    final activoActual = usuario['activo'] == true;
    final nuevoEstado = !activoActual;

    final ok = await ApiService.cambiarEstadoUsuario(
      id is int ? id : int.parse(id.toString()),
      nuevoEstado,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? nuevoEstado
                    ? 'Usuario activado'
                    : 'Usuario suspendido'
              : 'No se pudo cambiar el estado',
        ),
        backgroundColor: ok ? AppColors.green : AppColors.red,
      ),
    );

    if (ok) {
      _cargarUsuarios(esRefresco: true);
    }
  }

  String _nombreUsuario(dynamic usuario) {
    final nombre = '${usuario['nombre'] ?? ''}'.trim();
    return nombre.isEmpty ? 'Sin nombre' : nombre;
  }

  String _rolLegible(dynamic usuario) {
    final rol = '${usuario['rol'] ?? ''}';

    switch (rol) {
      case 'ROLE_ADMIN':
        return 'Administrador';
      case 'ROLE_CONSERJE':
        return 'Conserje';
      case 'ROLE_RESIDENTE':
        return 'Residente';
      default:
        return rol.isEmpty ? 'Sin rol' : rol;
    }
  }

  String _fechaLegible(dynamic valor) {
    if (valor == null) return '-';

    try {
      final fecha = DateTime.parse(valor.toString()).toLocal();

      return '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isRefreshing
                ? null
                : () => _cargarUsuarios(esRefresco: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarUsuarios,
              child: _usuarios.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No hay usuarios registrados')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: _usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = _usuarios[index];
                        final activo = usuario['activo'] == true;
                        final nombre = _nombreUsuario(usuario);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: activo
                                  ? AppColors.primaryDark
                                  : Colors.grey,
                              child: Text(
                                nombre.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '${usuario['email'] ?? '-'}\n'
                                '${_rolLegible(usuario)} · '
                                '${_fechaLegible(usuario['creadoEn'])}',
                              ),
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (valor) {
                                if (valor == 'estado') {
                                  _cambiarEstado(usuario);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'estado',
                                  child: Text(
                                    activo
                                        ? 'Suspender acceso'
                                        : 'Activar acceso',
                                    style: TextStyle(
                                      color: activo
                                          ? AppColors.red
                                          : AppColors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
