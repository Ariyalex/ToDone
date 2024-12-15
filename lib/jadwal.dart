import 'package:flutter/material.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 97, 190, 100), // Adjust this to match home_screen.dart
        title: const Text(
          'Jadwal',
          style: TextStyle(
            color: Color(0xFFF5EFFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Waktu')),
              DataColumn(label: Text('Senin')),
              DataColumn(label: Text('Selasa')),
              DataColumn(label: Text('Rabu')),
              DataColumn(label: Text('Kamis')),
              DataColumn(label: Text('Jumat')),
              DataColumn(label: Text('Sabtu')),
              DataColumn(label: Text('Minggu')),
            ],
            rows: List<DataRow>.generate(
              24,
              (index) => DataRow(
                cells: [
                  DataCell(Text('$index:00 - ${index + 1}:00')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}