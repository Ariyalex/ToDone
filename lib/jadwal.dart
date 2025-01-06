import 'package:flutter/material.dart';
import 'package:to_do_list/data/jadwal_data.dart'; // Adjust the import path as necessary

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<Map<String, String>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    await JadwalData.loadSchedules();
    setState(() {
      schedules = JadwalData.schedules;
      _sortSchedulesByDay();
    });
  }

  void _sortSchedulesByDay() {
    schedules.sort((a, b) {
      const daysOfWeek = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      int dayComparison = daysOfWeek
          .indexOf(a['day']!)
          .compareTo(daysOfWeek.indexOf(b['day']!));
      if (dayComparison != 0) {
        return dayComparison;
      } else {
        return a['startTime']!.compareTo(b['startTime']!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
            255, 97, 190, 100), // Adjust this to match home_screen.dart
        title: const Text(
          'Jadwal',
          style: TextStyle(
            color: Color(0xFFF5EFFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddJadwal()),
              ).then((_) => _loadSchedules());
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
      body: schedules.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddJadwal()),
                  ).then((_) => _loadSchedules());
                },
                child: const Text('Tambahkan Jadwal'),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Hari')),
                    DataColumn(label: Text('Waktu')),
                    DataColumn(label: Text('Nama Kegiatan')),
                  ],
                  rows: schedules.map((schedule) {
                    return DataRow(
                      cells: [
                        DataCell(Text(schedule['day']!)),
                        DataCell(Text(
                            '${schedule['startTime']} - ${schedule['endTime']}')),
                        DataCell(Text(schedule['activity']!)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}

class AddJadwal extends StatefulWidget {
  const AddJadwal({super.key});

  @override
  _AddJadwalState createState() => _AddJadwalState();
}

class _AddJadwalState extends State<AddJadwal> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _activity;

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveSchedule() async {
    await JadwalData.addSchedule(
      _selectedDay!,
      _startTime!.format(context),
      _endTime!.format(context),
      _activity!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
            255, 97, 190, 100), // Adjust this to match home_screen.dart
        title: const Text(
          'Tambah Jadwal',
          style: TextStyle(
            color: Color(0xFFF5EFFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Kegiatan',
                ),
                onChanged: (value) {
                  _activity = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan nama kegiatan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Hari',
                ),
                items: const [
                  DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                  DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                  DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                  DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                  DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
                  DropdownMenuItem(value: 'Sabtu', child: Text('Sabtu')),
                  DropdownMenuItem(value: 'Minggu', child: Text('Minggu')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap pilih hari';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_startTime != null)
                          Text('Jam Awal: ${_startTime!.format(context)}',
                              style: const TextStyle(fontSize: 18)),
                        FilledButton(
                          onPressed: () => _selectStartTime(context),
                          child: const Text('Pilih Jam Awal'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_endTime != null)
                          Text('Jam Akhir: ${_endTime!.format(context)}',
                              style: const TextStyle(fontSize: 18)),
                        FilledButton(
                          onPressed: () => _selectEndTime(context),
                          child: const Text('Pilih Jam Akhir'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveSchedule().then((_) {
                      Navigator.pop(context);
                    });
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
