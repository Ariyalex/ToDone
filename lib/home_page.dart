import 'package:flutter/material.dart';
import 'package:to_do_list/to_do_list.dart';
import 'package:to_do_list/jadwal.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

  Future<void> _requestPermissions() async {
    // Request notification permissions
    final status = await Permission.notification.request();
    if (status.isGranted) {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        // Handle notification launch
      }
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      if (granted == null || !granted) {
        // Handle permission not granted
      }
    } else {
      // Handle permission not granted
    }
  }

  Future<void> _requestScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.request();
    if (!status.isGranted) {
      // Handle permission not granted
    }
  }

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _requestScheduleExactAlarmPermission();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: const <Widget>[
          ToDoList(),
          JadwalPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          _buildBottomNavigationBarItem(Icons.list, 'To Do', 0),
          _buildBottomNavigationBarItem(Icons.calendar_today, 'Jadwal', 1),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
    IconData icon, String label, int index) {
      return BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _selectedIndex == index ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _selectedIndex == index ? Colors.deepPurple : Colors.grey,
          ),
        ),
        label: label,
      );
    }
}

