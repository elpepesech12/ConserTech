import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class EstacionamientosScreen extends StatelessWidget {
  const EstacionamientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estacionamientos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const Text(
            'Control de ocupación y asignaciones por edificio',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Métricas superiores oscuras (estilo ConserTech)
          Row(
            children: [
              _metricDark('TOTAL ESTACIONAMIENTOS', '120', null, AppColors.cardDark),
              const SizedBox(width: 12),
              _metricDark('DISPONIBLES', '45', AppColors.green, AppColors.primaryDark),
              const SizedBox(width: 12),
              _metricDark('OCUPADOS', '68', AppColors.red, AppColors.primaryDark),
              const SizedBox(width: 12),
              _metricDark('RESERVADOS', '7', AppColors.orange, AppColors.primaryDark),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain),
                    ),
                    Row(
                      children: const [
                        CircleAvatar(radius: 4, backgroundColor: AppColors.green),
                        SizedBox(width: 4),
                        Text('Disponible  ', style: TextStyle(fontSize: 11)),
                        CircleAvatar(radius: 4, backgroundColor: AppColors.red),
                        SizedBox(width: 4),
                        Text('Ocupado  ', style: TextStyle(fontSize: 11)),
                        CircleAvatar(radius: 4, backgroundColor: AppColors.orange),
                        SizedBox(width: 4),
                        Text('Reservado', style: TextStyle(fontSize: 11)),
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
                        ['01', '02', '03', '04', '05', '06'],
                        [AppColors.red, AppColors.green, AppColors.green, AppColors.orange, AppColors.red, AppColors.green],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _edificioBox(
                        'EDIFICIO 101-B',
                        ['11', '12', '13', '14', '15', '16'],
                        [AppColors.green, AppColors.orange, AppColors.orange, AppColors.red, AppColors.green, AppColors.green],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _edificioBox(
                        'EDIFICIO 204-A',
                        ['21', '22', '23', '24', '25', '26'],
                        [AppColors.red, AppColors.red, AppColors.green, AppColors.green, AppColors.orange, AppColors.red],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _edificioBox(
                        'EDIFICIO 204-B',
                        ['31', '32', '33', '34', '35', '36'],
                        [AppColors.green, AppColors.green, AppColors.red, AppColors.green, AppColors.red, AppColors.orange],
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
                child: const Icon(Icons.filter_list, size: 18, color: AppColors.textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    hintText: 'Buscar residente o RUT...',
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
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Asignar Estacionamiento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  children: const [
                    _TH('ESTACIONAMIENTO'),
                    _TH('EDIFICIO'),
                    _TH('RESIDENTE'),
                    _TH('RUT'),
                    _TH('ESTADO'),
                    _TH('FECHA ASIGNACIÓN'),
                  ],
                ),
                _row('101', '101 - A', 'Dante Castillo', '21.456.345-7', 'Ocupado', AppColors.red, '04 Sep 2026'),
                _row('104', '101 - A', 'Maximiliano Allendes', '19.876.543-2', 'Reservado', AppColors.orange, '08 Sep 2026'),
                _row('204', '204 - B', 'Christine Brooks', '20.123.456-9', 'Disponible', AppColors.green, '12 Sep 2026'),
                _row('208', '204 - B', 'Alvaro Sanhueza', '18.345.987-K', 'Ocupado', AppColors.red, '15 Sep 2026'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TableRow _row(
    String est,
    String edif,
    String res,
    String rut,
    String estado,
    Color color,
    String fecha,
  ) {
    return TableRow(
      children: [
        _TD(est, isBold: true),
        _TD(edif),
        _TD(res),
        _TD(rut),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Chip(
            label: Text(
              estado,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            backgroundColor: color.withOpacity(0.1),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        _TD(fecha),
      ],
    );
  }

  Widget _metricDark(String label, String value, Color? dotColor, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
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
                border: Border.all(color: colors[i], width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                slots[i],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textMain),
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