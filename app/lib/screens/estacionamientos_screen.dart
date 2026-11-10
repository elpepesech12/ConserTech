import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/api_service.dart';

class EstacionamientosScreen extends StatefulWidget {
  const EstacionamientosScreen({super.key});

  @override
  State<EstacionamientosScreen> createState() => _EstacionamientosScreenState();
}

class _EstacionamientosScreenState extends State<EstacionamientosScreen> {
  List<dynamic> _estacionamientos = [];
  Map<String, dynamic> _metricas = {
    'total': 120,
    'disponibles': 45,
    'ocupados': 68,
    'mantencion': 7,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final list = await ApiService.getEstacionamientos();
      final metrics = await ApiService.getMetricasEstacionamientos();
      if (mounted) {
        setState(() {
          _estacionamientos = list;
          _metricas = metrics;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getColorForEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return AppColors.green;
      case 'OCUPADO':
        return AppColors.red;
      case 'MANTENCION':
      case 'RESERVADO':
        return AppColors.orange;
      default:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tomamos los slots de la BD para los edificios o asignamos según su índice
    List<String> codigos = _estacionamientos
        .map((e) => (e['codigo'] ?? '').toString())
        .toList();
    List<Color> colores = _estacionamientos
        .map((e) => _getColorForEstado(e['estado'] ?? 'DISPONIBLE'))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estacionamientos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const Text(
            'Control de ocupación y asignaciones por edificio',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Métricas superiores oscuras estilo ConserTech conectadas a BD
          Row(
            children: [
              _metricDark(
                'TOTAL ESTACIONAMIENTOS',
                '${_metricas['total'] ?? 10}',
                null,
                AppColors.cardDark,
              ),
              const SizedBox(width: 12),
              _metricDark(
                'DISPONIBLES',
                '${_metricas['disponibles'] ?? 0}',
                AppColors.green,
                AppColors.primaryDark,
              ),
              const SizedBox(width: 12),
              _metricDark(
                'OCUPADOS',
                '${_metricas['ocupados'] ?? 0}',
                AppColors.red,
                AppColors.primaryDark,
              ),
              const SizedBox(width: 12),
              _metricDark(
                'MANTENCIÓN / RES.',
                '${_metricas['mantencion'] ?? 0}',
                AppColors.orange,
                AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Plano Visual del Estacionamiento
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Plano Visual del Estacionamiento',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textMain,
                      ),
                    ),
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.green,
                        ),
                        SizedBox(width: 4),
                        Text('Disponible  ', style: TextStyle(fontSize: 11)),
                        CircleAvatar(radius: 4, backgroundColor: AppColors.red),
                        SizedBox(width: 4),
                        Text('Ocupado  ', style: TextStyle(fontSize: 11)),
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.orange,
                        ),
                        SizedBox(width: 4),
                        Text('Mantención', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _edificioBox(
                        'EDIFICIO 101-A',
                        _sublist(codigos, 0, 6, [
                          'V-01',
                          'V-02',
                          'V-03',
                          'V-04',
                          'V-05',
                          'V-06',
                        ]),
                        _sublist(colores, 0, 6, [
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                        ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _edificioBox(
                        'EDIFICIO 101-B',
                        _sublist(codigos, 6, 10, [
                          'V-07',
                          'V-08',
                          'V-09',
                          'V-10',
                          'V-11',
                          'V-12',
                        ]),
                        _sublist(colores, 6, 10, [
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                          AppColors.green,
                        ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _edificioBox(
                        'EDIFICIO 204-A',
                        ['21', '22', '23', '24', '25', '26'],
                        [
                          AppColors.red,
                          AppColors.red,
                          AppColors.green,
                          AppColors.green,
                          AppColors.orange,
                          AppColors.red,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _edificioBox(
                        'EDIFICIO 204-B',
                        ['31', '32', '33', '34', '35', '36'],
                        [
                          AppColors.green,
                          AppColors.green,
                          AppColors.red,
                          AppColors.green,
                          AppColors.red,
                          AppColors.orange,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Buscador + Botón Asignar
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
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: _cargarDatos,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Actualizar Estado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tabla de Asignaciones
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.0),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1.0),
                5: FlexColumnWidth(1.2),
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
                    _TH('ESTACIONAMIENTO'),
                    _TH('EDIFICIO'),
                    _TH('RESIDENTE'),
                    _TH('RUT'),
                    _TH('ESTADO'),
                    _TH('ACCIONES'),
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
                else
                  ..._estacionamientos.map((e) {
                    final estado = (e['estado'] ?? 'DISPONIBLE').toString();
                    final color = _getColorForEstado(estado);
                    return TableRow(
                      children: [
                        _TD(e['codigo'] ?? '', isBold: true),
                        _TD(e['tipo'] ?? 'VISITA'),
                        _TD('Sector Visitas'),
                        _TD('-'),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: Chip(
                            label: Text(
                              estado,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: color.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          onSelected: (val) async {
                            await ApiService.cambiarEstadoEstacionamiento(
                              e['id'],
                              val,
                            );
                            _cargarDatos();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'DISPONIBLE',
                              child: Text(
                                'Disponible',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'OCUPADO',
                              child: Text(
                                'Ocupado',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'MANTENCION',
                              child: Text(
                                'Mantención',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
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

  List<T> _sublist<T>(List<T> list, int start, int end, List<T> fallback) {
    if (list.length >= end) {
      return list.sublist(start, end);
    } else if (list.length > start) {
      return list.sublist(start);
    }
    return fallback;
  }

  Widget _metricDark(String label, String value, Color? dotColor, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (dotColor != null) ...[
                  CircleAvatar(radius: 3, backgroundColor: dotColor),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _edificioBox(String title, List<String> slots, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length > 6 ? 6 : slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (_, i) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: i < colors.length ? colors[i] : AppColors.green,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                slots[i],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String t;
  const _TH(this.t);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        t,
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
  final String t;
  final bool isBold;
  const _TD(this.t, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textMain,
        ),
      ),
    );
  }
}
