import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../../../url.dart';
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class DeleteEmployee extends StatefulWidget {
  const DeleteEmployee({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DeleteEmployeeState createState() => _DeleteEmployeeState();
}

class _DeleteEmployeeState extends State<DeleteEmployee> {
  String? selectedEmployee;
  Map<String, dynamic> employeeInfo = {};
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
            return {'id': employee['id'], 'name': employee['name']};
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
      final employee = employees[index];
      setState(() {
        selectedEmployee = employee['name'];
        employeeInfo = Map.from(employee);
      });
    }
  }

  Future<void> deleteEmployee() async {
    try {
      final response = await http.post(
        Uri.parse('https://backendapperss.onrender.com/deleteemployee'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'employee_id': employeeInfo['id']}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete employee');
      }

      fetchEmployees();

      setState(() {
        selectedEmployee = null;
        employeeInfo = {};
      });

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Thông báo'),
              content: Text('Nhân viên đã được xóa thành công.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (error) {
      print('Error deleting employee: $error');
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text('Không thể xóa nhân viên. Vui lòng thử lại.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa nhân viên này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteEmployee();
                },
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
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
        title: AppbarData.deleteEmployeeTitle,
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
              ElevatedButton(
                onPressed: showDeleteConfirmation,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Xóa nhân viên'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
