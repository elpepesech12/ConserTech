import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/api_service.dart';

class VisitasScreen extends StatefulWidget {
  const VisitasScreen({super.key});

  @override
  State<VisitasScreen> createState() => _VisitasScreenState();
}

class _VisitasScreenState extends State<VisitasScreen> {
  // Visitas
  List<dynamic> _visitas = [];
  bool _isLoadingVisitas = false;

  final _nombreCtrl = TextEditingController();
  final _numDocCtrl = TextEditingController();
  final _deptoCtrl = TextEditingController();
  final _residenteCtrl = TextEditingController();
  final _otroTipoCtrl = TextEditingController();

  String _tipoDocSeleccionado = 'RUT';
  final List<String> _tiposDoc = ['RUT', 'Pasaporte', 'DNI Extranjero', 'Otro'];

  // Paquetes (Encomiendas)
  List<dynamic> _encomiendas = [];
  Map<String, dynamic> _metricasPaquetes = {
    'total': 0,
    'pendientes': 0,
    'entregadas': 0,
  };
  bool _isLoadingPaquetes = false;

  final _destinatarioCtrl = TextEditingController();
  final _deptoPaqueteCtrl = TextEditingController();
  final _courierCtrl = TextEditingController();
  final _trackingCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    await Future.wait([_fetchVisitas(), _fetchEncomiendas()]);
  }

  // --- MÉTODOS VISITAS ---
  Future<void> _fetchVisitas() async {
    try {
      final list = await ApiService.getVisitas();
      if (mounted) setState(() => _visitas = list);
    } catch (e) {
      debugPrint("Error cargando visitas: $e");
    }
  }

  Future<void> _registrarVisita() async {
    if (_nombreCtrl.text.isEmpty ||
        _numDocCtrl.text.isEmpty ||
        _deptoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa Nombre, Documento y Depto.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingVisitas = true);

    String tipoFinal = _tipoDocSeleccionado == 'Otro'
        ? 'Otro: ${_otroTipoCtrl.text}'
        : _tipoDocSeleccionado;

    final Map<String, dynamic> body = {
      'nombreCompleto': _nombreCtrl.text.trim(),
      'tipoDocumento': tipoFinal,
      'numeroDocumento': _numDocCtrl.text.trim(),
      'deptoDestino': _deptoCtrl.text.trim(),
      'residenteQueAutoriza': _residenteCtrl.text.trim(),
    };

    final ok = await ApiService.registrarVisita(body);
    if (mounted) {
      if (ok) {
        _nombreCtrl.clear();
        _numDocCtrl.clear();
        _deptoCtrl.clear();
        _residenteCtrl.clear();
        _otroTipoCtrl.clear();
        setState(() => _tipoDocSeleccionado = 'RUT');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visita registrada exitosamente'),
            backgroundColor: AppColors.green,
          ),
        );
        _fetchVisitas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar visita'),
            backgroundColor: AppColors.red,
          ),
        );
      }
      setState(() => _isLoadingVisitas = false);
    }
  }

  Future<void> _marcarSalida(int id) async {
    final ok = await ApiService.marcarSalidaVisita(id);
    if (ok) _fetchVisitas();
  }

  // --- MÉTODOS ENCOMIENDAS ---
  Future<void> _fetchEncomiendas() async {
    try {
      final list = await ApiService.getEncomiendas();
      final metrics = await ApiService.getMetricasEncomiendas();
      if (mounted) {
        setState(() {
          _encomiendas = list;
          _metricasPaquetes = metrics;
        });
      }
    } catch (e) {
      debugPrint("Error cargando encomiendas: $e");
    }
  }

  Future<void> _registrarPaquete() async {
    if (_destinatarioCtrl.text.isEmpty || _deptoPaqueteCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa destinatario y depto.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingPaquetes = true);

    final Map<String, dynamic> body = {
      'destinatarioNombre': _destinatarioCtrl.text.trim(),
      'deptoDestino': _deptoPaqueteCtrl.text.trim(),
      'courier': _courierCtrl.text.trim().isEmpty
          ? 'Chilexpress'
          : _courierCtrl.text.trim(),
      'codigoSeguimiento': _trackingCtrl.text.trim().isEmpty
          ? 'PKG-${DateTime.now().millisecondsSinceEpoch}'
          : _trackingCtrl.text.trim(),
    };

    final ok = await ApiService.registrarEncomienda(body);
    if (mounted) {
      if (ok) {
        _destinatarioCtrl.clear();
        _deptoPaqueteCtrl.clear();
        _courierCtrl.clear();
        _trackingCtrl.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paquete ingresado correctamente'),
            backgroundColor: AppColors.green,
          ),
        );
        _fetchEncomiendas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al ingresar paquete'),
            backgroundColor: AppColors.red,
          ),
        );
      }
      setState(() => _isLoadingPaquetes = false);
    }
  }

  Future<void> _entregarPaquete(int id) async {
    final ok = await ApiService.entregarEncomienda(
      id,
      'Residente',
      'Retiro en conserjería',
    );
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paquete marcado como entregado'),
          backgroundColor: AppColors.green,
        ),
      );
      _fetchEncomiendas();
    }
  }

  String _formatHora(String? fechaIso) {
    if (fechaIso == null) return '';
    final dt = DateTime.parse(fechaIso).toLocal();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header y Búsqueda
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conserjería',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    'Control de accesos y recepción de paquetes',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
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
              SizedBox(
                width: 300,
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
            ],
          ),
          const SizedBox(height: 24),

          // Contenedor principal de 2 columnas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLUMNA IZQUIERDA: Visitas
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _cardBox(
                      title: 'REGISTRO RÁPIDO CON QR',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 48,
                              color: AppColors.primaryDark,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Escanear código QR del visitante',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircleAvatar(
                                  radius: 4,
                                  backgroundColor: AppColors.green,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Listo para escanear',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _cardBox(
                      title: 'Registro Manual de Visitas',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _InputTexto(
                                  'Nombre Completo',
                                  'Ej. Dante Castillo',
                                  _nombreCtrl,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tipo ID',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      value: _tipoDocSeleccionado,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        isDense: true,
                                      ),
                                      items: _tiposDoc.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _tipoDocSeleccionado = newValue!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_tipoDocSeleccionado == 'Otro') ...[
                            const SizedBox(height: 10),
                            _InputTexto(
                              'Especificar Documento',
                              'Ej. Licencia de Conducir',
                              _otroTipoCtrl,
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _InputTexto(
                                  'Número Documento',
                                  'Ej. 21.456.345-7',
                                  _numDocCtrl,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: _InputTexto(
                                  'Depto Destino',
                                  '101 - A',
                                  _deptoCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _InputTexto(
                            'Residente que autoriza (Opcional)',
                            'Buscar residente...',
                            _residenteCtrl,
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _isLoadingVisitas
                                ? null
                                : _registrarVisita,
                            icon: _isLoadingVisitas
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add, size: 16),
                            label: const Text('Registrar Visita'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _cardBox(
                      title: 'VISITAS RECIENTES HOY',
                      child: _visitas.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No hay visitas registradas',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Column(
                              children: _visitas.map((v) {
                                bool ingresado = v['horaSalida'] == null;
                                return Column(
                                  children: [
                                    _visitaRow(
                                      v['id'],
                                      _formatHora(v['horaIngreso']),
                                      v['nombreCompleto'] ?? '',
                                      v['deptoDestino'] ?? '',
                                      ingresado ? 'INGRESADO' : 'SALIDA',
                                      ingresado
                                          ? AppColors.green
                                          : AppColors.textMuted,
                                      ingresado,
                                    ),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // COLUMNA DERECHA: Paquetes
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _metricBadge(
                          'PENDIENTES',
                          '${_metricasPaquetes['pendientes'] ?? 0}',
                          AppColors.orange,
                        ),
                        const SizedBox(width: 10),
                        _metricBadge(
                          'ENTREGADOS',
                          '${_metricasPaquetes['entregadas'] ?? 0}',
                          AppColors.green,
                        ),
                        const SizedBox(width: 10),
                        _metricBadge(
                          'TOTAL REGISTRADOS',
                          '${_metricasPaquetes['total'] ?? 0}',
                          null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _cardBox(
                      title: 'Registrar Nuevo Paquete',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _InputTexto(
                                  'Destinatario / Residente',
                                  'Ej. Dante Castillo',
                                  _destinatarioCtrl,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: _InputTexto(
                                  'Depto',
                                  '101 - A',
                                  _deptoPaqueteCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _InputTexto(
                                  'Empresa / Courier',
                                  'Ej. Chilexpress, Starken...',
                                  _courierCtrl,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InputTexto(
                                  'Nº Seguimiento / Tracking',
                                  'Opcional...',
                                  _trackingCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _isLoadingPaquetes
                                ? null
                                : _registrarPaquete,
                            icon: _isLoadingPaquetes
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 16,
                                  ),
                            label: const Text('Registrar Paquete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _cardBox(
                      title: 'CONTROL DE PAQUETES RECIBIDOS',
                      child: _encomiendas.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No hay encomiendas registradas',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Column(
                              children: _encomiendas.map((p) {
                                final bool pendiente =
                                    (p['estado'] ?? '') == 'EN_CONSERJERIA';
                                return Column(
                                  children: [
                                    _paqueteRow(
                                      p['id'],
                                      p['destinatarioNombre'] ?? '',
                                      p['deptoDestino'] ?? '',
                                      p['courier'] ?? 'Paquete',
                                      pendiente ? 'PENDIENTE' : 'ENTREGADO',
                                      pendiente
                                          ? AppColors.orange
                                          : AppColors.green,
                                      pendiente,
                                    ),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              fontSize: 12,
              letterSpacing: 0.5,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _metricBadge(String label, String value, Color? dotColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                if (dotColor != null)
                  CircleAvatar(radius: 3, backgroundColor: dotColor),
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

  Widget _visitaRow(
    int id,
    String hora,
    String nombre,
    String depto,
    String estado,
    Color color,
    bool ingresado,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            hora,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              nombre,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Text(
            depto,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 14),
          Chip(
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (ingresado) ...[
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _marcarSalida(id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(50, 26),
              ),
              child: const Text(
                'Dar Salida',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _paqueteRow(
    int id,
    String dest,
    String depto,
    String tipo,
    String estado,
    Color color,
    bool isPendiente,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dest,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Text(
            depto,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 10),
          Text(
            tipo,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 10),
          Chip(
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 10),
          isPendiente
              ? ElevatedButton(
                  onPressed: () => _entregarPaquete(id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    minimumSize: const Size(60, 26),
                  ),
                  child: const Text(
                    'Entregar',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                )
              : const Text(
                  'Entregado',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
        ],
      ),
    );
  }
}

class _InputTexto extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  const _InputTexto(this.label, this.hint, this.controller);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
