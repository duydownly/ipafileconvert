import 'package:flutter/material.dart';
import '../../styles/app_bar_styles/appbar_style.dart';

/// CommonAppBar là một widget AppBar dùng chung.
///
/// Sử dụng widget này trong bất kỳ màn hình nào bằng cách truyền vào tham số [title] là một chuỗi.
/// Ví dụ sử dụng:
///
/// ```dart
/// import '.../widgets/Appbar/appbar.dart';
///
/// Scaffold(
///   appBar: CommonAppBar(title: 'Tiêu đề của bạn'),
///   body: ...,
/// )
/// ```
///
/// Bạn cũng có thể truyền vào các giá trị từ file dữ liệu tĩnh, ví dụ:
///
/// ```dart
/// import '.../data/statelessdata/appbar/appbar.dart';
///
/// CommonAppBar(title: AppbarData.dayscreenTitle)
/// ```
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Color? titleColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: CommonAppBarStyle.titleStyle.copyWith(
          color: titleColor ?? CommonAppBarStyle.titleStyle.color,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor ?? CommonAppBarStyle.backgroundColor,
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(CommonAppBarStyle.appBarHeight);
}
