import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedEmployee;
  List<dynamic> employees = [];
  String? selectedAction;
  double balance = 0;
  String amount = '';
  bool showHistoryModal = false;
  bool showDescriptionModal = false;
  List<dynamic> paymentHistory = [];
  String? adminId;
  String description = '';
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FocusNode descriptionFocusNode = FocusNode();

  final List<String> actions = ['Trả lương', 'Thưởng thêm'];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    fetchAdminId();
  }

  @override
  void dispose() {
    descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> fetchAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminId = prefs.getString('admin_id');
    });
    if (adminId != null) {
      fetchEmployees();
      fetchPaymentHistory();
    }
  }

  Future<void> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}/employeetabscreen?admin_id=$adminId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          employees = json.decode(response.body);
        });
      }
    } catch (error) {
      print('Lỗi khi tải danh sách nhân viên: $error');
    }
  }

  Future<void> fetchPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}/historypayments?admin_id=$adminId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          paymentHistory = json.decode(response.body);
        });
      }
    } catch (error) {
      print('Lỗi khi tải lịch sử thanh toán: $error');
    }
  }

  void handleSelectEmployee(String? value) {
    if (value != null) {
      final selected = employees.firstWhere((emp) => emp['name'] == value);
      double parsedBalance = 0;
      final bal = selected['balance'];
      if (bal is int) {
        parsedBalance = bal.toDouble();
      } else if (bal is double) {
        parsedBalance = bal;
      } else if (bal is String) {
        parsedBalance = double.tryParse(bal) ?? 0;
      }
      setState(() {
        selectedEmployee = value;
        balance = parsedBalance;
      });
    }
  }

  void handleAmountChange(String text) {
    final sanitizedText = text.replaceAll(RegExp(r'[^0-9]'), '');
    final parsedNumber = double.tryParse(sanitizedText);
    setState(() {
      amount = parsedNumber == null ? '' : formatNumber(parsedNumber);
      amountController.text = amount;
    });
  }

  String formatNumber(double number) {
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void handleConfirm() {
    final sanitizedAmount = amount.replaceAll('.', '');
    final numericAmount = double.tryParse(sanitizedAmount) ?? 0;

    if (numericAmount == 0) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text('Vui lòng nhập số tiền hợp lệ.'),
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

    double newBalance = balance;
    if (selectedAction == 'Trả lương') {
      newBalance -= numericAmount;
    } else if (selectedAction == 'Thưởng thêm') {
      newBalance += numericAmount;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép bấm ra ngoài
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận'),
            content: Text(
              'Bạn đã chọn $selectedAction cho $selectedEmployee với số tiền: ${formatNumber(numericAmount)} VND\n'
              'Số dư còn lại: ${formatNumber(newBalance)} VND',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setShowDescriptionModal(true);
                },
                child: Text('Xác nhận'),
              ),
            ],
          ),
    );
  }

  Future<void> handleSubmit() async {
    setState(() {
      isProcessing = true;
    });
    final sanitizedAmount = amount.replaceAll('.', '');
    double numericAmount = double.parse(sanitizedAmount);

    if (selectedAction == 'Trả lương') {
      numericAmount = -numericAmount;
    }

    final selectedEmployeeObj = employees.firstWhere(
      (emp) => emp['name'] == selectedEmployee,
      orElse: () => null,
    );

    if (selectedEmployeeObj == null) {
      setState(() {
        isProcessing = false;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text('Không tìm thấy nhân viên.'),
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

    final payload = {
      'employee_id': selectedEmployeeObj['id'],
      'amount': numericAmount,
      'description':
          description.trim().isEmpty ? selectedAction : description.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/adminrequestchangepayments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      setState(() {
        isProcessing = false;
      });

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Text('Thành công'),
                content: Text('Thao tác đã được xử lý thành công!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/payment',
                        (route) => route.isFirst,
                      );
                      resetState();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        throw Exception('Có lỗi xảy ra: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isProcessing = false;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text('Gửi yêu cầu thất bại: $error'),
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

  void resetState() {
    setState(() {
      description = '';
      amount = '';
      selectedEmployee = null;
      selectedAction = null;
      showDescriptionModal = false;
      amountController.clear();
      descriptionController.clear();
    });
  }

  List<dynamic> getPaymentHistoryByEmployeeId(String employeeId) {
    return paymentHistory
        .where((payment) => payment['employee_id'] == employeeId)
        .toList();
  }

  void setShowDescriptionModal(bool value) {
    setState(() {
      showDescriptionModal = value;
    });
    if (value) {
      // Đảm bảo focus vào ô mô tả khi modal hiển thị
      Future.delayed(Duration(milliseconds: 100), () {
        descriptionFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.paymentTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isProcessing,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Employee selection dropdown
                  DropdownButtonFormField<String>(
                    value: selectedEmployee,
                    decoration: InputDecoration(
                      labelText: 'Chọn nhân viên',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        employees.map<DropdownMenuItem<String>>((employee) {
                          return DropdownMenuItem<String>(
                            value: employee['name'],
                            child: Text(employee['name']),
                          );
                        }).toList(),
                    onChanged: handleSelectEmployee,
                  ),

                  SizedBox(height: 16),

                  // Action selection dropdown (luôn hiển thị)
                  DropdownButtonFormField<String>(
                    value: selectedAction,
                    decoration: InputDecoration(
                      labelText: 'Chọn thao tác',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        actions.map((action) {
                          return DropdownMenuItem<String>(
                            value: action,
                            child: Text(action),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAction = value;
                      });
                    },
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Nhập số tiền (VNĐ)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5e749e),
                    ),
                    onChanged: handleAmountChange,
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5e749e),
                      minimumSize: Size(double.infinity, 60),
                    ),
                    child: Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // History Modal
          if (showHistoryModal)
            Center(
              child: WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: Text(
                    'Lịch sử thanh toán',
                    textAlign: TextAlign.center,
                  ),
                  content: Container(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            paymentHistory.map((payment) {
                              final employee = employees.firstWhere(
                                (emp) => emp['id'] == payment['employee_id'],
                                orElse: () => {'name': 'Unknown'},
                              );
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Nhân viên: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: employee['name']),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Số tiền: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${formatNumber(payment['amount'].abs())} VND',
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Hình thức: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                payment['amount'] < 0
                                                    ? "Trả lương"
                                                    : "Thưởng thêm",
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Ngày: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                DateTime.parse(payment['date'])
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Mô tả: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: payment['description'],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showHistoryModal = false;
                        });
                      },
                      child: Text(
                        'Đóng',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF5e749e),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Description Modal
          if (showDescriptionModal)
            GestureDetector(
              onTap: () {
                setState(() {
                  showDescriptionModal = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Ngăn sự kiện tap lan xuống dưới
                    child: AlertDialog(
                      title: Text('Nhập mô tả', textAlign: TextAlign.center),
                      content: TextField(
                        controller: descriptionController,
                        focusNode: descriptionFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Nhập mô tả',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        autofocus: true,
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showDescriptionModal = false;
                            });
                            handleSubmit();
                          },
                          child: Text(
                            'Xác nhận',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF5e749e),
                          ),
                        ),
                      ],
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

// Replace with your actual BASE_URL
// ignore: constant_identifier_names
const BASE_URL = 'https://backendapperss.onrender.com';
