import 'package:flutter/material.dart';
import 'seat_status_screen.dart';
import 'package:flutter/services.dart';

class UserIdScreen extends StatefulWidget {
  @override
  _UserIdScreenState createState() => _UserIdScreenState();
}

class _UserIdScreenState extends State<UserIdScreen> {
  TextEditingController _userIdController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Scaffold 배경색을 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '학번 입력',
          style: TextStyle(color: Colors.black), // 제목 텍스트 색상 변경
        ),
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 변경
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'USER ID:',
                labelStyle: TextStyle(color: Colors.black), // 라벨 텍스트 색상 변경
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // 입력창 밑줄 색상 변경
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (int.tryParse(value) == null && value.isNotEmpty) {
                  setState(() {
                    errorMessage = '유효한 학번을 입력해주세요.';
                  });
                } else {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userId = int.tryParse(_userIdController.text);
                if (userId != null) {
                  setState(() {
                    errorMessage = null; // 버튼 클릭 시에도 오류 메시지 초기화
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeatStatusScreen(userId: userId),
                    ),
                  );
                } else {
                  setState(() {
                    errorMessage = '유효한 학번을 입력해주세요.';
                  });
                }
              },
              child: Text('좌석 상태 확인'),
            ),
          ],
        ),
      ),
    );
  }
}
