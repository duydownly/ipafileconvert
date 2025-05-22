import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class ChangePasswordA extends StatefulWidget {
  const ChangePasswordA({super.key});

  @override
  ChangePasswordAState createState() => ChangePasswordAState(); // Đổi tên state class thành public
}

class ChangePasswordAState extends State<ChangePasswordA> {
  // Đổi tên class thành public
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  // Thêm biến trạng thái cho ẩn/hiện mật khẩu
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showAlert('Lỗi', 'Vui lòng điền đầy đủ thông tin.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showAlert('Lỗi', 'Mật khẩu mới và xác nhận mật khẩu không khớp.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('admin_id');
      if (adminId == null) {
        _showAlert('Lỗi', 'Không tìm thấy thông tin người dùng.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://backendapperss.onrender.com/changepasswordadmin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'admin_id': adminId,
          'password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showAlert(
          'Thành công',
          data['message'] ?? 'Đổi mật khẩu thành công.',
          onOk: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('admin_id');
            await prefs.remove('id');
            await prefs.remove('name');
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          },
        );
      } else {
        _showAlert('Lỗi', data['error'] ?? 'Đổi mật khẩu thất bại.');
      }
    } catch (e) {
      _showAlert('Lỗi', 'Không thể kết nối đến máy chủ.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAlert(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title, style: TextStyle(fontFamily: 'HP001')),
            content: Text(message, style: TextStyle(fontFamily: 'HP001')),
            actions: [
              TextButton(
                child: Text('OK', style: TextStyle(fontFamily: 'HP001')),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onOk != null) onOk();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.changePasswordTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Đổi Mật Khẩu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HP001',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 45),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    labelStyle: TextStyle(fontFamily: 'HP001'),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    labelStyle: TextStyle(fontFamily: 'HP001'),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Nhập lại mật khẩu mới',
                    labelStyle: TextStyle(fontFamily: 'HP001'),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5e749e),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HP001',
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleChangePassword,
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Thay đổi',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HP001',
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
