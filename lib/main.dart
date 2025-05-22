import 'package:flutter/material.dart';
import 'feattures/login/views/login.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/accountscreen/views/ChangePassword/changepassworda.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/employee_tab_bar/views/payment.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/dayscreen_tab_bar/views/dayscreen_tab_bar.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/employee_tab_bar/views/ManagenmentEmployees/Addemployees/addemployeesinfo.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/employee_tab_bar/views/ManagenmentEmployees/Addemployees/addemployeesauth.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/employee_tab_bar/views/ManagenmentEmployees/Addemployees/payrollcalculationmethod.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/employee_tab_bar/views/ManagenmentEmployees/updateemployee.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/employee_tab_bar/views/ManagenmentEmployees/lockemployees.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/employee_tab_bar/views/ManagenmentEmployees/deleteemployees.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/dayscreen_tab_bar/views/Notification/notificationscreena.dart';
import 'feattures/admin/bottom_nav_bar_admin/views/dayscreen_tab_bar/views/Notification/notificationstagsa.dart';

void main() {
  runApp(const WhateverApp());
}

class WhateverApp extends StatelessWidget {
  const WhateverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/changepassworda': (context) => const ChangePasswordA(),
        '/payment': (context) => PaymentScreen(),
        '/dayscreen': (context) => DayScreenTabBar(),
        '/addemployeesinfo':
            (context) => AddEmployeesInfo(
              employeeData:
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?,
            ),
        '/addemployeesauth':
            (context) => AddEmployeesAuth(
              employeeData:
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>,
            ),
        '/payrollcalculationmethod':
            (context) => PayrollCalculationMethod(
              employeeData:
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>,
            ),
        '/lockemployees': (context) => LockEmployees(),
        '/updateemployee': (context) => UpdateEmployee(),
        '/deleteemployee': (context) => DeleteEmployee(),
        '/NotificationScreenA': (context) => NotificationScreenA(),
        '/NotificationTagsA': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
          return NotificationsTagsA(notifications: args ?? []);
        },
      },
    );
  }
}
