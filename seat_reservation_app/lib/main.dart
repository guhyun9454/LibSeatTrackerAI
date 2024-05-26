import 'package:flutter/material.dart';
import 'user_id_screen.dart';
import 'main_page.dart';
import 'user_page.dart';
import 'reading_room_status_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => UserIdScreen(),
        '/main': (context) => MainPage(),
        '/user': (context) => UserPage(
              userId: 0,
              department: '',
              name: '',
              warningCount: 0,
            ),
        '/readingroom': (context) => ReadingRoomStatusScreen(userId: 0),
      },
    );
  }
}
