import 'package:flutter/material.dart';
import 'dayscreen_tab_bar/views/dayscreen_tab_bar.dart';
import 'employee_tab_bar/views/employee_tab_bar.dart';
import 'monthscreen_tab_bar/views/monthscreen_tab_bar.dart';
import 'accountscreen/views/accoutscreen.dart';
import '../../../../data/statelessdata/Admin/bottom_nav_bar/bottomnav.dart';

class BottomNavBarAdmin extends StatefulWidget {
  const BottomNavBarAdmin({super.key});

  @override
  State<BottomNavBarAdmin> createState() => _BottomNavBarAdminState();
}

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  int _currentIndex = 0;

  // Style riêng cho chữ label của BottomNavigationBar
  final TextStyle _selectedLabelTextStyle = const TextStyle(
    fontFamily: 'HP001',
    fontSize: 15, // giảm nhỏ hơn nữa
    color: Colors.black,
  );
  final TextStyle _unselectedLabelTextStyle = const TextStyle(
    fontFamily: 'HP001',
    fontSize: 15, // giảm nhỏ hơn nữa
    color: Colors.grey,
  );

  final List<Widget> _pages = [
    DayScreenTabBar(),
    Employees(),
    MonthScreen(), // Đổi từ MonthScreenTabBar() sang MonthScreen()
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Đổi màu nền navbar thành trắng
        selectedItemColor: Colors.black, // Màu icon/label khi được chọn
        unselectedItemColor: Colors.grey, // Màu icon/label khi không chọn
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedLabelStyle: _selectedLabelTextStyle,
        unselectedLabelStyle: _unselectedLabelTextStyle,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: BottomnavData.day,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: BottomnavData.employee,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: BottomnavData.month,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: BottomnavData.options,
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
