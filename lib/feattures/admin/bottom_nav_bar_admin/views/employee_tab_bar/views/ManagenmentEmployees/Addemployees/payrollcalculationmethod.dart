import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../../../../url.dart'; // Thêm dòng này để import baseUrl
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class PayrollCalculationMethod extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const PayrollCalculationMethod({super.key, required this.employeeData});

  @override
  // ignore: library_private_types_in_public_api
  _PayrollCalculationMethodState createState() =>
      _PayrollCalculationMethodState();
}

class _PayrollCalculationMethodState extends State<PayrollCalculationMethod> {
  String _payMethod = '';
  String _salary = '';
  String _selectedCurrency = 'VND';

  final List<String> _payMethods = ['Ngày'];
  final List<String> _currencies = ['VND'];

  late final TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    _salaryController = TextEditingController();
    _salaryController.addListener(_salaryListener);
  }

  void _salaryListener() {
    final formatted = _formatSalary(_salaryController.text);
    if (_salaryController.text != formatted) {
      final selectionIndex = formatted.length;
      _salaryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: selectionIndex),
      );
    }
    setState(() {
      _salary = formatted;
    });
  }

  @override
  void dispose() {
    _salaryController.removeListener(_salaryListener);
    _salaryController.dispose();
    super.dispose();
  }

  void _handleSelectPayMethod(String? value) {
    if (value != null && value != 'Cancel') {
      setState(() {
        _payMethod = value;
      });
    }
  }

  void _handleSelectCurrency(String? value) {
    if (value != null && value != 'Cancel') {
      setState(() {
        _selectedCurrency = value;
      });
    }
  }

  String _formatSalary(String value) {
    final num = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (num.isNotEmpty) {
      final number = int.parse(num);
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), // Sửa lại regex đúng cú pháp
        (Match m) => '${m[1]},',
      );
    }
    return '';
  }

  Future<void> _handleComplete() async {
    final numericSalary = double.tryParse(
      _salary.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (numericSalary == null) {
      print('Invalid salary: $_salary');
      return;
    }

    if (widget.employeeData['fullName'] == null ||
        widget.employeeData['phoneNumber'] == null ||
        widget.employeeData['password'] == null ||
        widget.employeeData['idNumber'] == null ||
        widget.employeeData['dob'] == null ||
        widget.employeeData['address'] == null ||
        widget.employeeData['admin_id'] == null) {
      print('Employee data is incomplete: ${widget.employeeData}');
      return;
    }

    final dataToSend = {
      'fullName': widget.employeeData['fullName'],
      'phoneNumber': widget.employeeData['phoneNumber'],
      'password': widget.employeeData['password'],
      'idNumber': widget.employeeData['idNumber'],
      'dob': widget.employeeData['dob'],
      'address': widget.employeeData['address'],
      'payrollType': _payMethod == 'Tháng' ? 'Tháng' : 'Ngày',
      'salary': numericSalary,
      'currency': _selectedCurrency,
      'admin_id': widget.employeeData['admin_id'],
    };

    print('Data to send: ${jsonEncode(dataToSend)}');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aeas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSend),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('Employee and salary added successfully: $result');

        if (!mounted) return; // Add mounted check before using context

        // Nếu response có trường báo lỗi, hiển thị dialog lỗi
        if (result is Map && result.containsKey('error')) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Lỗi'),
                  content: Text(result['error'].toString()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        } else {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Thành công'),
                  content: const Text('Thêm nhân viên thành công!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Quay về màn hình chính có BottomNavBarAdmin
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      } else {
        print('Failed to add employee and salary: ${response.statusCode}');
        if (!mounted) return; // Add mounted check before using context
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Lỗi'),
                content: const Text(
                  'Không thể thêm nhân viên. Vui lòng thử lại.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (error) {
      print('Error: $error');
      if (!mounted) return; // Add mounted check before using context
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Lỗi'),
              content: const Text('Có lỗi xảy ra khi thêm nhân viên.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.addEmployeeTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pay Method Selection
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Chọn cách tính công'),
                          ),
                          ..._payMethods.map(
                            (method) => ListTile(
                              title: Text(method),
                              onTap: () {
                                _handleSelectPayMethod(method);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Cancel'),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5e749e),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _payMethod.isNotEmpty ? _payMethod : 'Chọn cách tính công',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Salary Input
            if (_payMethod.isNotEmpty) ...[
              Text(
                _payMethod == 'Tháng' ? 'Lương theo tháng' : 'Lương theo ngày',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _salaryController,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder:
                              (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('Chọn đơn vị tiền tệ'),
                                  ),
                                  ..._currencies.map(
                                    (currency) => ListTile(
                                      title: Text(currency),
                                      onTap: () {
                                        _handleSelectCurrency(currency);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Cancel'),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5e749e),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Text(
                        _selectedCurrency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Complete Button
            if (_salary.isNotEmpty && _payMethod.isNotEmpty)
              ElevatedButton(
                onPressed: _handleComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5e749e),
                  minimumSize: const Size(300, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'Hoàn thành',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
