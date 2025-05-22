import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../../Extend/common/widgets/Appbar/appbar.dart';
import '../../../../../../data/statelessdata/Admin/appbar/appbar.dart';

class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MonthScreenState createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  List<dynamic> employees = [];
  dynamic selectedEmployee;
  DateTime currentMonth = DateTime.now();
  String? selectedButton;
  DateTime? selectedDay;
  bool confirmModalVisible = false;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('admin_id');
      if (adminId == null) {
        throw Exception('admin_id not found in shared preferences');
      }

      final response = await http.get(
        Uri.parse('${BASE_URL}/dayscreen?admin_id=$adminId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            employees = data;
          });
        } else {
          print('Fetched data is not an array: $data');
          setState(() {
            employees = [];
          });
        }
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (error) {
      print('Error fetching employees: $error');
    }
  }

  void selectEmployee(dynamic employeeId) {
    // Replace firstWhereOrNull with manual search to avoid 'collection' dependency
    final employee = employees.firstWhere(
      (emp) => emp['id'] == employeeId,
      orElse: () => null,
    );
    setState(() {
      selectedEmployee = employee;
    });
  }

  void handlePrevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void handleNextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
  }

  void handleButtonPress(String buttonTitle) {
    setState(() {
      selectedButton = buttonTitle;
    });
  }

  void handleDayPress(DateTime day) {
    final today = DateTime.now();
    final selectedDayStart = DateTime(day.year, day.month, day.day);

    if (selectedDayStart.isAfter(
      DateTime(today.year, today.month, today.day),
    )) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Xin lỗi'),
              content: Text(
                'Ngày này chưa tới, bạn không thể thay đổi trạng thái',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    if (selectedButton != null && selectedEmployee != null) {
      setState(() {
        selectedDay = day;
        confirmModalVisible = true;
      });
    }
  }

  Future<void> updateOrAddAttendance() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay!);
    print(
      'Updating or adding attendance for date: $formattedDate with status: $selectedButton',
    );

    final existingAttendance = (selectedEmployee['attendance'] as List?)
        ?.firstWhere((att) => att['date'] == formattedDate, orElse: () => null);

    final endpoint =
        existingAttendance != null ? '/updateAttendance' : '/addAttendance';

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employee_id': selectedEmployee['id'],
          'date': formattedDate,
          'status': selectedButton,
          'color':
              selectedButton == 'Đủ'
                  ? 'green'
                  : selectedButton == 'Vắng'
                  ? 'red'
                  : selectedButton == 'Nửa'
                  ? 'yellow'
                  : 'transparent',
        }),
      );

      if (response.statusCode == 200) {
        final updatedAttendance = List.from(
          selectedEmployee['attendance'] ?? [],
        );
        final attendanceIndex = updatedAttendance.indexWhere(
          (att) => att['date'] == formattedDate,
        );

        if (attendanceIndex > -1) {
          updatedAttendance[attendanceIndex] = {
            ...updatedAttendance[attendanceIndex],
            'status': selectedButton,
            'color':
                selectedButton == 'Đủ'
                    ? 'green'
                    : selectedButton == 'Vắng'
                    ? 'red'
                    : selectedButton == 'Nửa'
                    ? 'yellow'
                    : 'transparent',
          };
        } else {
          updatedAttendance.add({
            'date': formattedDate,
            'status': selectedButton,
            'color':
                selectedButton == 'Đủ'
                    ? 'green'
                    : selectedButton == 'Vắng'
                    ? 'red'
                    : selectedButton == 'Nửa'
                    ? 'yellow'
                    : 'transparent',
          });
        }

        final updatedEmployee = {
          ...selectedEmployee,
          'attendance': updatedAttendance,
        };

        setState(() {
          selectedEmployee = updatedEmployee;
          final employeeIndex = employees.indexWhere(
            (emp) => emp['id'] == selectedEmployee['id'],
          );
          if (employeeIndex > -1) {
            employees[employeeIndex] = updatedEmployee;
          }
          confirmModalVisible = false;
        });
      } else {
        print(
          'Failed to update attendance. Server responded with ${response.statusCode}: ${response.body}',
        );
      }
    } catch (error) {
      print('Error updating attendance: $error');
    }
  }

  List<Widget> renderDays() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    // Find the first day of the week for the first day of the month
    final firstDayOfWeek = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    // Find the last day of the week for the last day of the month
    final lastDayOfWeek = lastDayOfMonth.add(
      Duration(days: DateTime.daysPerWeek - lastDayOfMonth.weekday),
    );

    final days = <Widget>[];
    DateTime currentDay = firstDayOfWeek;

    while (currentDay.isBefore(lastDayOfWeek) ||
        currentDay.isAtSameMomentAs(lastDayOfWeek)) {
      final day = currentDay;
      final isCurrentMonth = day.month == currentMonth.month;

      // Replace firstWhereOrNull with firstWhere + orElse
      final attendance = (selectedEmployee?['attendance'] as List?)?.firstWhere(
        (att) => att['date'] == DateFormat('yyyy-MM-dd').format(day),
        orElse: () => null,
      );

      final dayStyle = BoxDecoration(
        color:
            attendance != null
                ? _getColorFromString(attendance['color'])
                : Colors.transparent,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      );

      days.add(
        GestureDetector(
          onTap: () => handleDayPress(day),
          child: Container(
            width: MediaQuery.of(context).size.width / 7,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: dayStyle,
            child: Text(
              day.day.toString(),
              style: TextStyle(
                fontSize: 16,
                color:
                    isCurrentMonth
                        ? Colors.black
                        : Colors.black.withOpacity(0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      currentDay = currentDay.add(Duration(days: 1));
    }

    return days;
  }

  Color _getColorFromString(String colorStr) {
    switch (colorStr) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.transparent;
    }
  }

  void showEmployeeActionSheet() {
    if (employees.isEmpty) {
      print('No employees available for selection.');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Vui lòng chọn nhân viên',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HP001',
                      ),
                    ),
                  ),
                  ...employees.map(
                    (employee) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        title: Text(
                          employee['name'],
                          style: TextStyle(fontFamily: 'HP001'),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          selectEmployee(employee['id']);
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red, fontFamily: 'HP001'),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.monthscreenTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: handlePrevMonth,
                    ),
                    Text(
                      DateFormat('MM/yyyy').format(currentMonth),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: handleNextMonth,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                          .map(
                            (day) => Text(
                              day,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .toList(),
                ),
                Wrap(children: renderDays()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusButton('Đủ', Colors.green),
                    _buildStatusButton('Vắng', Colors.red),
                    _buildStatusButton('Nửa', Colors.yellow),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 35),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFF5e749e),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: InkWell(
                    onTap: showEmployeeActionSheet,
                    child: Center(
                      child: Text(
                        selectedEmployee != null
                            ? selectedEmployee['name']
                            : 'Chọn nhân viên',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'HP001',
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (confirmModalVisible) _buildConfirmModal(),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String title, Color activeColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedButton == title
                ? activeColor.withOpacity(0.2)
                : Colors.white,
        foregroundColor: Color(0xFF5e749e),
        side: BorderSide(
          color:
              selectedButton == title ? Colors.transparent : Color(0xFF5e749e),
        ),
      ),
      onPressed: () => handleButtonPress(title),
      child: Text(
        title,
        style: TextStyle(
          color: selectedButton == title ? activeColor : Color(0xFF5e749e),
        ),
      ),
    );
  }

  Widget _buildConfirmModal() {
    Color statusColor;
    switch (selectedButton) {
      case 'Đủ':
        statusColor = Colors.green;
        break;
      case 'Vắng':
        statusColor = Colors.red;
        break;
      case 'Nửa':
        statusColor = Colors.yellow;
        break;
      default:
        statusColor = Colors.black;
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'HP001',
                      ),
                      children: [
                        TextSpan(text: 'Bạn có chắc chắn muốn '),
                        TextSpan(
                          text: selectedButton ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontFamily: 'HP001',
                          ),
                        ),
                        TextSpan(
                          text:
                              ' cho ngày ${DateFormat('dd-MM-yyyy').format(selectedDay!)}?',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5e749e),
                        ),
                        onPressed: updateOrAddAttendance,
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HP001',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed:
                            () => setState(() => confirmModalVisible = false),
                        child: Text(
                          'No',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HP001',
                          ),
                        ),
                      ),
                    ],
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

// Replace with your actual BASE_URL
const BASE_URL = 'https://backendapperss.onrender.com';
