import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'seat_status_screen.dart';
import 'user_id_screen.dart'; // Add this import

class ReadingRoomStatusScreen extends StatefulWidget {
  final int userId;

  ReadingRoomStatusScreen({required this.userId});

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
    // Exclude statuses that are green (0) or grey (6)
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

  @override
  Widget build(BuildContext context) {
    int occupiedSeats = getOccupiedSeatsCount();
    int availableSeats = totalSeats - occupiedSeats;
    return Scaffold(
      backgroundColor: Colors.white, // Scaffold background color set to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Reading Room Status',
          style: TextStyle(color: Colors.black), // Title text color changed
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserIdScreen()),
            );
          },
          color: Colors.black, // Icon color changed
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '사용 중인 좌석: $occupiedSeats / $totalSeats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 30,
              decoration: BoxDecoration(
                color: getBarColor(occupiedSeats),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '사용 가능한 좌석: $availableSeats',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
              child: ElevatedButton(
                onPressed: occupiedSeats < totalSeats
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SeatStatusScreen(userId: widget.userId),
                          ),
                        );
                      }
                    : null,
                child: Text('Proceed to Seat Assignment'),
              ),
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
      ),
    );
  }
}
