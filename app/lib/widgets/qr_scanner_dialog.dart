import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/theme/app_colors.dart';

class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
  final MobileScannerController _controller = MobileScannerController();

  bool _procesando = false;
  String? _error;

  void _procesarCodigo(String? codigo) {
    if (_procesando || codigo == null || codigo.trim().isEmpty) {
      return;
    }

    setState(() {
      _procesando = true;
      _error = null;
    });

    try {
      final data = jsonDecode(codigo);

      if (data is! Map<String, dynamic>) {
        throw const FormatException('El QR no tiene un formato válido');
      }

      final nombre = '${data['nombreCompleto'] ?? ''}'.trim();
      final tipoDocumento = '${data['tipoDocumento'] ?? 'RUT'}'.trim();
      final numeroDocumento = '${data['numeroDocumento'] ?? ''}'.trim();
      final departamento = '${data['deptoDestino'] ?? ''}'.trim();
      final residente = '${data['residenteQueAutoriza'] ?? ''}'.trim();

      if (nombre.isEmpty || numeroDocumento.isEmpty || departamento.isEmpty) {
        throw const FormatException(
          'El QR no contiene todos los datos necesarios',
        );
      }

      Navigator.of(context).pop(
        QrVisitaData(
          nombreCompleto: nombre,
          tipoDocumento: tipoDocumento,
          numeroDocumento: numeroDocumento,
          deptoDestino: departamento,
          residenteQueAutoriza: residente,
        ),
      );
    } catch (_) {
      setState(() {
        _procesando = false;
        _error = 'El QR no corresponde a un visitante válido de ConserTech.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Escanear QR del visitante',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _controller,
                              onDetect: (capture) {
                                if (capture.barcodes.isEmpty) return;

                                final codigo = capture.barcodes.first.rawValue;

                                _procesarCodigo(codigo);
                              },
                            ),
                            Center(
                              child: Container(
                                width: 230,
                                height: 230,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            if (_procesando)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ubica el código QR dentro del recuadro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        _controller.toggleTorch();
                      },
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Linterna'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrVisitaData {
  final String nombreCompleto;
  final String tipoDocumento;
  final String numeroDocumento;
  final String deptoDestino;
  final String residenteQueAutoriza;

  const QrVisitaData({
    required this.nombreCompleto,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.deptoDestino,
    required this.residenteQueAutoriza,
  });
}
