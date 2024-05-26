import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final int userId;
  final String department;
  final String name;
  final int warningCount;

  UserPage(
      {required this.userId,
      required this.department,
      required this.name,
      required this.warningCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: $userId', style: TextStyle(fontSize: 18)),
            Text('Department: $department', style: TextStyle(fontSize: 18)),
            Text('Name: $name', style: TextStyle(fontSize: 18)),
            Text('Warning Count: $warningCount',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/main');
              },
              child: Text('Go to Main Page'),
            ),
          ],
        ),
      ),
    );
  }
}
