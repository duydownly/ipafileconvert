import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../../../url.dart'; // Điều chỉnh lại nếu cần

// Để xem log, hãy mở Debug Console (VS Code/Android Studio) hoặc dùng lệnh `flutter logs` khi chạy app ở chế độ debug.

class NotificationScreenA extends StatefulWidget {
  final Function(List<dynamic>)? onTapNotification;
  const NotificationScreenA({super.key, this.onTapNotification});

  @override
  State<NotificationScreenA> createState() => _NotificationScreenAState();
}

class _NotificationScreenAState extends State<NotificationScreenA> {
  List allNotifications = [];
  List unviewedNotifications = [];
  int currentIndex = 0;
  String? error;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDate(String dateString) {
    final today = DateTime.now();
    final date = DateTime.parse(dateString);
    final todayDate = DateTime(today.year, today.month, today.day);
    final dateDate = DateTime(date.year, date.month, date.day);
    final diffDays = todayDate.difference(dateDate).inDays;

    if (diffDays == 0) return 'Hôm nay';
    if (diffDays == 1) return 'Hôm qua';
    if (diffDays == 2) return 'Hôm kia';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString(
        'admin_id',
      ); // lấy adminId từ shared_preferences
      log('Admin ID: $adminId');
      if (adminId == null) {
        setState(() => error = 'Không tìm thấy Admin ID');
        log('Không tìm thấy Admin ID');
        return;
      }

      // Sử dụng adminId lấy từ SharedPreferences thay vì hardcode
      final url = Uri.parse(
        'https://backendapperss.onrender.com/notification_advance_admin?admin_id=$adminId',
      );
      log('Requesting: $url');
      final response = await http.get(url);

      log('Status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          log('Decoded data: $data');
          if (data is List) {
            log('Số lượng thông báo nhận được: ${data.length}');
            setState(() {
              allNotifications = data;
              unviewedNotifications =
                  data.where((item) {
                    if (item['is_viewed_by_admin'] is bool) {
                      return item['is_viewed_by_admin'] == false;
                    }
                    if (item['is_viewed_by_admin'] is String) {
                      return item['is_viewed_by_admin'] == 'false';
                    }
                    if (item['is_viewed_by_admin'] is num) {
                      return item['is_viewed_by_admin'] == 0;
                    }
                    return false;
                  }).toList();
              log('Unviewed notifications: $unviewedNotifications');
              error = null;
            });

            timer?.cancel();
            if (unviewedNotifications.isNotEmpty) {
              timer = Timer.periodic(const Duration(seconds: 5), (_) {
                if (!mounted) return;
                setState(() {
                  currentIndex =
                      (currentIndex + 1) % unviewedNotifications.length;
                });
              });
            }
          } else {
            log('API trả về không phải là List. Kiểu: ${data.runtimeType}');
            setState(() => error = 'API trả về không đúng định dạng');
          }
        } catch (e) {
          log('Lỗi khi parse JSON: $e');
          setState(() => error = 'Lỗi khi đọc dữ liệu từ server');
        }
      } else {
        log('Lỗi HTTP: status=${response.statusCode}, body=${response.body}');
        setState(
          () =>
              error =
                  'Lỗi khi tải dữ liệu từ server (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      setState(() => error = 'Đã xảy ra lỗi: $e');
      log('Đã xảy ra lỗi: $e');
    }
  }

  void handleNotificationPress() {
    log('handleNotificationPress - allNotifications: $allNotifications');
    if (widget.onTapNotification != null) {
      log('onTapNotification callback is provided');
      widget.onTapNotification!.call(allNotifications);
    } else {
      log('onTapNotification callback is NOT provided');
    }
    // Nếu dùng Navigator để chuyển trang:
    // log('Push to /NotificationTagsA with: $allNotifications');
    // Navigator.pushNamed(context, '/NotificationTagsA', arguments: allNotifications);
  }

  Widget buildEmptyNotification() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: handleNotificationPress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              const Text(
                'Thông báo',
                style: TextStyle(fontSize: 16, height: 2),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5e749e),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10, top: 10),
                alignment: Alignment.center,
                child: const Text(
                  'Chưa có thông báo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotificationItem(Map notification) {
    final title = 'Ứng tiền: ${notification['name']}';
    final truncatedDescription =
        (notification['reason'] as String).length > 20
            ? '${notification['reason'].substring(0, 20)}...'
            : notification['reason'];

    // Đảm bảo amount luôn là String khi hiển thị
    final amountStr = notification['amount']?.toString() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: handleNotificationPress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông báo',
                style: TextStyle(fontSize: 16, height: 2),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5e749e),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10, top: 10),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Số tiền: $amountStr VND',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Text(
                'Lý do: $truncatedDescription',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                'Ngày tạo: ${formatDate(notification['created_at'])}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Text(error!));
    }

    if (unviewedNotifications.isEmpty) {
      return buildEmptyNotification();
    }

    return buildNotificationItem(unviewedNotifications[currentIndex]);
  }
}
