import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'seat_status_screen.dart';
import 'package:flutter/services.dart';

class UserIdScreen extends StatefulWidget {
  @override
  _UserIdScreenState createState() => _UserIdScreenState();
}

class _UserIdScreenState extends State<UserIdScreen> {
  TextEditingController _userIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? errorMessage;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUserId();
  }

  Future<void> _loadSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('savedUserId');
    final saved = prefs.getBool('isSaved') ?? false;
    if (savedUserId != null && saved) {
      setState(() {
        _userIdController.text = savedUserId;
        isSaved = saved;
      });
    } else {
      setState(() {
        _userIdController.clear();
        isSaved = false;
      });
    }
  }

  Future<void> _saveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedUserId', _userIdController.text);
    await prefs.setBool('isSaved', true);
  }

  Future<void> _clearSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedUserId');
    await prefs.setBool('isSaved', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '학번 입력',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadSavedUserId();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 90), // 전체적으로 아래로 이동
            Text(
              '로그인',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '아이디 저장',
                  style: TextStyle(
                    color: Color.fromARGB(255, 154, 154, 154),
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.check_box : Icons.check_box_outline_blank,
                    color: Color(0xFFA40F16),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isSaved) {
                        _clearSavedUserId();
                        isSaved = false;
                      } else {
                        _saveUserId();
                        isSaved = true;
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 5),
            Container(
              width: double.infinity,
              height: 55,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border.all(
                    width: 1, color: Color.fromARGB(255, 184, 184, 184)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _userIdController,
                        decoration: InputDecoration(
                          labelText: 'USER ID:',
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {
                          if (int.tryParse(value) == null && value.isNotEmpty) {
                            setState(() {
                              errorMessage = '유효한 학번을 입력해주세요.';
                            });
                          } else {
                            setState(() {
                              errorMessage = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _userIdController.clear();
                    },
                  ),
                ],
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Container(
              width: double.infinity,
              height: 55,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border.all(
                    width: 1, color: Color.fromARGB(255, 184, 184, 184)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호를 입력하세요',
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                        obscureText: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _passwordController.clear();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 55,
              decoration: ShapeDecoration(
                color: Color(0xFFA40F16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
              ),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    final userId = int.tryParse(_userIdController.text);
                    if (userId != null) {
                      setState(() {
                        errorMessage = null;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SeatStatusScreen(userId: userId),
                        ),
                      );
                    } else {
                      setState(() {
                        errorMessage = '유효한 학번을 입력해주세요.';
                      });
                    }
                  },
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
