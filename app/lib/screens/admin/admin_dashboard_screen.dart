import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> _residentes = [];
  List<dynamic> _visitas = [];
  List<dynamic> _encomiendas = [];
  List<dynamic> _bitacora = [];

  Map<String, dynamic> _metricasEncomiendas = {};
  Map<String, dynamic> _metricasEstacionamientos = {};

  bool _isLoading = true;
  bool _isRefreshing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarDatos();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cargarDatos(esRefresco: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarDatos({bool esRefresco = false}) async {
    if (_isRefreshing) return;

    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      final resultados = await Future.wait([
        ApiService.getResidentes(),
        ApiService.getVisitas(),
        ApiService.getEncomiendas(),
        ApiService.getMetricasEncomiendas(),
        ApiService.getMetricasEstacionamientos(),
        ApiService.getBitacora(),
      ]);

      if (!mounted) return;

      setState(() {
        _residentes = resultados[0] as List<dynamic>;
        _visitas = resultados[1] as List<dynamic>;
        _encomiendas = resultados[2] as List<dynamic>;
        _metricasEncomiendas = resultados[3] as Map<String, dynamic>;
        _metricasEstacionamientos = resultados[4] as Map<String, dynamic>;
        _bitacora = resultados[5] as List<dynamic>;

        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      debugPrint('Error cargando dashboard administrativo: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  int get _residentesActivos {
    return _residentes.where((residente) {
      return residente['activo'] != false;
    }).length;
  }

  int get _visitasUltimosSieteDias {
    final hoy = DateTime.now();

    return _visitas.where((visita) {
      final fecha = _parsearFecha(visita['horaIngreso']);

      if (fecha == null) return false;

      final diferencia = DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
      ).difference(DateTime(fecha.year, fecha.month, fecha.day)).inDays;

      return diferencia >= 0 && diferencia < 7;
    }).length;
  }

  int get _encomiendasPendientes {
    return _encomiendas.where((encomienda) {
      return encomienda['estado'] == 'EN_CONSERJERIA';
    }).length;
  }

  int get _alertasBitacora {
    return _bitacora.where((novedad) {
      final categoria = '${novedad['categoria'] ?? ''}';
      return categoria == 'SEGURIDAD' || categoria == 'MANTENCION';
    }).length;
  }

  DateTime? _parsearFecha(dynamic valor) {
    if (valor == null) return null;

    try {
      return DateTime.parse(valor.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  List<int> _visitasPorDia() {
    final hoy = DateTime.now();
    final cantidades = List<int>.filled(7, 0);

    for (final visita in _visitas) {
      final fecha = _parsearFecha(visita['horaIngreso']);
      if (fecha == null) continue;

      final diferencia = DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
      ).difference(DateTime(fecha.year, fecha.month, fecha.day)).inDays;

      if (diferencia >= 0 && diferencia < 7) {
        cantidades[6 - diferencia]++;
      }
    }

    return cantidades;
  }

  List<String> _nombresDias() {
    const nombres = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final hoy = DateTime.now();

    return List.generate(7, (index) {
      final fecha = hoy.subtract(Duration(days: 6 - index));
      return nombres[fecha.weekday - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isRefreshing
                ? null
                : () => _cargarDatos(esRefresco: true),
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen del Condominio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Indicadores generales y actividad reciente',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 22),
              _buildCards(),
              const SizedBox(height: 24),
              _buildGraficos(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        final espacio = 12.0;
        final ancho =
            (constraints.maxWidth - ((columnas - 1) * espacio)) / columnas;

        final cards = [
          _statCard(
            'Residentes activos',
            '$_residentesActivos',
            Icons.people_outline,
            AppColors.primaryBlue,
          ),
          _statCard(
            'Visitas últimos 7 días',
            '$_visitasUltimosSieteDias',
            Icons.directions_walk,
            AppColors.green,
          ),
          _statCard(
            'Encomiendas pendientes',
            '$_encomiendasPendientes',
            Icons.inventory_2_outlined,
            AppColors.orange,
          ),
          _statCard(
            'Alertas de bitácora',
            '$_alertasBitacora',
            Icons.warning_amber_rounded,
            AppColors.red,
          ),
        ];

        return Wrap(
          spacing: espacio,
          runSpacing: espacio,
          children: cards.map((card) {
            return SizedBox(width: ancho, child: card);
          }).toList(),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficos() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dosColumnas = constraints.maxWidth >= 900;

        final visitas = _buildGraficoVisitas();
        final encomiendas = _buildGraficoEncomiendas();

        if (dosColumnas) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: visitas),
              const SizedBox(width: 16),
              Expanded(child: encomiendas),
            ],
          );
        }

        return Column(
          children: [visitas, const SizedBox(height: 16), encomiendas],
        );
      },
    );
  }

  Widget _buildGraficoVisitas() {
    final cantidades = _visitasPorDia();
    final dias = _nombresDias();
    final maximo = cantidades.reduce((a, b) => a > b ? a : b);

    return _panel(
      title: 'Visitas de los últimos 7 días',
      child: SizedBox(
        height: 260,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final cantidad = cantidades[index];
            final porcentaje = maximo == 0 ? 0.02 : cantidad / maximo;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$cantidad',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: porcentaje,
                          child: Container(
                            width: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dias[index],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGraficoEncomiendas() {
    final pendientes = _encomiendas
        .where((e) => e['estado'] == 'EN_CONSERJERIA')
        .length;

    final entregadas = _encomiendas
        .where((e) => e['estado'] == 'ENTREGADO')
        .length;

    final devueltas = _encomiendas
        .where((e) => e['estado'] == 'DEVUELTO')
        .length;

    final total = pendientes + entregadas + devueltas;
    final maximo = total == 0 ? 1 : total;

    return _panel(
      title: 'Estado de encomiendas',
      child: Column(
        children: [
          _barraEstado('Pendientes', pendientes, AppColors.orange, maximo),
          const SizedBox(height: 16),
          _barraEstado('Entregadas', entregadas, AppColors.green, maximo),
          const SizedBox(height: 16),
          _barraEstado('Devueltas', devueltas, AppColors.red, maximo),
          const SizedBox(height: 12),
          Text(
            'Total registrado: $total',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _barraEstado(String texto, int cantidad, Color color, int maximo) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(texto, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: cantidad / maximo,
              minHeight: 16,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$cantidad',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
