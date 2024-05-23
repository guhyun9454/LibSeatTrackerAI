import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SeatStatusScreen(),
    );
  }
}

class SeatStatusScreen extends StatefulWidget {
  @override
  _SeatStatusScreenState createState() => _SeatStatusScreenState();
}

class _SeatStatusScreenState extends State<SeatStatusScreen> {
  final String apiUrl = 'http://127.0.0.1:8000/seats/status';
  Timer? timer;
  List<int> seatStatuses = [];

  @override
  void initState() {
    super.initState();
    fetchSeatStatuses();
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
        setState(() {
          seatStatuses = List<int>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load seat statuses');
      }
    } catch (e) {
      print('Exception: Failed to load seat statuses: $e');
    }
  }

  Color getSeatColor(int index) {
    if (index == 4 && seatStatuses.isNotEmpty) {
      return getStatusColor(seatStatuses[0]);
    } else if (index == 20 && seatStatuses.length > 1) {
      return getStatusColor(seatStatuses[1]);
    } else {
      return Colors.grey;
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green; // Available
      case 1:
        return Colors.blue; // In use
      case 2:
        return Colors.red; // Unauthorized use
      case 3:
        return Colors.orange; // Reserved waiting entry
      case 4:
        return Colors.yellow; // Checking out
      case 5:
        return Colors.purple; // Temporarily empty
      default:
        return Colors.grey; // Unknown
    }
  }

  Widget buildSeat(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: getSeatColor(index),
        shape: BoxShape.rectangle,
      ),
      child: Center(
        child: Text(
          'Seat ${index + 1}',
          style: TextStyle(color: Colors.white, fontSize: 10),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSeatRow(startIndex),
        SizedBox(height: 10),
        buildSeatRow(startIndex + 3),
      ],
    );
  }

  Widget buildSeatGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSeatColumn(0),
            buildSeatColumn(6),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSeatColumn(12),
            buildSeatColumn(18),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSeatColumn(24),
            buildSeatColumn(30),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('좌석 상태 확인'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 40, // 화면 상단에서 10px 떨어진 위치
              left: (MediaQuery.of(context).size.width - 450) / 2,
              child: Container(
                width: 450,
                height: 650,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // 밝은 회색
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: buildSeatGrid(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
