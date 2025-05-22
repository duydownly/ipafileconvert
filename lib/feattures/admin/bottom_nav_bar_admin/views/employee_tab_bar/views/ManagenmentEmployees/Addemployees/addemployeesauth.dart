import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class AddEmployeesAuth extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const AddEmployeesAuth({super.key, required this.employeeData});

  @override
  // ignore: library_private_types_in_public_api
  _AddEmployeesAuthState createState() => _AddEmployeesAuthState();
}

class _AddEmployeesAuthState extends State<AddEmployeesAuth> {
  late TextEditingController _phoneNumberController;
  late TextEditingController _passwordController;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAddEmployee() async {
    setState(() {
      _error = '';
    });

    // Retrieve admin_id from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString('admin_id');

    if (adminId == null) {
      setState(() {
        _error = 'Admin ID is missing.';
      });
      return;
    }

    // Validate required fields
    if (_phoneNumberController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _error = 'All fields are required';
      });
      return;
    }

    final completeEmployeeData = {
      ...widget.employeeData,
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordController.text,
      'admin_id': adminId,
    };

    Navigator.pushNamed(
      context,
      '/payrollcalculationmethod',
      arguments: completeEmployeeData,
    );
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _handleAddEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5e749e),
                  minimumSize: const Size(90, 90),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
