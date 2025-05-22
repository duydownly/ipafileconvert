import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../../Extend/common/widgets/Appbar/appbar.dart'; // <-- already present
import '../../../../../../data/statelessdata/Admin/appbar/appbar.dart';

class Employees extends StatefulWidget {
  const Employees({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmployeesState createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  List<dynamic> employees = [];
  bool modalVisible = false;
  bool managementModalVisible = false;
  dynamic selectedEmployee;
  double totalBalance = 0;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchEmployees();
  }

  Future<void> refreshBalance() async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/refreshbalance'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Balance refreshed successfully');
      } else {
        print('Failed to refresh balance, Status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error refreshing balance: $error');
    }
  }

  Future<void> fetchEmployees() async {
    try {
      await refreshBalance();
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('admin_id');
      print('Admin ID: $adminId');

      if (adminId != null) {
        final url = Uri.parse('$BASE_URL/employeetabscreen?admin_id=$adminId');
        print('Fetching URL: $url');

        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Fetched Data: $data');
          setState(() {
            employees = data;
            calculateTotalBalance(data);
          });
        } else {
          print('Failed to fetch employees, Status: ${response.statusCode}');
        }
      } else {
        print('No admin_id found in SharedPreferences');
      }
    } catch (error) {
      print('Error fetching employees: $error');
    }
  }

  void calculateTotalBalance(List<dynamic> employees) {
    final total = employees.fold(0.0, (sum, employee) {
      final balance = double.tryParse(employee['balance'].toString()) ?? 0.0;
      return sum + balance;
    });
    setState(() {
      totalBalance = total;
    });
  }

  void handleEmployeeSelect(dynamic employee) {
    setState(() {
      selectedEmployee = employee;
      modalVisible = false;
    });
  }

  void openManagementModal() {
    setState(() {
      managementModalVisible = true;
    });
  }

  void closeManagementModal() {
    setState(() {
      managementModalVisible = false;
    });
  }

  void handleAddEmployee() {
    closeManagementModal();
    // Ensure modal is closed before navigating
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.pushNamed(context, '/addemployeesinfo');
    });
  }

  void handleUpdateEmployee() {
    Navigator.pushNamed(context, '/updateemployee');
    closeManagementModal();
  }

  void handleLockEmployee() {
    Navigator.pushNamed(context, '/lockemployees');
    closeManagementModal();
  }

  void handleDeleteEmployee() {
    Navigator.pushNamed(context, '/deleteemployee');
    closeManagementModal();
  }

  String formatNumber(double number) {
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.employeescreenTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      modalVisible = true;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(37),
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          margin: const EdgeInsets.only(top: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5e749e),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Text(
                            'TỔNG PHẢI TRẢ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${formatNumber(totalBalance)} VND',
                            style: const TextStyle(
                              color: Color(0xFF5e749e),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: openManagementModal,
                          child: Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5e749e),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Quản lý',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'HP001',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/payment');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5e749e),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Thanh Toán',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'HP001',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Modals
          if (modalVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  modalVisible = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from bubbling up
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'DANH SÁCH NHÂN VIÊN (${employees.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5e749e),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // Prevent overflow by limiting height and making scrollable
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ...employees.map((employee) {
                                          return GestureDetector(
                                            onTap: () {
                                              handleEmployeeSelect(employee);
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xFFdddddd),
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 10,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    employee['name'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Số dư ${formatNumber(double.tryParse(employee['balance'].toString()) ?? 0)}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (managementModalVisible)
            GestureDetector(
              onTap: closeManagementModal,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from bubbling up
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: GestureDetector(
                              onTap: handleAddEmployee,
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5e749e),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Thêm',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: GestureDetector(
                              onTap: handleUpdateEmployee,
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5e749e),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Sửa',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: GestureDetector(
                              onTap: handleLockEmployee,
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5e749e),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Khóa',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: GestureDetector(
                              onTap: handleDeleteEmployee,
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5e749e),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Xóa',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ignore: constant_identifier_names
const BASE_URL =
    'https://backendapperss.onrender.com'; // Replace with your actual base URL
