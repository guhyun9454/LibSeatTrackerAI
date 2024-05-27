import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MobileTicketPage extends StatefulWidget {
  final int userId;
  final String name;
  final String department;

  MobileTicketPage({
    required this.userId,
    required this.name,
    required this.department,
  });

  @override
  _MobileTicketPageState createState() => _MobileTicketPageState();
}

class _MobileTicketPageState extends State<MobileTicketPage> {
  int seatNumber = 0;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSeatNumber();
  }

  Future<void> fetchSeatNumber() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final user = data.firstWhere((user) => user['user_id'] == widget.userId,
            orElse: () => null);

        if (user != null) {
          setState(() {
            seatNumber = user['seat_id'] ?? 0;
          });
        } else {
          setState(() {
            errorMessage = '사용자를 찾을 수 없습니다.';
          });
        }
      } else {
        setState(() {
          errorMessage = '좌석 정보를 가져오는 중 오류 발생: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '좌석 정보를 가져오는 중 오류 발생: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '모바일 이용증',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 430,
          height: 932,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: -4,
                top: 734, // 784 - 30
                child: Container(
                  width: 436,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 19, // 29 - 10 (너비를 키우기 위해 좌측 이동)
                top: 127, // 177 - 30
                child: Container(
                  width: 392, // 372 + 20
                  height: 503,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
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
                left: 19, // 29 - 10 (너비를 키우기 위해 좌측 이동)
                top: 101, // 151 - 30
                child: Container(
                  width: 392, // 372 + 20
                  height: 50,
                  decoration: BoxDecoration(color: Color(0xFFA40F16)),
                ),
              ),
              Positioned(
                left: 0,
                top: 825, // 875 - 30
                child: Container(
                  width: 430,
                  height: 57,
                  decoration: BoxDecoration(color: Color(0xFFA40F16)),
                ),
              ),
              Positioned(
                left: 0,
                top: 882, // 새로운 컨테이너 추가
                child: Container(
                  width: 430,
                  height: 50,
                  decoration: BoxDecoration(color: Color(0xFFA40F16)),
                  child: Center(
                    child: Text(
                      '예약 취소',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'Freesentation',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 180,
                top: 190, // 249 - 30
                child: Column(
                  children: [
                    SizedBox(
                      width: 75, // 65 + 20 (너비를 키움)
                      height: 45,
                      child: Text(
                        '좌석',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF525252),
                          fontSize: 35,
                          fontFamily: 'Freesentation',
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 75, // 65 + 20 (너비를 키움)
                      height: 30,
                      child: Text(
                        '$seatNumber번',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: 20,
                          fontFamily: 'Freesentation',
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 61,
                top: 304, // 354 - 30
                child: Container(
                  width: 304,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.50,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFDDDDDD),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0, // 875 - 30
                child: Container(
                  width: 430,
                  height: 60,
                  decoration: BoxDecoration(color: Color(0xFFA40F16)),
                  child: Center(
                    child: Text(
                      '예약 취소',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Freesentation',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
