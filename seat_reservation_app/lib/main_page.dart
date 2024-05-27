import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_page.dart';
import 'reading_room_status_screen.dart';
import 'mobile_ticket_page.dart';

class MainPage extends StatelessWidget {
  final int userId;
  final String name;
  final String department;
  final int warningCount;

  MainPage({
    required this.userId,
    required this.name,
    required this.department,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    // 상태 표시줄의 색상과 아이콘 스타일을 설정
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // 상태 표시줄의 배경색을 흰색으로 설정
      statusBarIconBrightness: Brightness.dark, // 상태 표시줄 아이콘 밝기를 어둡게 설정
    ));

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white, // 상태 표시줄 배경색 흰색
          statusBarIconBrightness: Brightness.dark, // 상태 표시줄 아이콘 밝기 어둡게
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 430,
                  height: 1200, // 전체 높이를 늘려서 스크롤 가능하게 설정
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 55,
                        child: Container(
                          width: 430,
                          height: 595,
                          decoration: BoxDecoration(color: Color(0xFFA40F16)),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 55,
                        child: Image.asset(
                          'assets/images/웃는사자.png', // 웃는 사자 이미지 경로
                          fit: BoxFit.cover,
                          height: 595, // 빨간 컨테이너와 동일한 높이
                        ),
                      ),
                      Positioned(
                        left: 15,
                        top: 80, // 유저페이지 밑부분에 위치
                        child: Image.asset(
                          'assets/images/로고.png', // 검색사진 이미지 경로
                          width: 182,
                          height: 43,
                        ),
                      ),
                      Positioned(
                        left: 316,
                        top: 95,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPage(
                                  userId: userId,
                                  department: department,
                                  name: name,
                                  warningCount: warningCount,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 67,
                            height: 17,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: Text(
                                '유저페이지',
                                style: TextStyle(
                                  color: Color(0xFF4B4B4B),
                                  fontSize: 12,
                                  fontFamily: 'Freesentation',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 새로운 네모 컨테이너 추가
                      Positioned(
                        left: 393, // 유저페이지 컨테이너 오른쪽에 위치
                        top: 95,
                        child: Container(
                          width: 18,
                          height: 18,
                          color: Colors.white,
                        ),
                      ),
                      // 검색사진 이미지 추가
                      Positioned(
                        left: 5,
                        top: 145, // 유저페이지 밑부분에 위치
                        child: Image.asset(
                          'assets/images/검색 사진.png', // 검색사진 이미지 경로
                          width: 420,
                          height: 230,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 365,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MobileTicketPage(
                                  seatNumber: 0,
                                  userId: userId,
                                  name: name,
                                  department: department,
                                  warningCount: warningCount,
                                ),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/images/도서관이용증.png', // 도서관 이용증 이미지 경로
                            width: 120,
                            height: 120,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 130,
                        top: 390,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadingRoomStatusScreen(
                                  userId: userId,
                                  name: name,
                                  department: department,
                                  warningCount: warningCount,
                                ),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/images/자리 이용 예약.png', // 자리 이용 내역 이미지 경로
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                      // 빨간 컨테이너 아래에 추가할 내용
                      Positioned(
                        left: 10,
                        top: 695,
                        child: Container(
                          width: 408,
                          height: 205,
                          decoration: ShapeDecoration(
                            color: Colors.white, // 배경색 흰색으로 설정
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 25.57,
                        top: 715,
                        child: Container(
                          width: 60.44,
                          height: 23.70,
                          decoration: ShapeDecoration(
                            color: Color(0xFF111E63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 90.67,
                        top: 715,
                        child: Container(
                          width: 38.36,
                          height: 23.70,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 133.68,
                        top: 715,
                        child: Container(
                          width: 39.52,
                          height: 23.70,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 330.12,
                        top: 720,
                        child: SizedBox(
                          width: 31.38,
                          height: 16.59,
                          child: Text(
                            '더보기',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                              fontFamily: 'Freesentation',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
