import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsTagsA extends StatefulWidget {
  final List<dynamic> notifications;
  const NotificationsTagsA({super.key, required this.notifications});

  @override
  State<NotificationsTagsA> createState() => _NotificationsTagsAState();
}

class _NotificationsTagsAState extends State<NotificationsTagsA> {
  String activeTab = 'Notifications';
  late List<dynamic> notificationList;
  late List<dynamic> history;
  Map? selectedNotification;
  bool isModalVisible = false;
  bool isRejectModalVisible = false;
  String rejectionReason = '';

  @override
  void initState() {
    super.initState();
    print(
      'NotificationsTagsA received notifications: ${widget.notifications}',
    ); // log input
    final sorted = List<Map<String, dynamic>>.from(widget.notifications)..sort(
      (a, b) => DateTime.parse(
        b['created_at'],
      ).compareTo(DateTime.parse(a['created_at'])),
    );
    notificationList =
        sorted.where((item) {
          // Nếu là bool
          if (item['is_viewed_by_admin'] is bool) {
            return item['is_viewed_by_admin'] == false;
          }
          // Nếu là String
          if (item['is_viewed_by_admin'] is String) {
            return item['is_viewed_by_admin'] == 'false';
          }
          // Nếu là số
          if (item['is_viewed_by_admin'] is num) {
            return item['is_viewed_by_admin'] == 0;
          }
          return false;
        }).toList();
    history =
        sorted.where((item) {
          if (item['is_viewed_by_admin'] is bool) {
            return item['is_viewed_by_admin'] == true;
          }
          if (item['is_viewed_by_admin'] is String) {
            return item['is_viewed_by_admin'] == 'true';
          }
          if (item['is_viewed_by_admin'] is num) {
            return item['is_viewed_by_admin'] == 1;
          }
          return false;
        }).toList();
    print('notificationList: $notificationList'); // log notificationList
    print('history: $history'); // log history
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

  void handleNotificationPress(Map notification) {
    setState(() {
      selectedNotification = notification;
      isModalVisible = true;
    });
  }

  void handleAccept() async {
    // TODO: Gọi API chấp nhận
    setState(() {
      updateNotificationStatus('Accepted');
      isModalVisible = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yêu cầu đã được chấp nhận.')));
    // Navigator.of(context).pop(); // hoặc chuyển hướng khác nếu cần
  }

  void handleReject() {
    setState(() {
      isModalVisible = false;
      isRejectModalVisible = true;
    });
  }

  void confirmReject() async {
    if (rejectionReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do từ chối.')),
      );
      return;
    }
    // TODO: Gọi API từ chối
    setState(() {
      updateNotificationStatus('Rejected');
      isRejectModalVisible = false;
      rejectionReason = '';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yêu cầu đã bị từ chối.')));
    // Navigator.of(context).pop(); // hoặc chuyển hướng khác nếu cần
  }

  void updateNotificationStatus(String status) {
    if (selectedNotification != null) {
      final updated = Map<String, dynamic>.from(selectedNotification!);
      updated['status'] = status;
      updated['rejection_reason'] =
          status == 'Rejected' ? rejectionReason : null;
      notificationList.removeWhere(
        (item) => item['id'] == selectedNotification!['id'],
      );
      history.add(updated);
      selectedNotification = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = activeTab == 'Notifications' ? notificationList : history;
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(() => activeTab = 'Notifications'),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 3,
                                color:
                                    activeTab == 'Notifications'
                                        ? const Color(0xFF5e749e)
                                        : Colors.transparent,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => activeTab = 'History'),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 3,
                                color:
                                    activeTab == 'History'
                                        ? const Color(0xFF5e749e)
                                        : Colors.transparent,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children:
                        data.map<Widget>((item) {
                          return GestureDetector(
                            onTap: () => handleNotificationPress(item),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    activeTab == 'History'
                                        ? const Color(0xffe0e0e0)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5e749e),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Ứng tiền: ${item['name']}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Số tiền: ${item['amount']?.toString() ?? ''} VND',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Lý do: ${item['reason']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Ngày tạo: ${formatDate(item['created_at'])}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (activeTab == 'History')
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['status'] == 'Accepted'
                                              ? 'Đã chấp nhận'
                                              : item['status'] == 'Rejected'
                                              ? 'Đã từ chối'
                                              : (item['status'] ?? ''),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        if (item['status'] == 'Rejected' &&
                                            item['rejection_reason'] != null)
                                          Text(
                                            'Lý do từ chối: ${item['rejection_reason']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.red,
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            if (isModalVisible && selectedNotification != null)
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ứng tiền: ${selectedNotification!['name']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Số tiền: ${selectedNotification!['amount']?.toString() ?? ''} VND',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Lý do: ${selectedNotification!['reason']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (selectedNotification!['rejection_reason'] != null)
                          Text(
                            'Lý do từ chối: ${selectedNotification!['rejection_reason']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        Text(
                          'Ngày tạo: ${formatDate(selectedNotification!['created_at'])}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (activeTab == 'Notifications')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: handleAccept,
                                child: const Text('Chấp nhận'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5e749e),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: handleReject,
                                child: const Text('Từ chối'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        TextButton(
                          onPressed:
                              () => setState(() => isModalVisible = false),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (isRejectModalVisible)
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Nhập lý do từ chối',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Nhập lý do từ chối',
                            border: OutlineInputBorder(),
                          ),
                          minLines: 2,
                          maxLines: 5,
                          onChanged: (value) => rejectionReason = value,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: confirmReject,
                              child: const Text('Xác nhận'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5e749e),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => setState(() {
                                    isRejectModalVisible = false;
                                    rejectionReason = '';
                                  }),
                              child: const Text('Hủy'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
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
