import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalData {
  static List<Map<String, String>> schedules = [];

  static Future<void> addSchedule(
      String day, String startTime, String endTime, String activity) async {
    final prefs = await SharedPreferences.getInstance();
    final String? schedulesString = prefs.getString('schedules');
    if (schedulesString != null) {
      schedules = (json.decode(schedulesString) as List)
          .map((item) => Map<String, String>.from(item))
          .toList();
    }
    schedules.add({
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'activity': activity,
    });
    await prefs.setString('schedules', json.encode(schedules));
  }

  static Future<void> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? schedulesString = prefs.getString('schedules');
    if (schedulesString != null) {
      schedules = (json.decode(schedulesString) as List)
          .map((item) => Map<String, String>.from(item))
          .toList();
    }
  }

  static Future<void> saveSchedules(
      List<Map<String, String>> updatedSchedules) async {
    final prefs = await SharedPreferences.getInstance();
    schedules = updatedSchedules;
    await prefs.setString('schedules', json.encode(schedules));
  }
}
