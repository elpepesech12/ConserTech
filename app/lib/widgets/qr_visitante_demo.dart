import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/theme/app_colors.dart';

class QrVisitanteDemo extends StatelessWidget {
  const QrVisitanteDemo({super.key});

  String get _contenidoQr {
    return jsonEncode({
      'nombreCompleto': 'Juan Pérez',
      'tipoDocumento': 'RUT',
      'numeroDocumento': '12.345.678-9',
      'deptoDestino': '101',
      'residenteQueAutoriza': 'Carlos Mendoza',
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('QR de prueba'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: _contenidoQr,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 14),
            const Text(
              'Escanea este código desde otro dispositivo o muéstralo en pantalla para probar el registro automático.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
