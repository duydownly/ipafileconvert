import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Extend/common/widgets/Appbar/appbar.dart';
import '../../../data/statelessdata/Admin/login/statelessdata.dart';
import '../../admin/bottom_nav_bar_admin/views/bottom_nav_bar_admin.dart';
import '../../../url.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  bool _obscureText = true;
  String _phoneNumber = '';
  String _password = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat(reverse: true);

    _phoneController = TextEditingController(text: _phoneNumber);
    _passwordController = TextEditingController(text: _password);

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString('admin_id');

    if (adminId != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBarAdmin()),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (_phoneNumber.isEmpty || _password.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ số điện thoại và mật khẩu';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': _phoneNumber, 'password': _password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final admin = data['admin'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_id', admin['id'].toString());
        await prefs.setString('name', admin['name']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBarAdmin()),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['error'] ?? 'Đăng nhập thất bại';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể kết nối đến server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: LoginData.title),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LoginUIStyles.backgroundGradient,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: LoginUIStyles.spacer70),
                  SizedBox(
                    height: LoginUIStyles.imageHeight,
                    child: Image.asset(
                      'asset/images/image.png',
                      width: LoginUIStyles.imageWidth,
                    ),
                  ),
                  const SizedBox(height: LoginUIStyles.spacer10),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'HP001',
                        ),
                      ),
                    ),

                  const SizedBox(height: LoginUIStyles.spacer15),

                  SizedBox(
                    width: LoginUIStyles.textFieldWidth,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => _phoneNumber = value,
                      decoration: LoginUIStyles.inputDecorationStyle(
                        hintText: LoginData.hintTextNumber,
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: LoginUIStyles.iconColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: LoginUIStyles.spacer20),

                  SizedBox(
                    width: LoginUIStyles.textFieldWidth,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      onChanged: (value) => _password = value,
                      decoration: LoginUIStyles.inputDecorationStyle(
                        hintText: LoginData.hintTextPassword,
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: LoginUIStyles.iconColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: LoginUIStyles.iconColor,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: LoginUIStyles.spacer40),

                  SizedBox(
                    width: 250,
                    child: OutlinedButton(
                      onPressed: _handleLogin,
                      style: LoginUIStyles.outlinedButtonStyle,
                      child: const Text(
                        LoginData.loginButtonText,
                        style: LoginUIStyles.loginButtonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Các lớp LoginData giữ nguyên như định nghĩa ban đầu
class LoginUIStyles {
  // Colors
  static const Color iconColor = Colors.black;
  static const Color appBarBottomColor = Colors.black;
  static const Color appBarBackgroundColor = Colors.white;

  // Sizes
  static const double appBarHeight = 65;
  static const double appBarBottomHeight = 2;
  static const double textFieldWidth = 300;
  static const double imageHeight = 220;
  static const double imageWidth = 500;

  // Spacing
  static const double spacer70 = 20;
  static const double spacer10 = 10;
  static const double spacer15 = 15;
  static const double spacer20 = 20;
  static const double spacer40 = 40;

  // Padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 30,
    vertical: 15,
  );

  // Text Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 30,
    fontStyle: FontStyle.italic,
    fontFamily: 'HP001',
    color: Colors.black,
  );

  static const TextStyle loginButtonTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: Colors.black,
    fontFamily: 'HP001',
    fontStyle: FontStyle.italic,
  );

  static const TextStyle loginButtonHintStyle = TextStyle(
    fontSize: 20,
    color: Colors.black54,
    fontStyle: FontStyle.italic,
    fontFamily: 'HP001',
  );

  // Decorations
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Colors.white, Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static InputDecoration inputDecorationStyle({
    required String hintText,
    required Icon prefixIcon,
    IconButton? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: loginButtonHintStyle,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    side: const BorderSide(color: Colors.black, width: 2),
    padding: buttonPadding,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
