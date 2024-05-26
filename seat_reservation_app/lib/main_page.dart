import 'package:flutter/material.dart';
import 'user_page.dart';
import 'reading_room_status_screen.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPage(
                      userId: 1234,
                      department: '인공지능학과',
                      name: '홍길동',
                      warningCount: 0,
                    ),
                  ),
                );
              },
              child: Text('Go to User Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingRoomStatusScreen(userId: 1234),
                  ),
                );
              },
              child: Text('Go to Reading Room'),
            ),
          ],
        ),
      ),
    );
  }
}
