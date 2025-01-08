import 'package:flutter/material.dart';
import 'package:to_do_list/data/jadwal_data.dart'; // Adjust the import path as necessary

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add GlobalKey
  List<Map<String, String>> schedules = [];
  bool isMultiSelectMode = false;
  Set<int> selectedIndexes = {}; // Track selected items

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

  void _deleteSelectedItems() async {
    setState(() {
      schedules = schedules
          .asMap()
          .entries
          .where((entry) => !selectedIndexes.contains(entry.key))
          .map((entry) => entry.value)
          .toList();
      selectedIndexes.clear();
      isMultiSelectMode = false;
    });
    await JadwalData.saveSchedules(schedules); // Save the updated schedules
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
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
          if (isMultiSelectMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteSelectedItems,
            ),
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
              size: 34,
            ),
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Use GlobalKey to open the drawer
          },
        ),
      ),
      drawer: Drawer(
        width: 250, // Set the width of the Drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            SizedBox(
              height: 165,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 97, 190, 100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ToDone',
                      style: TextStyle(
                        color: Color(0xFFF5EFFF),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Buat To Do List dan Jadwalmu',
                      style: TextStyle(
                        color: Color(0xFFF5EFFF),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text("Cara penggunaan Jadwal:"),
              subtitle: Text(
                "1. Tambahkan jadwal dengan menekan tombol +.\n"
                "2. Ketuk tahan jadwal untuk memilih jadwal yang akan dihapus.\n"
                "3. Hapus jadwal yang dipilih dengan menekan ikon tempat sampah.",
              ),
            ),
          ],
        ),
      ),
      body: schedules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                      image: AssetImage('images/jadwal_vector.png'),
                      height: 300),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        "Belum ada jadwal yang ditambahkan, tambahkan jadwal lewat tombol dibawah atau tombol '+' di pojok kanan atas.\n cara penggunaan jadwal ada di menu kiri atas.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddJadwal()),
                      ).then((_) => _loadSchedules());
                    },
                    child: const Text('Tambahkan Jadwal',
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width),
                  child: DataTable(
                    columnSpacing: 10.0, // Adjust the gap between columns
                    columns: const [
                      DataColumn(
                        label: Center(
                          child: Text(
                            'HARI',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'WAKTU',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'NAMA KEGIATAN',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    rows: schedules.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> schedule = entry.value;
                      bool isSelected = selectedIndexes.contains(index);
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (isSelected) {
                              return Colors.grey[
                                  300]; // Change background color for selected items
                            }
                            return null; // Use default color for unselected items
                          },
                        ),
                        cells: [
                          DataCell(
                            Container(
                              width: 55, // Set a fixed width for the day column
                              child: Wrap(
                                children: [Text(schedule['day']!)],
                              ),
                            ),
                            onTap: () {
                              if (isMultiSelectMode) {
                                setState(() {
                                  if (isSelected) {
                                    selectedIndexes.remove(index);
                                    if (selectedIndexes.isEmpty) {
                                      isMultiSelectMode = false;
                                    }
                                  } else {
                                    selectedIndexes.add(index);
                                  }
                                });
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                isMultiSelectMode = true;
                                selectedIndexes.add(index);
                              });
                            },
                          ),
                          DataCell(
                            Container(
                              width:
                                  130, // Set a fixed width for the time column
                              child: Wrap(
                                children: [
                                  Text(
                                      '${schedule['startTime']} - ${schedule['endTime']}')
                                ],
                              ),
                            ),
                            onTap: () {
                              if (isMultiSelectMode) {
                                setState(() {
                                  if (isSelected) {
                                    selectedIndexes.remove(index);
                                    if (selectedIndexes.isEmpty) {
                                      isMultiSelectMode = false;
                                    }
                                  } else {
                                    selectedIndexes.add(index);
                                  }
                                });
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                isMultiSelectMode = true;
                                selectedIndexes.add(index);
                              });
                            },
                          ),
                          DataCell(
                            Container(
                              width: 180,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Wrap(
                                  children: [Text(schedule['activity']!)],
                                ),
                              ),
                            ),
                            onTap: () {
                              if (isMultiSelectMode) {
                                setState(() {
                                  if (isSelected) {
                                    selectedIndexes.remove(index);
                                    if (selectedIndexes.isEmpty) {
                                      isMultiSelectMode = false;
                                    }
                                  } else {
                                    selectedIndexes.add(index);
                                  }
                                });
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                isMultiSelectMode = true;
                                selectedIndexes.add(index);
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                          onPressed: () => _selectStartTime(context),
                          child: const Text('Pilih Jam Awal'),
                        ),
                      ),
                      if (_startTime != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Jam Awal: ${_startTime!.format(context)}',
                              style: const TextStyle(fontSize: 18)),
                        ),
                    ],
                  ),
                  const SizedBox(width: 50),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                          onPressed: () => _selectEndTime(context),
                          child: const Text('Pilih Jam Akhir'),
                        ),
                      ),
                      if (_endTime != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Jam Akhir: ${_endTime!.format(context)}',
                              style: const TextStyle(fontSize: 18)),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_startTime != null && _endTime != null)
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          _saveSchedule().then((_) {
                            Navigator.pop(context);
                          });
                        }
                      }
                    : null,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
