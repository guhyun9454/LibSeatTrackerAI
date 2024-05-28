import 'dart:async';
import 'dart:convert';
import 'reading_room_status_screen.dart';
import 'main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mobile_ticket_page.dart';

class SeatStatusScreen extends StatefulWidget {
  final int userId;
  final String name;
  final String department;

  SeatStatusScreen(
      {required this.userId, required this.name, required this.department});

  @override
  _SeatStatusScreenState createState() => _SeatStatusScreenState();
}

class _SeatStatusScreenState extends State<SeatStatusScreen> {
  final String apiUrl = 'http://127.0.0.1:8000/seats/status';
  final String userSeatUrl = 'http://127.0.0.1:8000/usr/seat_id?user_id=';

  Timer? timer;
  List<int> seatStatuses = [];
  int mySeat = -1;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSeatStatuses();
    fetchUserSeat(widget.userId);
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => fetchSeatStatuses());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchSeatStatuses() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            seatStatuses = List<int>.from(data);
          });
          // 사용자의 좌석 상태를 업데이트
          fetchUserSeat(widget.userId);
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
    }
  }

  Future<void> fetchUserSeat(int userId) async {
    try {
      final response = await http.get(Uri.parse('$userSeatUrl$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('seat_id')) {
          setState(() {
            mySeat = data['seat_id'] ?? -1;
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
    }
  }

  Future<void> reserveSeat(int seatId, int userId) async {
    if (mySeat != -1) {
      setState(() {
        errorMessage = '이미 예약된 좌석이 있습니다.';
      });
      return;
    }

    try {
      final response = await http.put(Uri.parse(
          'http://127.0.0.1:8000/reserve/?seat_id=$seatId&user_id=$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['message'] == 'Seat reserved successfully') {
          setState(() {
            seatStatuses[seatId] = 3;
            mySeat = seatId;
          });
          // 좌석 상태를 다시 가져옴
          await fetchSeatStatuses();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MobileTicketPage(
                userId: widget.userId,
                name: widget.name,
                department: widget.department,
              ),
            ),
          );
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
        return Colors.green;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void onSeatTap(int index) {
    int seatStatus = seatStatuses[index];
    String message;

    if (seatStatus == 0) {
      if (mySeat != -1) {
        message = '이미 예약한 자리가 존재합니다.';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white, // 배경 흰색으로 설정
              title: Text(
                '좌석 예약 오류',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              content: Text(
                message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
                textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
              ),
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
        return;
      }
      message = '이 좌석은 예약 가능합니다.\n예약하시겠습니까?';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white, // 배경 흰색으로 설정
            title: Text(
              '좌석 예약',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.black, fontSize: 13),
              textAlign: TextAlign.left,
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  reserveSeat(index, widget.userId);
                },
              ),
            ],
          );
        },
      );
    } else {
      switch (seatStatus) {
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
            backgroundColor: Colors.white,
            title: Text(
              '좌석 상태',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
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
                      if (innerIndex % 2 == 1) SizedBox(height: 30),
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
      padding: const EdgeInsets.only(right: 10.0),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '좌석 상태 확인',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ReadingRoomStatusScreen(
                  userId: widget.userId,
                  department: widget.department,
                  name: widget.name,
                ),
              ),
            );
          },
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(
                    userId: widget.userId,
                    name: widget.name,
                    department: widget.department,
                  ),
                ),
              );
            },
            color: Colors.black,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 20),
            buildStatusLegend(),
            SizedBox(height: 10),
            ClipRect(
              child: Container(
                width: 450,
                height: 610,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 237, 237, 237),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: buildScrollableSeatGrid(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchSeatStatuses,
        backgroundColor: Colors.white,
        child: Icon(Icons.refresh, color: Colors.black),
        tooltip: '새로고침',
      ),
    );
  }
}
