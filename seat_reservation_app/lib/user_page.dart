import 'package:flutter/material.dart';
import 'user_id_screen.dart';

class UserPage extends StatelessWidget {
  final int userId;
  final String name;
  final String department;
  final int warningCount;

  UserPage({
    required this.userId,
    required this.name,
    required this.department,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('유저 페이지'),
      ),
      body: Container(
        color: Colors.white, // 배경색 흰색으로 설정
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
                            'assets/images/학생페이지 뒷배경.png', // 이미지 파일 경로
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
                              name,
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
                              userId.toString(),
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
                              department,
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
                        bottom: 50, // 로그아웃 버튼을 조금 위로 이동
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
