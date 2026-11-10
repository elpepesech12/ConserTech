import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _metricasEst = {
    'total': 120,
    'disponibles': 45,
    'ocupados': 68,
    'mantencion': 7,
  };
  List<dynamic> _residentes = [];
  List<dynamic> _residentesFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final metricas = await ApiService.getMetricasEstacionamientos();
      final residentes = await ApiService.getResidentes();
      if (mounted) {
        setState(() {
          _metricasEst = metricas;
          _residentes = residentes;
          _residentesFiltrados = residentes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filtrar(String query) {
    if (query.trim().isEmpty) {
      setState(() => _residentesFiltrados = _residentes);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _residentesFiltrados = _residentes.where((r) {
        final rut = (r['rut'] ?? '').toString().toLowerCase();
        final nom = (r['nombre'] ?? '').toString().toLowerCase();
        final ape = (r['apellido'] ?? '').toString().toLowerCase();
        final depto = r['departamento'] != null
            ? (r['departamento']['numero'] ?? '').toString().toLowerCase()
            : '';
        return rut.contains(q) ||
            nom.contains(q) ||
            ape.contains(q) ||
            depto.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      'Resumen operativo y flujo de accesos',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Tarjeta Estacionamientos de invitados conectada a BD
              Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estacionamientos de invitados',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _statItem(
                      AppColors.green,
                      'Estacionamientos disp.',
                      '${_metricasEst['disponibles'] ?? 0}',
                    ),
                    const SizedBox(height: 8),
                    _statItem(
                      AppColors.red,
                      'Estacionamientos ocup.',
                      '${_metricasEst['ocupados'] ?? 0}',
                    ),
                    const SizedBox(height: 8),
                    _statItem(
                      AppColors.orange,
                      'Estacionamientos mant./res.',
                      '${_metricasEst['mantencion'] ?? 0}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfico de barras: Visitas últimos 30 días
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Visitas últimos 30 días',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar('Lunes', 45),
                      _bar('Martes', 95),
                      _bar('Miércoles', 95),
                      _bar('Jueves', 95),
                      _bar('Viernes', 140),
                      _bar('Sábado', 140),
                      _bar('Domingo', 140),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Buscador de residentes
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_list,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _filtrar,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    hintText: 'Buscar residente o RUT...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tabla conectada a BD
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.4),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(1.0),
                4: FlexColumnWidth(1.0),
                5: FlexColumnWidth(1.3),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  children: [
                    _TH('RUT'),
                    _TH('NOMBRE'),
                    _TH('APELLIDO'),
                    _TH('DEPTO'),
                    _TH('TORRE'),
                    _TH('TIPO'),
                  ],
                ),
                if (_isLoading)
                  const TableRow(
                    children: [
                      _TD('Cargando...'),
                      _TD(''),
                      _TD(''),
                      _TD(''),
                      _TD(''),
                      _TD(''),
                    ],
                  )
                else if (_residentesFiltrados.isEmpty)
                  const TableRow(
                    children: [
                      _TD('Sin registros'),
                      _TD('-'),
                      _TD('-'),
                      _TD('-'),
                      _TD('-'),
                      _TD('-'),
                    ],
                  )
                else
                  ..._residentesFiltrados.map((r) {
                    final depto = r['departamento'];
                    return TableRow(
                      children: [
                        _TD(r['rut'] ?? ''),
                        _TD(r['nombre'] ?? ''),
                        _TD(r['apellido'] ?? ''),
                        _TD(depto != null ? (depto['numero'] ?? '') : ''),
                        _TD(depto != null ? (depto['torre'] ?? '') : ''),
                        _TD(r['tipoResidente'] ?? 'PROPIETARIO'),
                      ],
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(Color dot, String label, String val) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: dot),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _bar(String day, double h) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 48,
          height: h,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: AppColors.textMain,
        ),
      ),
    );
  }
}

class _TD extends StatelessWidget {
  final String text;
  const _TD(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.textMain),
      ),
    );
  }
}
