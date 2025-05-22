import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import '../../../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../../../Extend/common/widgets/Appbar/appbar.dart';

class AddEmployeesInfo extends StatefulWidget {
  final Map<String, dynamic>? employeeData;

  const AddEmployeesInfo({super.key, this.employeeData});

  @override
  // ignore: library_private_types_in_public_api
  _AddEmployeesInfoState createState() => _AddEmployeesInfoState();
}

class _AddEmployeesInfoState extends State<AddEmployeesInfo> {
  late TextEditingController _fullNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.employeeData?['fullName'] ?? '',
    );
    _idNumberController = TextEditingController(
      text: widget.employeeData?['idNumber'] ?? '',
    );
    _dobController = TextEditingController(
      text: widget.employeeData?['dob'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.employeeData?['address'] ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleNext() {
    setState(() {
      _error = '';
    });

    if (_fullNameController.text.isEmpty ||
        _idNumberController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _addressController.text.isEmpty) {
      setState(() {
        _error = 'All fields are required';
      });
      return;
    }

    Navigator.pushNamed(
      context,
      '/addemployeesauth',
      arguments: {
        ...?widget.employeeData,
        'fullName': _fullNameController.text,
        'idNumber': _idNumberController.text,
        'dob': _dobController.text,
        'address': _addressController.text,
      },
    );
  }

  void _handleQRScan() {
    Navigator.pushNamed(context, 'QRScanner');
  }

  void _handleCCCDScan() {
    print("CCCD icon pressed");
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Tên nhân viên',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'Số CMND',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Ngày sinh',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: ElevatedButton(
                  onPressed: _handleNext,
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
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: _handleQRScan,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 50,
                      color: Colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _handleCCCDScan,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      'asset/images/cccd.jpg', // Đường dẫn đúng với thư mục asset của bạn
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
