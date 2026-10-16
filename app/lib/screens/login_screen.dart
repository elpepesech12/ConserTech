import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@admin.com');
  final _passCtrl = TextEditingController(text: '123456');
  bool _rememberMe = true;
  bool _obscurePass = true;
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final success = await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    setState(() => _isLoading = false);
    if (mounted && success) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apartment_rounded, color: AppColors.primaryDark, size: 32),
                  SizedBox(width: 10),
                  Text(
                    'CONSERTECH',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'SISTEMA DE CONSERJERÍA INTELIGENTE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 28),

              // Contenedor dual estilo Figma
              Container(
                constraints: const BoxConstraints(maxWidth: 860),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Lado izquierdo: Inicio de sesión
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(36.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Inicio de Sesión',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ingrese sus credenciales para iniciar su turno',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 22),
                              const Text('RUT o Correo Electrónico', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _emailCtrl,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person_outline, size: 18),
                                  hintText: 'ejemplo@admin.com',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.borderLight),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _passCtrl,
                                obscureText: _obscurePass,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 18),
                                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.borderLight),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.primaryDark,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                  ),
                                  const Text('Recordar en este equipo', style: TextStyle(fontSize: 12, color: AppColors.textMain)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Iniciar Turno', style: TextStyle(fontWeight: FontWeight.bold)),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 18),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Lado derecho: Contexto de Turno
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(19),
                              bottomRight: Radius.circular(19),
                            ),
                          ),
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contexto de Turno',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Información de entrega del turno anterior para el conserje entrante.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const Divider(color: Colors.white24, height: 30),
                              _buildTurnoRow(Icons.schedule, 'TURNO ACTUAL', 'Nocturno (22:00 - 06:00)'),
                              const SizedBox(height: 18),
                              _buildTurnoRow(Icons.badge_outlined, 'ÚLTIMO CONSERJE DE TURNO', 'Carlos Pérez R.'),
                              const SizedBox(height: 18),
                              _buildTurnoRow(Icons.check_circle_outline, 'ÚLTIMA SESIÓN CERRADA', '13/09/2026 - 22:05 hrs'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.orange, size: 20),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Recuerde verificar el estado de los estacionamientos en el panel principal al iniciar sesión.',
                                        style: TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CONSERTECH v1.0 — Gestión de Conserjería Inteligente',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnoRow(IconData icon, String label, String val) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: Colors.white10,
          child: Icon(icon, color: Colors.white70, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 0.8)),
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
}