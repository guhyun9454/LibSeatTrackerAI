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

  @override
  void dispose() {
    // 여기에 비동기 작업이나 타이머를 정리하는 코드를 추가합니다.
    super.dispose();
  }

  Future<void> fetchSeatNumber() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final user = data.firstWhere((user) => user['user_id'] == widget.userId,
            orElse: () => null);

        if (user != null) {
          if (mounted) {
            setState(() {
              seatNumber = user['seat_id'] ?? 0;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              errorMessage = '사용자를 찾을 수 없습니다.';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = '좌석 정보를 가져오는 중 오류 발생: ${response.reasonPhrase}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = '좌석 정보를 가져오는 중 오류 발생: $e';
        });
      }
    }
  }

  Future<void> cancelSeat() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/cancel/?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            seatNumber = -1;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seat canceled successfully')),
        );
      } else {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            errorMessage = 'Error: ${responseData['detail']}';
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['detail']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                left: 19,
                top: 127,
                child: Container(
                  width: 392,
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
                left: 19,
                top: 101,
                child: Container(
                  width: 392,
                  height: 50,
                  decoration: BoxDecoration(color: Color(0xFFA40F16)),
                ),
              ),
              Positioned(
                right: 19,
                top: 101,
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    fetchSeatNumber();
                  },
                ),
              ),
              if (seatNumber == -1)
                Center(
                  child: Text(
                    '예약한 자리가 없습니다',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                )
              else ...[
                Positioned(
                  left: 60,
                  top: 190,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 75,
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
                      SizedBox(height: 5),
                      Container(
                        width: 75,
                        height: 30,
                        child: Center(
                          child: Text(
                            '$seatNumber번',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4A4A4A),
                              fontSize: 25,
                              fontFamily: 'Freesentation',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 300,
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 61,
                  top: 304,
                  child: Container(
                    width: 304,
                    height: 304,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset('assets/images/QR.png',
                              fit: BoxFit.cover),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              Positioned(
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    cancelSeat();
                  },
                  child: Container(
                    width: 430,
                    height: 60,
                    decoration: BoxDecoration(color: Color(0xFFA40F16)),
                    child: Center(
                      child: Text(
                        '예약 취소 / 퇴실',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
