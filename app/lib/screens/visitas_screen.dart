import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/api_service.dart';

class VisitasScreen extends StatefulWidget {
  const VisitasScreen({super.key});

  @override
  State<VisitasScreen> createState() => _VisitasScreenState();
}

class _VisitasScreenState extends State<VisitasScreen> {
  List<dynamic> _visitas = [];
  bool _isLoadingVisitas = false;

  final _nombreCtrl = TextEditingController();
  final _numDocCtrl = TextEditingController();
  final _deptoCtrl = TextEditingController();
  final _residenteCtrl = TextEditingController();
  final _otroTipoCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _tipoDocSeleccionado = 'RUT';
  String _metodoIngreso = 'MANUAL';
  final List<String> _tiposDoc = ['RUT', 'Pasaporte', 'DNI Extranjero', 'Otro'];

  List<dynamic> _encomiendas = [];
  Map<String, dynamic> _metricasPaquetes = {
    'total': 0,
    'pendientes': 0,
    'entregadas': 0,
  };
  bool _isLoadingPaquetes = false;
  bool _isRefreshing = false;

  final _destinatarioCtrl = TextEditingController();
  final _deptoPaqueteCtrl = TextEditingController();
  final _courierCtrl = TextEditingController();
  final _trackingCtrl = TextEditingController();

  Timer? _refreshTimer;
  DateTime? _ultimaActualizacion;

  // Visitantes de demostración para el QR propio de ConserTech.
  final List<Map<String, String>> _qrDemo = const [
    {
      'nombreCompleto': 'Juan Pérez González',
      'tipoDocumento': 'RUT',
      'numeroDocumento': '12.345.678-9',
      'deptoDestino': '101',
      'residenteQueAutoriza': 'Carlos Mendoza',
    },
    {
      'nombreCompleto': 'María Soto Lagos',
      'tipoDocumento': 'RUT',
      'numeroDocumento': '16.789.123-4',
      'deptoDestino': '102',
      'residenteQueAutoriza': 'Camila Silva',
    },
    {
      'nombreCompleto': 'Pedro Ramírez Díaz',
      'tipoDocumento': 'Pasaporte',
      'numeroDocumento': 'AB123456',
      'deptoDestino': '201',
      'residenteQueAutoriza': 'Rodrigo Pérez',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarTodo();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _cargarTodo(esRefresco: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _nombreCtrl.dispose();
    _numDocCtrl.dispose();
    _deptoCtrl.dispose();
    _residenteCtrl.dispose();
    _otroTipoCtrl.dispose();
    _searchCtrl.dispose();
    _destinatarioCtrl.dispose();
    _deptoPaqueteCtrl.dispose();
    _courierCtrl.dispose();
    _trackingCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarTodo({bool esRefresco = false}) async {
    if (_isRefreshing) return;

    if (mounted) {
      setState(() => _isRefreshing = true);
    }

    await Future.wait([_fetchVisitas(), _fetchEncomiendas()]);

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;
      _ultimaActualizacion = DateTime.now();
    });
  }

  Future<void> _fetchVisitas() async {
    try {
      final list = await ApiService.getVisitas();
      if (mounted) setState(() => _visitas = list);
    } catch (e) {
      debugPrint('Error cargando visitas: $e');
    }
  }

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
      debugPrint('Error cargando encomiendas: $e');
    }
  }

  List<dynamic> get _visitasFiltradas {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _visitas;

    return _visitas.where((v) {
      final nombre = '${v['nombreCompleto'] ?? ''}'.toLowerCase();
      final depto = '${v['deptoDestino'] ?? ''}'.toLowerCase();
      final doc = '${v['numeroDocumento'] ?? ''}'.toLowerCase();
      final residente = '${v['residenteQueAutoriza'] ?? ''}'.toLowerCase();
      return nombre.contains(q) ||
          depto.contains(q) ||
          doc.contains(q) ||
          residente.contains(q);
    }).toList();
  }

  List<dynamic> get _encomiendasFiltradas {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _encomiendas;

    return _encomiendas.where((p) {
      final dest = '${p['destinatarioNombre'] ?? ''}'.toLowerCase();
      final depto = '${p['deptoDestino'] ?? ''}'.toLowerCase();
      final courier = '${p['courier'] ?? ''}'.toLowerCase();
      final tracking = '${p['codigoSeguimiento'] ?? ''}'.toLowerCase();
      return dest.contains(q) ||
          depto.contains(q) ||
          courier.contains(q) ||
          tracking.contains(q);
    }).toList();
  }

  String _horaActualizacion() {
    if (_ultimaActualizacion == null) return 'Sin actualizar';
    final hora = _ultimaActualizacion!.hour.toString().padLeft(2, '0');
    final minuto = _ultimaActualizacion!.minute.toString().padLeft(2, '0');
    return 'Actualizado a las $hora:$minuto';
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
      'metodoIngreso': _metodoIngreso,
    };

    final ok = await ApiService.registrarVisita(body);
    if (mounted) {
      if (ok) {
        _limpiarFormularioVisita();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _metodoIngreso == 'QR_CEDULA'
                  ? 'Visita registrada mediante QR'
                  : 'Visita registrada exitosamente',
            ),
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

  void _limpiarFormularioVisita() {
    _nombreCtrl.clear();
    _numDocCtrl.clear();
    _deptoCtrl.clear();
    _residenteCtrl.clear();
    _otroTipoCtrl.clear();
    setState(() {
      _tipoDocSeleccionado = 'RUT';
      _metodoIngreso = 'MANUAL';
    });
  }

  Future<void> _marcarSalida(dynamic id) async {
    final parsed = id is int ? id : int.tryParse('$id');
    if (parsed == null) return;

    final ok = await ApiService.marcarSalidaVisita(parsed);
    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salida registrada'),
            backgroundColor: AppColors.green,
          ),
        );
      }
      _fetchVisitas();
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
            content: Text('Paquete ingresado como pendiente de retiro'),
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

  Future<void> _entregarPaquete(dynamic id) async {
    final parsed = id is int ? id : int.tryParse('$id');
    if (parsed == null) return;

    final retiradoPorCtrl = TextEditingController();
    final rutRetiroCtrl = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Registrar entrega',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresa los datos de la persona que retira el paquete.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nombre de quien retira',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: retiradoPorCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ej. Carlos Mendoza',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'RUT de quien retira',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: rutRetiroCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ej. 18.123.456-7',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar entrega'),
            ),
          ],
        );
      },
    );

    final retiradoPor = retiradoPorCtrl.text.trim();
    final rutRetiro = rutRetiroCtrl.text.trim();
    retiradoPorCtrl.dispose();
    rutRetiroCtrl.dispose();

    if (confirmado != true) return;

    if (retiradoPor.isEmpty || rutRetiro.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar nombre y RUT de quien retira.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    final ok = await ApiService.entregarEncomienda(
      parsed,
      retiradoPor,
      rutRetiro,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paquete entregado a $retiradoPor'),
          backgroundColor: AppColors.green,
        ),
      );
      _fetchEncomiendas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al entregar el paquete'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _abrirDialogoQr() async {
    final qrCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Registro rápido con QR',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usa un QR propio de ConserTech. Formato:',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Text(
                    'Nombre|TipoDocumento|Numero|Depto|Residente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Pegar contenido del QR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: qrCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Ej. Juan Pérez|RUT|12.345.678-9|101|Carlos Mendoza',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Visitantes de prueba',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _qrDemo.map((demo) {
                    return OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _aplicarDatosQr(demo);
                      },
                      child: Text(
                        demo['nombreCompleto'] ?? 'Visitante',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final contenido = qrCtrl.text.trim();
                Navigator.pop(context);
                if (contenido.isEmpty) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('El contenido del QR está vacío'),
                      backgroundColor: AppColors.orange,
                    ),
                  );
                  return;
                }
                _procesarContenidoQr(contenido);
              },
              icon: const Icon(Icons.qr_code_scanner, size: 16),
              label: const Text('Leer QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    qrCtrl.dispose();
  }

  void _procesarContenidoQr(String contenido) {
    Map<String, String>? datos;

    final texto = contenido.trim();

    if (texto.startsWith('{')) {
      try {
        final decoded = jsonDecode(texto);
        if (decoded is Map) {
          datos = {
            'nombreCompleto': '${decoded['nombreCompleto'] ?? ''}',
            'tipoDocumento': '${decoded['tipoDocumento'] ?? 'RUT'}',
            'numeroDocumento': '${decoded['numeroDocumento'] ?? ''}',
            'deptoDestino': '${decoded['deptoDestino'] ?? ''}',
            'residenteQueAutoriza': '${decoded['residenteQueAutoriza'] ?? ''}',
          };
        }
      } catch (_) {
        datos = null;
      }
    } else {
      final partes = texto.split('|').map((e) => e.trim()).toList();
      if (partes.length >= 4) {
        datos = {
          'nombreCompleto': partes[0],
          'tipoDocumento': partes[1].isEmpty ? 'RUT' : partes[1],
          'numeroDocumento': partes[2],
          'deptoDestino': partes[3],
          'residenteQueAutoriza': partes.length > 4 ? partes[4] : '',
        };
      }
    }

    if (datos == null ||
        datos['nombreCompleto']!.isEmpty ||
        datos['numeroDocumento']!.isEmpty ||
        datos['deptoDestino']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'QR no válido. Usa Nombre|TipoDocumento|Numero|Depto|Residente',
          ),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    _aplicarDatosQr(datos);
  }

  Future<void> _aplicarDatosQr(Map<String, String> datos) async {
    final tipo = datos['tipoDocumento'] ?? 'RUT';
    final tipoNormalizado = _tiposDoc.contains(tipo) ? tipo : 'Otro';

    setState(() {
      _nombreCtrl.text = datos['nombreCompleto'] ?? '';
      _numDocCtrl.text = datos['numeroDocumento'] ?? '';
      _deptoCtrl.text = datos['deptoDestino'] ?? '';
      _residenteCtrl.text = datos['residenteQueAutoriza'] ?? '';
      _tipoDocSeleccionado = tipoNormalizado;
      _metodoIngreso = 'QR_CEDULA';
      if (tipoNormalizado == 'Otro') {
        _otroTipoCtrl.text = tipo;
      }
    });

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'QR leído correctamente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Visitante: ${datos['nombreCompleto']}'),
              const SizedBox(height: 6),
              Text(
                'Documento: ${datos['tipoDocumento']} ${datos['numeroDocumento']}',
              ),
              const SizedBox(height: 6),
              Text('Departamento: ${datos['deptoDestino']}'),
              if ((datos['residenteQueAutoriza'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('Autoriza: ${datos['residenteQueAutoriza']}'),
              ],
              const SizedBox(height: 12),
              const Text(
                '¿Deseas registrar el ingreso ahora?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Solo completar formulario'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
              child: const Text('Registrar ingreso'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _registrarVisita();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos del QR cargados en el formulario'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  String _formatHora(String? fechaIso) {
    if (fechaIso == null) return '';
    try {
      final dt = DateTime.parse(fechaIso).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic> _estadoEncomienda(String estado) {
    switch (estado.toUpperCase()) {
      case 'EN_CONSERJERIA':
        return {
          'texto': 'PENDIENTE',
          'color': AppColors.orange,
          'pendiente': true,
        };
      case 'ENTREGADO':
        return {
          'texto': 'ENTREGADO',
          'color': AppColors.green,
          'pendiente': false,
        };
      case 'DEVUELTO':
        return {
          'texto': 'DEVUELTO',
          'color': AppColors.red,
          'pendiente': false,
        };
      default:
        return {
          'texto': estado.isEmpty ? 'SIN ESTADO' : estado,
          'color': AppColors.textMuted,
          'pendiente': false,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _cargarTodo(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_isRefreshing)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Text(
                  _horaActualizacion(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
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
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      hintText: 'Buscar visita, paquete, depto o RUT...',
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _cardBox(
                        title: 'REGISTRO RÁPIDO CON QR',
                        child: InkWell(
                          onTap: _abrirDialogoQr,
                          borderRadius: BorderRadius.circular(10),
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
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
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
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _abrirDialogoQr,
                                  icon: const Icon(Icons.qr_code, size: 16),
                                  label: const Text('Leer QR de visitante'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _cardBox(
                        title: 'Registro Manual de Visitas',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_metodoIngreso == 'QR_CEDULA')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.green.withOpacity(0.4),
                                    ),
                                  ),
                                  child: const Text(
                                    'Datos cargados desde QR. Al registrar se guardará como ingreso QR.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                ),
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        child: _visitasFiltradas.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No hay visitas registradas',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Column(
                                children: _visitasFiltradas.map((v) {
                                  final bool ingresado =
                                      v['horaSalida'] == null;
                                  final metodo =
                                      '${v['metodoIngreso'] ?? 'MANUAL'}';
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
                                        metodo,
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
                        child: _encomiendasFiltradas.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No hay encomiendas registradas',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Column(
                                children: _encomiendasFiltradas.map((p) {
                                  final info = _estadoEncomienda(
                                    '${p['estado'] ?? ''}',
                                  );
                                  return Column(
                                    children: [
                                      _paqueteRow(
                                        p['id'],
                                        p['destinatarioNombre'] ?? '',
                                        p['deptoDestino'] ?? '',
                                        p['courier'] ?? 'Paquete',
                                        info['texto'] as String,
                                        info['color'] as Color,
                                        info['pendiente'] as bool,
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
    dynamic id,
    String hora,
    String nombre,
    String depto,
    String estado,
    Color color,
    bool ingresado,
    String metodo,
  ) {
    final esQr = metodo.toUpperCase().contains('QR');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            hora,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(width: 10),
          if (esQr) ...[
            const Icon(Icons.qr_code_2, size: 14, color: AppColors.primaryDark),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              nombre,
              overflow: TextOverflow.ellipsis,
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
    dynamic id,
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
              overflow: TextOverflow.ellipsis,
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
              : Text(
                  estado == 'DEVUELTO' ? 'Devuelto' : 'Entregado',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
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
