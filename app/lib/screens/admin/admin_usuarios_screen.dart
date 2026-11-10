import 'package:flutter/material.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  // Lista simulada - Aquí consumirías la lista de conserjes desde PostgreSQL
  final _conserjes = [
    {'id': 1, 'nombre': 'Juan Pérez', 'turno': 'Día', 'estado': 'Activo'},
    {'id': 2, 'nombre': 'Carlos López', 'turno': 'Noche', 'estado': 'Activo'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Conserjes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Abrir modal para registrar nuevo conserje
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _conserjes.length,
        itemBuilder: (context, index) {
          final user = _conserjes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Text(user['nombre'].toString().substring(0, 1), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(user['nombre'].toString()),
              subtitle: Text('Turno: ${user['turno']}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  // Lógica para editar o suspender cuenta
                },
                itemBuilder: (BuildContext context) {
                  return const [
                    PopupMenuItem(value: 'edit', child: Text('Editar turno')),
                    PopupMenuItem(value: 'suspend', child: Text('Suspender acceso', style: TextStyle(color: Colors.red))),
                  ];
                },
              ),
            ),
          );
        },
      ),
    );
  }
}