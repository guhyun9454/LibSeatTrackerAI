import 'package:flutter/material.dart';
import 'user_id_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserIdScreen(),
    );
  }
}
