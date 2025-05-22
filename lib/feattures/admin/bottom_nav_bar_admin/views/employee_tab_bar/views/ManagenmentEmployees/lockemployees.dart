import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../../../url.dart';
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class LockEmployees extends StatefulWidget {
  const LockEmployees({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LockEmployeesState createState() => _LockEmployeesState();
}

class _LockEmployeesState extends State<LockEmployees> {
  String? selectedEmployee;
  Map<String, dynamic> employeeInfo = {};
  Map<String, dynamic> initialEmployeeInfo = {};
  bool isModified = false;
  List<dynamic> employees = [];

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
        throw Exception('Admin ID not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/employees?admin_id=$adminId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch employees');
      }

      final data = json.decode(response.body);
      final filteredData =
          data.map<Map<String, dynamic>>((employee) {
            return {
              'id': employee['id'],
              'name': employee['name'],
              'active_status': employee['active_status'],
            };
          }).toList();

      setState(() {
        employees = filteredData;
      });
    } catch (error) {
      print('Error fetching employees: $error');
    }
  }

  void handleSelectEmployee(int index) {
    if (index != employees.length) {
      // Check if not cancelled
      final employee = employees[index];
      setState(() {
        selectedEmployee = employee['name'];
        employeeInfo = Map.from(employee);
        initialEmployeeInfo = Map.from(employee);
      });
    }
  }

  Future<void> handleActivate() async {
    try {
      final updateData = {'employee_id': employeeInfo['id']};

      final response = await http.put(
        Uri.parse('$baseUrl/employeesactive'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update employee status');
      }

      setState(() {
        employeeInfo['active_status'] = 'active';
        isModified = false;
      });

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Thông báo'),
              content: Text('Nhân viên đã được kích hoạt.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    fetchEmployees();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (error) {
      print('Error updating employee status: $error');
    }
  }

  Future<void> handleUnactivate() async {
    try {
      final updateData = {'employee_id': employeeInfo['id']};

      final response = await http.put(
        Uri.parse('$baseUrl/employeesunactive'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update employee status');
      }

      setState(() {
        employeeInfo['active_status'] = 'unactive';
        isModified = false;
      });

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Thông báo'),
              content: Text('Nhân viên đã bị khóa.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    fetchEmployees();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (error) {
      print('Error updating employee status: $error');
    }
  }

  void showEmployeeSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn nhân viên',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: employees.length + 1,
                  itemBuilder: (context, index) {
                    if (index == employees.length) {
                      return TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Hủy', style: TextStyle(color: Colors.red)),
                      );
                    }
                    return ListTile(
                      title: Text(employees[index]['name']),
                      onTap: () {
                        handleSelectEmployee(index);
                        Navigator.pop(context);
                      },
                    );
                  },
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
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.lockEmployeeTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: showEmployeeSelection,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF5e749e),
                backgroundColor: Colors.white,
                side: BorderSide(color: Color(0xFFcccccc)),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                selectedEmployee ?? 'Chọn nhân viên',
                style: TextStyle(fontSize: 16),
              ),
            ),
            if (selectedEmployee != null) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  if (employeeInfo['active_status'] != 'active')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: handleActivate,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFF5e749e),
                          backgroundColor: Color(0xFFd4edda),
                          side: BorderSide(color: Color(0xFFc3e6cb)),
                        ),
                        child: Text('Kích hoạt'),
                      ),
                    ),
                  if (employeeInfo['active_status'] != 'unactive') ...[
                    if (employeeInfo['active_status'] != 'active')
                      SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: handleUnactivate,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFF5e749e),
                          backgroundColor: Color(0xFFf8d7da),
                          side: BorderSide(color: Color(0xFFf5c6cb)),
                        ),
                        child: Text('Vô hiệu hóa'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
