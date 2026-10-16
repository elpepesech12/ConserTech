import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    Text('Resumen operativo y flujo de accesos', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              // Tarjeta Estacionamientos de invitados
              Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estacionamientos de invitados',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _statItem(AppColors.green, 'Estacionamientos disp.', '45'),
                    const SizedBox(height: 8),
                    _statItem(AppColors.red, 'Estacionamientos ocup.', '68'),
                    const SizedBox(height: 8),
                    _statItem(AppColors.orange, 'Estacionamientos reserv.', '7'),
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
                    const Text('Visitas últimos 30 días', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textMain)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
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

          // Buscador y Tabla de residentes
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
                    hintText: 'Search...',
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
          ),
          const SizedBox(height: 14),

          // Tabla
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
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  ),
                  children: const [
                    _TH('RUT'),
                    _TH('NOMBRE'),
                    _TH('APELLIDO'),
                    _TH('TELÉFONO'),
                    _TH('EDIFICIO'),
                    _TH('ESTACIONAMIENTO'),
                  ],
                ),
                const TableRow(
                  children: [
                    _TD('21.456.345-7'),
                    _TD('Dante'),
                    _TD('Castillo'),
                    _TD('101'),
                    _TD('101 - A'),
                    _TD('01'),
                  ],
                ),
                const TableRow(
                  children: [
                    _TD('21.456.345-7'),
                    _TD('Maximiliano'),
                    _TD('Allendes'),
                    _TD('204'),
                    _TD('204 - B'),
                    _TD('04'),
                  ],
                ),
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
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
        Text(day, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textMain)),
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
      child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textMain)),
    );
  }
}