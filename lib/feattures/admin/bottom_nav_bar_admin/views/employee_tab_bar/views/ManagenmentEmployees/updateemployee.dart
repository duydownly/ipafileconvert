import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../../../../../url.dart';
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class UpdateEmployee extends StatefulWidget {
  const UpdateEmployee({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateEmployeeState createState() => _UpdateEmployeeState();
}

class _UpdateEmployeeState extends State<UpdateEmployee> {
  String? selectedEmployee;
  Map<String, dynamic> employeeInfo = {};
  Map<String, dynamic> initialEmployeeInfo = {};
  String? selectedField;
  bool isModified = false;
  List<dynamic> employees = [];
  String temporaryValue = '';
  bool isSalaryFocused = false;
  TextEditingController? _fieldController;

  final List<String> fields = [
    'name',
    'phone',
    'password',
    'cmnd',
    'birth_date',
    'address',
    'salary',
  ];
  final Map<String, String> fieldLabels = {
    'name': 'Tên',
    'phone': 'Số điện thoại',
    'password': 'Mật khẩu',
    'cmnd': 'CMND',
    'birth_date': 'Ngày sinh',
    'address': 'Địa chỉ',
    'salary': 'Lương',
  };

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  @override
  void dispose() {
    _fieldController?.dispose();
    super.dispose();
  }

  void updateFieldController() {
    _fieldController?.removeListener(_onFieldChanged);
    _fieldController?.dispose();
    if (selectedField != null) {
      _fieldController = TextEditingController(
        text: employeeInfo[selectedField]?.toString() ?? '',
      );
      _fieldController!.addListener(_onFieldChanged);
    } else {
      _fieldController = null;
    }
  }

  void _onFieldChanged() {
    final value = _fieldController?.text ?? '';
    if (selectedField == 'salary') {
      final formatted = formatSalary(value);
      if (employeeInfo[selectedField] != formatted) {
        setState(() {
          employeeInfo[selectedField!] = formatted;
        });
      }
    } else {
      if (employeeInfo[selectedField] != value) {
        setState(() {
          employeeInfo[selectedField!] = value;
        });
      }
    }
    checkIsModified();
  }

  void checkIsModified() {
    if (selectedField != null && initialEmployeeInfo.isNotEmpty) {
      final current = employeeInfo[selectedField]?.toString() ?? '';
      final initial = initialEmployeeInfo[selectedField]?.toString() ?? '';
      setState(() {
        isModified = current != initial;
      });
    } else {
      setState(() {
        isModified = false;
      });
    }
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

      setState(() {
        employees = jsonDecode(response.body);
      });
    } catch (error) {
      print('Error fetching employees: $error');
    }
  }

  void handleSelectEmployee(int index) {
    if (index < employees.length) {
      setState(() {
        selectedEmployee = employees[index]['name'];
        initialEmployeeInfo = Map.from(employees[index]);
        employeeInfo = Map.from(employees[index]);
        selectedField = null;
        isModified = false;
      });
      updateFieldController();
    }
  }

  void handleSelectField(int index) {
    if (index < fields.length) {
      setState(() {
        selectedField = fields[index];
      });
      // Cập nhật controller khi chọn trường mới
      updateFieldController();
      checkIsModified();
    }
  }

  String formatSalary(String value) {
    final num = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (num.isNotEmpty) {
      return NumberFormat('#,###').format(int.parse(num));
    }
    return '';
  }

  Future<void> handleConfirm() async {
    try {
      final updateData = {
        'employee_id': employeeInfo['id'],
        'field': selectedField,
        'value':
            selectedField == 'salary'
                ? double.parse(
                  employeeInfo[selectedField!].replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  ),
                )
                : employeeInfo[selectedField!],
      };

      print('Data to be sent: $updateData');

      final response = await http.put(
        Uri.parse('$baseUrl/updateEmployee'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update employee information');
      }

      final result = jsonDecode(response.body);
      print('Update successful: $result');

      setState(() {
        isModified = false;
      });

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Thông báo'),
              content: Text('Cập nhật thông tin thành công.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (error) {
      print('Error updating employee information: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.updateEmployeeTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => ListView.builder(
                        itemCount: employees.length + 1,
                        itemBuilder: (context, index) {
                          if (index < employees.length) {
                            return ListTile(
                              title: Text(employees[index]['name']),
                              onTap: () {
                                handleSelectEmployee(index);
                                Navigator.pop(context);
                              },
                            );
                          } else {
                            return ListTile(
                              title: Text(
                                'Hủy',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () => Navigator.pop(context),
                            );
                          }
                        },
                      ),
                );
              },
              child: Text(selectedEmployee ?? 'Chọn nhân viên'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF5e749e),
                backgroundColor: Colors.white,
                side: BorderSide(color: Color(0xFFcccccc)),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            if (selectedEmployee != null) ...[
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => ListView.builder(
                          itemCount: fields.length + 1,
                          itemBuilder: (context, index) {
                            if (index < fields.length) {
                              return ListTile(
                                title: Text(fieldLabels[fields[index]]!),
                                onTap: () {
                                  handleSelectField(index);
                                  Navigator.pop(context);
                                },
                              );
                            } else {
                              return ListTile(
                                title: Text(
                                  'Hủy',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () => Navigator.pop(context),
                              );
                            }
                          },
                        ),
                  );
                },
                child: Text(
                  selectedField != null
                      ? fieldLabels[selectedField]!
                      : 'Chọn thông tin nhân viên',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF5e749e),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xFFcccccc)),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              if (selectedField != null) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(8),
                        ),
                        controller: _fieldController,
                        onTap: () {
                          if (selectedField == 'salary') {
                            setState(() {
                              isSalaryFocused = true;
                            });
                          }
                        },
                        onFieldSubmitted: (_) {
                          if (selectedField == 'salary') {
                            setState(() {
                              isSalaryFocused = false;
                            });
                          }
                        },
                        keyboardType:
                            selectedField == 'salary'
                                ? TextInputType.number
                                : TextInputType.text,
                      ),
                    ),
                    if (selectedField == 'salary' && isSalaryFocused)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'VND',
                          style: TextStyle(
                            color: Color(0xFF5e749e),
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (isModified) ...[
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: handleConfirm,
                  child: Text(
                    'Xác nhận',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5e749e),
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// Note: You'll need to add these dependencies to your pubspec.yaml:
// shared_preferences: ^2.0.6
// http: ^0.13.3
// intl: ^0.17.0 (for NumberFormat)
