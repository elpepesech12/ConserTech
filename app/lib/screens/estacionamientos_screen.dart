import 'dart:async';

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
    'total': 0,
    'disponibles': 0,
    'ocupados': 0,
    'mantencion': 0,
  };
  bool _isLoading = true;
  bool _isRefreshing = false;
  DateTime? _ultimaActualizacion;
  Timer? _refreshTimer;
  final TextEditingController _searchCtrl = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _cargarDatos(esRefresco: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos({bool esRefresco = false}) async {
    if (esRefresco && mounted) {
      setState(() => _isRefreshing = true);
    }

    try {
      final list = await ApiService.getEstacionamientos();
      final metrics = await ApiService.getMetricasEstacionamientos();

      list.sort((a, b) {
        final codigoA = (a['codigo'] ?? '').toString();
        final codigoB = (b['codigo'] ?? '').toString();
        return codigoA.compareTo(codigoB);
      });

      if (!mounted) return;

      setState(() {
        _estacionamientos = list;
        _metricas = metrics;
        _isLoading = false;
        _isRefreshing = false;
        _ultimaActualizacion = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _cambiarEstado(
    dynamic estacionamiento,
    String nuevoEstado,
  ) async {
    final id = estacionamiento['id'];
    if (id == null) return;

    final ok = await ApiService.cambiarEstadoEstacionamiento(id, nuevoEstado);
    if (ok) {
      await _cargarDatos(esRefresco: true);
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

  Map<String, List<dynamic>> _agruparPorTipo(List<dynamic> lista) {
    final Map<String, List<dynamic>> grupos = {};
    for (final e in lista) {
      final tipo = (e['tipo'] ?? 'VISITA').toString().toUpperCase();
      grupos.putIfAbsent(tipo, () => []).add(e);
    }
    return grupos;
  }

  List<dynamic> get _estacionamientosFiltrados {
    final q = _filtro.trim().toLowerCase();
    if (q.isEmpty) return _estacionamientos;

    return _estacionamientos.where((e) {
      final codigo = (e['codigo'] ?? '').toString().toLowerCase();
      final tipo = (e['tipo'] ?? '').toString().toLowerCase();
      final estado = (e['estado'] ?? '').toString().toLowerCase();
      return codigo.contains(q) || tipo.contains(q) || estado.contains(q);
    }).toList();
  }

  String _horaActualizacion() {
    if (_ultimaActualizacion == null) return 'Sin actualizar';
    final hora = _ultimaActualizacion!.hour.toString().padLeft(2, '0');
    final minuto = _ultimaActualizacion!.minute.toString().padLeft(2, '0');
    final segundo = _ultimaActualizacion!.second.toString().padLeft(2, '0');
    return 'Actualizado a las $hora:$minuto:$segundo';
  }

  String _tituloSector(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'VISITA':
        return 'SECTOR VISITAS';
      case 'RESIDENTE':
        return 'SECTOR RESIDENTES';
      default:
        return 'SECTOR $tipo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _cargarDatos(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                        'Estacionamientos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      Text(
                        'Control de ocupación en tiempo real según la base de datos',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isRefreshing)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _horaActualizacion(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _metricDark(
                  'TOTAL ESTACIONAMIENTOS',
                  '${_metricas['total'] ?? 0}',
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

            _buildPlanoVisual(),
            const SizedBox(height: 22),

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
                    onChanged: (value) => setState(() => _filtro = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      hintText: 'Buscar código, tipo o estado...',
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
                  onPressed: _isRefreshing
                      ? null
                      : () => _cargarDatos(esRefresco: true),
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
                  else if (_estacionamientosFiltrados.isEmpty)
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
                    ..._estacionamientosFiltrados.map((e) {
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
                            onSelected: (val) => _cambiarEstado(e, val),
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
      ),
    );
  }

  Widget _buildPlanoVisual() {
    final grupos = _agruparPorTipo(_estacionamientos);

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Plano Visual del Estacionamiento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const CircleAvatar(radius: 4, backgroundColor: AppColors.green),
              const SizedBox(width: 4),
              const Text('Disponible  ', style: TextStyle(fontSize: 11)),
              const CircleAvatar(radius: 4, backgroundColor: AppColors.red),
              const SizedBox(width: 4),
              const Text('Ocupado  ', style: TextStyle(fontSize: 11)),
              const CircleAvatar(radius: 4, backgroundColor: AppColors.orange),
              const SizedBox(width: 4),
              const Text('Mantención', style: TextStyle(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Cada espacio refleja el estado real de la base de datos. Toca un estacionamiento para cambiarlo.',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_estacionamientos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No hay estacionamientos registrados en la base de datos',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final claves = grupos.keys.toList();
                final columnas = constraints.maxWidth >= 720
                    ? (claves.length >= 2 ? 2 : 1)
                    : 1;
                final espacio = 12.0;
                final anchoSector = columnas == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - espacio) / 2;

                return Wrap(
                  spacing: espacio,
                  runSpacing: espacio,
                  children: claves.map((tipo) {
                    return SizedBox(
                      width: anchoSector,
                      child: _sectorBox(tipo, grupos[tipo] ?? []),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _sectorBox(String tipo, List<dynamic> slots) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tituloSector(tipo),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Text(
                '${slots.length} espacios',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.35,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (_, i) => _slotVisual(slots[i]),
          ),
        ],
      ),
    );
  }

  Widget _slotVisual(dynamic estacionamiento) {
    final codigo = (estacionamiento['codigo'] ?? '').toString();
    final estado = (estacionamiento['estado'] ?? 'DISPONIBLE').toString();
    final color = _getColorForEstado(estado);

    return PopupMenuButton<String>(
      tooltip: '$codigo · $estado',
      onSelected: (val) => _cambiarEstado(estacionamiento, val),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'DISPONIBLE',
          child: Text('Disponible', style: TextStyle(fontSize: 12)),
        ),
        const PopupMenuItem(
          value: 'OCUPADO',
          child: Text('Ocupado', style: TextStyle(fontSize: 12)),
        ),
        const PopupMenuItem(
          value: 'MANTENCION',
          child: Text('Mantención', style: TextStyle(fontSize: 12)),
        ),
      ],
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color, width: 1.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              codigo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              estado,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
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
