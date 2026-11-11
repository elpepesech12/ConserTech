import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8081/api';

  // --- VISITAS ---
  static Future<List<dynamic>> getVisitas() async {
    final res = await http.get(Uri.parse('$baseUrl/visitas'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<bool> registrarVisita(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/visitas/ingreso'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> marcarSalidaVisita(int id) async {
    final res = await http.put(Uri.parse('$baseUrl/visitas/$id/salida'));
    return res.statusCode == 200;
  }

  // --- ESTACIONAMIENTOS ---
  static Future<List<dynamic>> getEstacionamientos() async {
    final res = await http.get(Uri.parse('$baseUrl/estacionamientos'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>> getMetricasEstacionamientos() async {
    final res = await http.get(Uri.parse('$baseUrl/estacionamientos/metricas'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'total': 0, 'disponibles': 0, 'ocupados': 0, 'mantencion': 0};
  }

  static Future<bool> cambiarEstadoEstacionamiento(
    int id,
    String nuevoEstado,
  ) async {
    final res = await http.put(
      Uri.parse(
        '$baseUrl/estacionamientos/$id/estado?nuevoEstado=$nuevoEstado',
      ),
    );
    return res.statusCode == 200;
  }

  // --- RESIDENTES Y DIRECTORIO ---
  static Future<List<dynamic>> getResidentes() async {
    final res = await http.get(Uri.parse('$baseUrl/residentes'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<List<dynamic>> buscarResidentes(String query) async {
    if (query.trim().isEmpty) return getResidentes();
    final res = await http.get(
      Uri.parse('$baseUrl/residentes/buscar?query=$query'),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  // --- ENCOMIENDAS (PAQUETES) ---
  static Future<List<dynamic>> getEncomiendas() async {
    final res = await http.get(Uri.parse('$baseUrl/encomiendas'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return [];
  }

  static Future<Map<String, dynamic>> getMetricasEncomiendas() async {
    final res = await http.get(Uri.parse('$baseUrl/encomiendas/metricas'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'total': 0, 'pendientes': 0, 'entregadas': 0};
  }

  static Future<bool> registrarEncomienda(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/encomiendas/recepcion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> entregarEncomienda(
    int id,
    String retiradoPor,
    String rutRetiro,
  ) async {
    final res = await http.put(
      Uri.parse(
        '$baseUrl/encomiendas/$id/entregar?retiradoPor=$retiradoPor&rutRetiro=$rutRetiro',
      ),
    );
    return res.statusCode == 200;
  }

  // --- ADMINISTRACIÓN DE USUARIOS ---

  static Future<List<dynamic>> getUsuarios() async {
    final res = await http.get(Uri.parse('$baseUrl/usuarios'));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<bool> cambiarEstadoUsuario(int id, bool activo) async {
    final uri = Uri.parse('$baseUrl/usuarios/$id/estado')
        .replace(queryParameters: {'activo': activo.toString()});

    final res = await http.put(uri);

    return res.statusCode == 200;
  }

  // --- BITÁCORA ---

  static Future<List<dynamic>> getBitacora() async {
    final res = await http.get(Uri.parse('$baseUrl/bitacora'));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }
}
