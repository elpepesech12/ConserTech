import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _visitas = [];
  List<dynamic> _residentes = [];
  List<dynamic> _residentesFiltrados = [];

  Map<String, dynamic> _metricasPaquetes = {
    'total': 0,
    'pendientes': 0,
    'entregadas': 0,
  };

  bool _isLoading = true;
  bool _isRefreshing = false;

  DateTime? _ultimaActualizacion;
  Timer? _refreshTimer;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _cargarDatos();

    // Actualización automática cada 30 segundos.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
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
      final resultados = await Future.wait([
        ApiService.getVisitas(),
        ApiService.getResidentes(),
        ApiService.getMetricasEncomiendas(),
      ]);

      final visitas = resultados[0] as List<dynamic>;
      final residentes = resultados[1] as List<dynamic>;
      final metricasPaquetes = resultados[2] as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        _visitas = visitas;
        _residentes = residentes;
        _metricasPaquetes = metricasPaquetes;

        // Si ya había una búsqueda escrita, la aplicamos nuevamente.
        _residentesFiltrados = _filtrarLista(residentes, _searchCtrl.text);

        _isLoading = false;
        _isRefreshing = false;
        _ultimaActualizacion = DateTime.now();
      });
    } catch (e) {
      debugPrint('Error cargando dashboard: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  List<dynamic> _filtrarLista(List<dynamic> residentes, String query) {
    if (query.trim().isEmpty) {
      return residentes;
    }

    final q = query.trim().toLowerCase();

    return residentes.where((r) {
      final rut = (r['rut'] ?? '').toString().toLowerCase();
      final nombre = (r['nombre'] ?? '').toString().toLowerCase();
      final apellido = (r['apellido'] ?? '').toString().toLowerCase();

      final departamento = r['departamento'];
      final numeroDepto = departamento != null
          ? (departamento['numero'] ?? '').toString().toLowerCase()
          : '';

      final torre = departamento != null
          ? (departamento['torre'] ?? '').toString().toLowerCase()
          : '';

      return rut.contains(q) ||
          nombre.contains(q) ||
          apellido.contains(q) ||
          numeroDepto.contains(q) ||
          torre.contains(q);
    }).toList();
  }

  void _filtrarResidentes(String query) {
    setState(() {
      _residentesFiltrados = _filtrarLista(_residentes, query);
    });
  }

  List<dynamic> get _visitasActivas {
    return _visitas.where((visita) {
      return visita['horaSalida'] == null;
    }).toList();
  }

  List<dynamic> get _visitasDeHoy {
    final ahora = DateTime.now();

    return _visitas.where((visita) {
      final fecha = _parsearFecha(visita['horaIngreso']);

      if (fecha == null) return false;

      return fecha.year == ahora.year &&
          fecha.month == ahora.month &&
          fecha.day == ahora.day;
    }).toList();
  }

  DateTime? _parsearFecha(dynamic valor) {
    if (valor == null) return null;

    try {
      return DateTime.parse(valor.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  List<int> _visitasUltimosSieteDias() {
    final ahora = DateTime.now();

    final cantidades = List<int>.filled(7, 0);

    for (final visita in _visitas) {
      final fecha = _parsearFecha(visita['horaIngreso']);

      if (fecha == null) continue;

      final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

      final hoySinHora = DateTime(ahora.year, ahora.month, ahora.day);

      final diferencia = hoySinHora.difference(fechaSinHora).inDays;

      if (diferencia >= 0 && diferencia < 7) {
        // Índice 0: hace 6 días.
        // Índice 6: hoy.
        final indice = 6 - diferencia;
        cantidades[indice]++;
      }
    }

    return cantidades;
  }

  List<String> _nombresUltimosSieteDias() {
    final ahora = DateTime.now();

    const nombres = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return List.generate(7, (index) {
      final fecha = ahora.subtract(Duration(days: 6 - index));
      return nombres[fecha.weekday - 1];
    });
  }

  String _horaActualizacion() {
    if (_ultimaActualizacion == null) return 'Sin actualizar';

    final hora = _ultimaActualizacion!.hour.toString().padLeft(2, '0');
    final minuto = _ultimaActualizacion!.minute.toString().padLeft(2, '0');

    return 'Actualizado a las $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final visitasActivas = _visitasActivas.length;
    final visitasDeHoy = _visitasDeHoy.length;

    final paquetesPendientes =
        int.tryParse('${_metricasPaquetes['pendientes'] ?? 0}') ?? 0;

    final paquetesEntregados =
        int.tryParse('${_metricasPaquetes['entregadas'] ?? 0}') ?? 0;

    return RefreshIndicator(
      onRefresh: () => _cargarDatos(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            _buildMetricas(
              visitasActivas: visitasActivas,
              visitasDeHoy: visitasDeHoy,
              paquetesPendientes: paquetesPendientes,
              paquetesEntregados: paquetesEntregados,
            ),

            const SizedBox(height: 24),

            _buildGraficoVisitas(),

            const SizedBox(height: 24),

            _buildTituloResidentes(),

            const SizedBox(height: 14),

            _buildBuscadorResidentes(),

            const SizedBox(height: 14),

            _buildTablaResidentes(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard de Conserjería',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Resumen operativo del turno actual',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _isRefreshing
                  ? null
                  : () => _cargarDatos(esRefresco: true),
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 17),
              label: const Text('Actualizar'),
            ),
            const SizedBox(height: 5),
            Text(
              _horaActualizacion(),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricas({
    required int visitasActivas,
    required int visitasDeHoy,
    required int paquetesPendientes,
    required int paquetesEntregados,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;

        final cantidadColumnas = ancho >= 900
            ? 4
            : ancho >= 600
            ? 2
            : 1;

        final espacio = 12.0;
        final anchoTarjeta =
            (ancho - ((cantidadColumnas - 1) * espacio)) / cantidadColumnas;

        final tarjetas = [
          _metricCard(
            titulo: 'VISITAS ACTIVAS',
            valor: '$visitasActivas',
            detalle: 'Personas actualmente dentro',
            icono: Icons.login_outlined,
            color: AppColors.green,
          ),
          _metricCard(
            titulo: 'VISITAS DE HOY',
            valor: '$visitasDeHoy',
            detalle: 'Ingresos registrados hoy',
            icono: Icons.groups_outlined,
            color: AppColors.primaryBlue,
          ),
          _metricCard(
            titulo: 'PAQUETES PENDIENTES',
            valor: '$paquetesPendientes',
            detalle: 'Esperando retiro',
            icono: Icons.inventory_2_outlined,
            color: AppColors.orange,
          ),
          _metricCard(
            titulo: 'PAQUETES ENTREGADOS',
            valor: '$paquetesEntregados',
            detalle: 'Entregas registradas',
            icono: Icons.check_circle_outline,
            color: AppColors.green,
          ),
        ];

        return Wrap(
          spacing: espacio,
          runSpacing: espacio,
          children: tarjetas.map((tarjeta) {
            return SizedBox(width: anchoTarjeta, child: tarjeta);
          }).toList(),
        );
      },
    );
  }

  Widget _metricCard({
    required String titulo,
    required String valor,
    required String detalle,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoVisitas() {
    final cantidades = _visitasUltimosSieteDias();
    final nombresDias = _nombresUltimosSieteDias();

    final maximo = cantidades.isEmpty
        ? 1
        : cantidades.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingresos de visitas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Visitas registradas durante los últimos 7 días',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: ${cantidades.reduce((a, b) => a + b)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 210,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(cantidades.length, (index) {
                final cantidad = cantidades[index];

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _barraGrafico(
                      dia: nombresDias[index],
                      cantidad: cantidad,
                      maximo: maximo,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraGrafico({
    required String dia,
    required int cantidad,
    required int maximo,
  }) {
    final porcentaje = maximo == 0 ? 0.0 : cantidad / maximo;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$cantidad',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: porcentaje == 0 ? 0.02 : porcentaje,
              child: Container(
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dia,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildTituloResidentes() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Directorio de residentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Busca rápidamente un residente, departamento o RUT',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildBuscadorResidentes() {
    return Row(
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
            onChanged: _filtrarResidentes,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: AppColors.textMuted,
              ),
              hintText: 'Buscar residente, RUT o departamento...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTablaResidentes() {
    return Container(
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
            ..._residentesFiltrados.map((residente) {
              final departamento = residente['departamento'];

              return TableRow(
                children: [
                  _TD('${residente['rut'] ?? ''}'),
                  _TD('${residente['nombre'] ?? ''}'),
                  _TD('${residente['apellido'] ?? ''}'),
                  _TD(
                    departamento != null
                        ? '${departamento['numero'] ?? ''}'
                        : '',
                  ),
                  _TD(
                    departamento != null
                        ? '${departamento['torre'] ?? ''}'
                        : '',
                  ),
                  _TD('${residente['tipoResidente'] ?? 'PROPIETARIO'}'),
                ],
              );
            }).toList(),
        ],
      ),
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
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.textMain),
      ),
    );
  }
}
