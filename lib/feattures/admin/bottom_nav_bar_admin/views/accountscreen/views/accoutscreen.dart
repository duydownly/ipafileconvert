import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../Extend/common/widgets/Appbar/appbar.dart'; // <-- already present
import '../../../../../../data/statelessdata/Admin/appbar/appbar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key}); // Sửa lại constructor cho đúng

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String name = '';

  @override
  void initState() {
    super.initState();
    _fetchName();
  }

  Future<void> _fetchName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('name');
    if (storedName != null) {
      setState(() {
        name = storedName;
      });
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_id');
    await prefs.remove('id'); // Xóa luôn id nếu có
    await prefs.remove('name');
    // Reset navigation stack và chuyển đến màn hình login
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _handleChangePassword() {
    Navigator.of(context).pushNamed('/changepassworda');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.optionscreenTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Icon(Icons.account_circle, size: 100, color: Color(0xFF5e749e)),
                SizedBox(height: 10),
                Text(
                  name.isNotEmpty ? name : 'Tài khoản',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'HP001',
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 300, // Giảm chiều rộng để không tràn viền
                  height: 3,
                  decoration: BoxDecoration(
                    color: Color(0xFF5e749e),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildMenuItem(
                  Icons.person,
                  'Thông tin tài khoản',
                  onTap: () {},
                ),
                _buildMenuItem(Icons.language, 'Ngôn ngữ', onTap: () {}),
                _buildMenuItem(
                  Icons.shield,
                  'Bảo mật & Tính năng',
                  onTap: () {},
                ),
                _buildMenuItem(
                  Icons.vpn_key,
                  'Nhập mã kích hoạt',
                  onTap: () {},
                ),
                _buildMenuItem(
                  Icons.lock,
                  'Đổi mật khẩu',
                  onTap: _handleChangePassword,
                ),
                _buildMenuItem(Icons.help, 'Hỗ trợ', onTap: () {}),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: 350,
              height: 65,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5e749e),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
                onPressed: _handleLogout,
                child: Text(
                  'Đăng Xuất',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'HP001',
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF5e749e)),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'HP001',
          fontSize: 22,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      horizontalTitleGap: 10,
      shape: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
    );
  }
}
