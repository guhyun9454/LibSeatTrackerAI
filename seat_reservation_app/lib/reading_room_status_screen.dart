import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'seat_status_screen.dart';
import 'main_page.dart';

class ReadingRoomStatusScreen extends StatefulWidget {
  final int userId;
  final String name;
  final String department;
  final int warningCount;

  ReadingRoomStatusScreen({
    required this.userId,
    required this.name,
    required this.department,
    required this.warningCount,
  });

  @override
  _ReadingRoomStatusScreenState createState() =>
      _ReadingRoomStatusScreenState();
}

class _ReadingRoomStatusScreenState extends State<ReadingRoomStatusScreen> {
  final String apiUrl = 'http://127.0.0.1:8000/seats/status';
  final String numberOfSeatsUrl = 'http://127.0.0.1:8000/seats/number';
  Timer? timer;
  List<int> seatStatuses = [];
  int totalSeats = 0;
  String? errorMessage;
  String selectedCampus = '국제캠퍼스';
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    fetchTotalSeats();
    fetchSeatStatuses();
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => fetchSeatStatuses());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchTotalSeats() async {
    try {
      final response = await http.get(Uri.parse(numberOfSeatsUrl));
      if (response.statusCode == 200) {
        setState(() {
          totalSeats = int.parse(response.body);
        });
      } else {
        setState(() {
          errorMessage =
              'Error while fetching total seats: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error while fetching total seats: $e';
      });
    }
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
        } else {
          setState(() {
            errorMessage =
                'Error in data format while fetching seat information';
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Error while fetching seat information: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error while fetching seat information: $e';
      });
    }
  }

  int getOccupiedSeatsCount() {
    return seatStatuses.where((status) => status != 0 && status != 6).length;
  }

  Color getBarColor(int occupiedSeats) {
    double ratio = occupiedSeats / totalSeats;
    if (ratio >= 1.0) {
      return Colors.red;
    } else if (ratio >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget buildReadingRoomContainer(String title, int occupiedSeats,
      int totalSeats, int availableSeats, double progress) {
    bool isFavorite = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          width: 410,
          height: 220,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeatStatusScreen(
                            userId: widget.userId,
                            name: widget.name,
                            department: widget.department,
                            warningCount: widget.warningCount,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      backgroundColor: Color(0xFF111E63),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      '자리 배정',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    '00:00 ~ 24:00',
                    style: TextStyle(fontSize: 12),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.yellow : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                '사용 중인 좌석: $occupiedSeats / $totalSeats',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        getBarColor(occupiedSeats)),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Available: $availableSeats',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int occupiedSeats = getOccupiedSeatsCount();
    int availableSeats = totalSeats - occupiedSeats;
    double progress = (totalSeats > 0) ? (occupiedSeats / totalSeats) : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '좌석 및 시설 예약',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(
                  userId: widget.userId,
                  name: widget.name,
                  department: widget.department,
                  warningCount: widget.warningCount,
                ),
              ),
            );
          },
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              StatusHeader(
                onToggle: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
              SizedBox(height: 20),
              if (isExpanded) ...[
                buildReadingRoomContainer('1F 제 1열람실', occupiedSeats,
                    totalSeats, availableSeats, progress),
                buildReadingRoomContainer('2F 제 2열람실', occupiedSeats,
                    totalSeats, availableSeats, progress),
                buildReadingRoomContainer('3F 제 3열람실', occupiedSeats,
                    totalSeats, availableSeats, progress),
                buildReadingRoomContainer('4F 제 4열람실', occupiedSeats,
                    totalSeats, availableSeats, progress),
              ],
            ],
          ),
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

class StatusHeader extends StatefulWidget {
  final VoidCallback onToggle;

  StatusHeader({required this.onToggle});

  @override
  _StatusHeaderState createState() => _StatusHeaderState();
}

class _StatusHeaderState extends State<StatusHeader> {
  String selectedCampus = '국제캠퍼스';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Container(
            width: 216.77,
            height: 45,
            decoration: BoxDecoration(color: Color(0xFF979797)),
            child: Center(
              child: Text(
                '좌석 현황/배정',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FacilityStatusScreen(),
                ),
              );
            },
            child: Container(
              width: 213.2,
              height: 45,
              decoration: BoxDecoration(color: Color(0xFFA40F16)),
              child: Center(
                child: Text(
                  '시설 현황/예약',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Transform(
        transform: Matrix4.identity()
          ..translate(200.0, 25.0)
          ..rotateZ(3.13),
        child: GestureDetector(
          onTap: widget.onToggle,
          child: Container(
            width: 15,
            height: 15,
            decoration: ShapeDecoration(
              color: Color(0xFF111E63),
              shape: StarBorder.polygon(sides: 3),
            ),
          ),
        ),
      ),
    ]);
  }
}

class FacilityStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('시설 현황/예약'),
      ),
      body: Center(
        child: Text('시설 현황/예약 페이지'),
      ),
    );
  }
}
