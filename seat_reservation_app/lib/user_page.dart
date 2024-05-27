import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_id_screen.dart';

class UserPage extends StatefulWidget {
  final int userId;
  final String name;
  final String department;

  UserPage({
    required this.userId,
    required this.name,
    required this.department,
  });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final String getWarningCountUrl =
      'http://127.0.0.1:8000/usr/warning_count/?user_id=';
  int warningCount = 0;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchWarningCount(widget.userId);
  }

  Future<void> fetchWarningCount(int userId) async {
    try {
      final response = await http.get(Uri.parse('$getWarningCountUrl$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          warningCount = data['warning_count'] ?? 0;
        });
      } else {
        setState(() {
          errorMessage = '경고 횟수를 가져오는 중 오류 발생: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '경고 횟수를 가져오는 중 오류 발생: $e';
        warningCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('유저 페이지'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -42,
                        top: 0,
                        child: Container(
                          width: 472,
                          height: 208,
                          child: Image.asset(
                            'assets/images/학생페이지 뒷배경.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 115,
                        top: 120,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 230, 230, 230),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 115,
                        top: 115,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: ShapeDecoration(
                            shape: CircleBorder(),
                          ),
                          child: ClipOval(
                            child: Icon(
                              Icons.person,
                              size: 150,
                              color: Color.fromARGB(255, 145, 145, 145),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 93,
                        top: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이름',
                              style: TextStyle(
                                color: Color(0xFF848484),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '학번',
                              style: TextStyle(
                                color: Color(0xFF848484),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '학부',
                              style: TextStyle(
                                color: Color(0xFF848484),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '경고누적',
                              style: TextStyle(
                                color: Color(0xFF848484),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 241,
                        top: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.name,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFF525252),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              widget.userId.toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFF525252),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              widget.department,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFF525252),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '$warningCount번',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFF525252),
                                fontSize: 17,
                                fontFamily: 'Freesentation',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 로그아웃 버튼 추가
                      Positioned(
                        right: 30,
                        bottom: 50,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserIdScreen(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                '로그아웃',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
