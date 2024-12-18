import 'package:flutter/material.dart';
import 'package:to_do_list/data/list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AddList(),
    );
  }
}

class AddList extends StatefulWidget {
  const AddList ({super.key});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  final TextEditingController _controller = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate; // Allow selectedDate to be null
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    _controller.addListener(_checkIfEmpty);
    _initializeNotifications();
    _requestScheduleExactAlarmPermission();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveBackgroundNotificationResponse: (response) {debugPrint('Notification clicked');});
  }

  Future<void> _scheduleNotification(String title, DateTime dateTime) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Pengingat ToDo',
        title,
        tz.TZDateTime.from(dateTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id', 'Your Channel Name',
            channelDescription: 'Your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker'
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      );
      debugPrint('Notifikasi dijadwalkan pada $dateTime dengan judul: $title');
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi: $e');
    }
  }

  Future<void> _requestScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.request();
    if (!status.isGranted) {
      // Handle permission not granted
      debugPrint('Exact alarm permission not granted');
    }
  }

  void _checkIfEmpty() {
    setState(() {
      _isButtonDisabled = _controller.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA294F9),
        leading: 
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        title: const Text(
            'ToDone',
            style: TextStyle(
              color: Color(0xFFF5EFFF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Masukkan To Do List',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => _selectDate(),
                      child: const Text('Pilih Tanggal'),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      getFormattedDate(_selectedDate),
                      style: const TextStyle(fontSize: 20),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FilledButton(
                  onPressed: () => _pickTime(),
                   child: const Text('Pilih Waktu'),
                ),
                const SizedBox(width: 20),
                Text(
                  _selectedTime == null ? 'Waktu tidak dipilih' : _selectedTime!.format(context),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  
                  onPressed: _isButtonDisabled ? null : () {
                    final newItem = Todolist(
                      _controller.text, 
                      date: _selectedDate?.toIso8601String().split('T').first,
                      time: _selectedTime?.format(context),
                    );
                    if (_selectedDate != null && _selectedTime != null) {
                      final scheduledDate = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );
                      if (scheduledDate.isAfter(DateTime.now())) {
                        _scheduleNotification(_controller.text, scheduledDate);
                      } else {
                        debugPrint('Scheduled date must be in the future');
                      }
                    }
                    Navigator.pop(context, newItem); // Pass new item back to HomeScreen
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String getFormattedDate(DateTime? date) {
    if (date == null) return 'Tanggal belum dipilih';
    return "${date.day}-${date.month}-${date.year}";
  }
}

@pragma('vm:entry-point')
Future<void> _alarmCallback() async {
  const androidDetails = AndroidNotificationDetails(
    'your_channel_id',
    'Your Channel Name',
    channelDescription: 'Your channel description',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Pengingat ToDo',
    'Waktunya untuk melakukan ToDo',
    notificationDetails,
  );
}

