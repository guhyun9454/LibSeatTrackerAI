import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reading_room_status_screen.dart';
import 'user_id_screen.dart';

class SeatStatusScreen extends StatefulWidget {
  final int userId;

  SeatStatusScreen({required this.userId});

  @override
  _SeatStatusScreenState createState() => _SeatStatusScreenState();
}

class _SeatStatusScreenState extends State<SeatStatusScreen> {
  final String apiUrl = 'http://127.0.0.1:8000/seats/status';
  Timer? timer;
  List<int> seatStatuses = [];
  int? mySeat;
  ScrollController _scrollController = ScrollController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSeatStatuses();
    fetchUserSeat(widget.userId);
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => fetchSeatStatuses());

    _scrollController.addListener(() {
      double pixels = _scrollController.position.pixels;
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      AxisDirection userScrollDirection =
          _scrollController.position.axisDirection;
      print('스크롤 위치: $pixels');
      print('최대 스크롤 범위: $maxScrollExtent');
      print('사용자 스크롤 방향: $userScrollDirection');
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchSeatStatuses() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('좌석 상태 응답 상태 코드: ${response.statusCode}'); // 디버깅용
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            seatStatuses = List<int>.from(data);
            print('좌석 상태: $seatStatuses'); // 디버깅용
          });
        } else {
          setState(() {
            errorMessage = '좌석 정보를 가져오는 중 데이터 형식 오류 발생';
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
      print('Exception: $e');
    }
  }

  Future<void> fetchUserSeat(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:8000/seat/?user_id=$userId'));
      print('사용자 좌석 응답 상태 코드: ${response.statusCode}'); // 디버깅용
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('my_seat')) {
          setState(() {
            mySeat = data['my_seat'] != null
                ? int.tryParse(data['my_seat'].toString())
                : -1;
            print('사용자 좌석: $mySeat'); // 디버깅용
          });
        } else {
          setState(() {
            errorMessage = '사용자 좌석 정보를 가져오는 중 데이터 형식 오류 발생';
          });
        }
      } else {
        setState(() {
          errorMessage = '사용자 좌석 정보를 가져오는 중 오류 발생: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '사용자 좌석 정보를 가져오는 중 오류 발생: $e';
      });
      print('Exception: $e');
    }
  }

  Future<void> reserveSeat(int seatId, int userId) async {
    try {
      final response = await http
          .put(Uri.parse('$apiUrl/reserve/?seat_id=$seatId&user_id=$userId'));
      print('좌석 예약 응답 상태 코드: ${response.statusCode}'); // 디버깅용
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            seatStatuses = List<int>.from(data);
            print('예약 후 좌석 상태: $seatStatuses'); // 디버깅용
          });
          fetchUserSeat(userId);
        } else {
          setState(() {
            errorMessage = '좌석 예약 후 데이터 형식 오류 발생';
          });
        }
      } else {
        setState(() {
          errorMessage = '좌석 예약 중 오류 발생: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '좌석 예약 중 오류 발생: $e';
      });
      print('Exception: $e'); // 디버깅을 위한 예외 메시지 출력
    }
  }

  Color getSeatColor(int index) {
    if (index < seatStatuses.length) {
      return getStatusColor(seatStatuses[index]);
    } else {
      return const Color.fromARGB(255, 183, 183, 183);
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green; // 예약 가능
      case 1:
        return Colors.blue; // 사용 중
      case 2:
        return Colors.red; // 무단 이용중
      case 3:
        return Colors.yellow; // 예약됨 (입실 대기)
      case 4:
        return Colors.orange; // 퇴실 예정
      case 5:
        return Colors.purple; // 자리 비움
      default:
        return Colors.grey; // 알 수 없음
    }
  }

  void onSeatTap(int index) {
    int seatStatus = seatStatuses[index];
    String message;

    switch (seatStatus) {
      case 0:
        message = '이 좌석은 예약 가능합니다.';
        reserveSeat(index, widget.userId);
        break;
      case 1:
        message = '이 좌석은 사용 중입니다.';
        break;
      case 2:
        message = '이 좌석은 무단 이용 중입니다.';
        break;
      case 3:
        message = '이 좌석은 예약되었고 입실을 기다리고 있습니다.';
        break;
      case 4:
        message = '이 좌석은 퇴실 예정입니다.';
        break;
      case 5:
        message = '이 좌석은 일시적으로 비어 있습니다.';
        break;
      default:
        message = '이 좌석은 알 수 없는 상태입니다.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('좌석 상태'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildSeat(int index) {
    return GestureDetector(
      onTap: () => onSeatTap(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: getSeatColor(index),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Text(
            'Seat $index',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget buildSeatRow(int startIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSeat(startIndex),
        SizedBox(width: 10),
        buildSeat(startIndex + 1),
        SizedBox(width: 10),
        buildSeat(startIndex + 2),
      ],
    );
  }

  Widget buildSeatColumn(int startIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildSeatRow(startIndex),
        SizedBox(height: 10),
        buildSeatRow(startIndex + 3),
      ],
    );
  }

  Widget buildScrollableSeatGrid() {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: List.generate(
                5,
                (innerIndex) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    children: [
                      buildSeatColumn((index * 30) + (innerIndex * 6)),
                      if (innerIndex % 2 == 1)
                        SizedBox(height: 30), // 두 행마다 공백 추가
                    ],
                  ),
                ),
              ),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatusLegend() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0), // 오른쪽 여백 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildLegendItem(Colors.green, '예약 가능'),
              SizedBox(width: 10),
              buildLegendItem(Colors.blue, '사용 중'),
              SizedBox(width: 10),
              buildLegendItem(Colors.red, '무단 이용중'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildLegendItem(Colors.yellow, '예약됨 (입실 대기)'),
              SizedBox(width: 10),
              buildLegendItem(Colors.orange, '퇴실 예정'),
              SizedBox(width: 10),
              buildLegendItem(Colors.purple, '자리 비움'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          color: color,
        ),
        SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Scaffold 배경색을 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '좌석 상태 확인',
          style: TextStyle(color: Colors.black), // 제목 텍스트 색상 변경
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReadingRoomStatusScreen(userId: widget.userId),
              ),
            );
          },
          color: Colors.black, // 아이콘 색상 변경
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserIdScreen()),
              );
            },
            color: Colors.black, // 아이콘 색상 변경
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 20), // 상단 여백
            buildStatusLegend(), // 상태 설명을 상단에 추가
            SizedBox(height: 10), // 상태 설명과 컨테이너 사이의 여백
            ClipRect(
              child: Container(
                width: 450,
                height: 610, // 높이를 조정하여 overflow 문제 해결
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 237, 237, 237), //
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: buildScrollableSeatGrid(), // 스크롤 가능한 좌석 그리드 표시
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchSeatStatuses, // 새로고침 버튼 클릭 시 즉시 업데이트
        backgroundColor: Colors.white,
        child: Icon(Icons.refresh, color: Colors.black),
        tooltip: '새로고침',
      ),
    );
  }
}
