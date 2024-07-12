import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl; //

  ApiService({required this.baseUrl});

  Future<List<dynamic>> getSeats() async {
    final response = await http.get(Uri.parse('$baseUrl/seats/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load seats');
    }
  }

  Future<int?> getMySeat(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/seat/?user_id=$userId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['my_seat'];
    } else {
      throw Exception('Failed to load seat');
    }
  }

  Future<void> reserveSeat(int seatNumber, int userId) async {
    final response = await http.put(
        Uri.parse('$baseUrl/seats/?seat_number=$seatNumber&user_id=$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to reserve seat');
    }
  }

  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect'));
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return json.decode(respStr);
    } else {
      throw Exception('Failed to upload image');
    }
  }
}
