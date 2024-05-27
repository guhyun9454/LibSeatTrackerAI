import 'package:flutter/material.dart';
import 'user_id_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seat Reservation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NanumGothic', // NanumGothic 폰트 설정
      ),
      locale: Locale('ko', 'KR'), // 한국어 로케일 설정
      home: UserIdScreen(), // 초기 화면을 UserIdScreen으로 설정합니다.
    );
  }
}
