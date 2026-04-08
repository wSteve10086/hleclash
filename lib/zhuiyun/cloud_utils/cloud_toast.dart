import 'dart:io';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CloudToast {
  static show(String msg, BuildContext context) {
    if (Platform.isWindows || Platform.isMacOS) {
      showToastWidget(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: CloudColors.overlaySurface(context).withOpacity(0.92),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
          msg,
          style: TextStyle(
            fontSize: 12.0,
            color: CloudColors.overlayOnSurface(context),
          ),
        ),
        ),
        context: context,
        position: StyledToastPosition.center,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: CloudColors.c020202,
        textColor: CloudColors.white,
        fontSize: 12.0);
  }

  static void loading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CloudColors.overlaySurface(context).withOpacity(0.92),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              //背景颜色
              backgroundColor:
                  CloudColors.overlayOnSurface(context).withOpacity(0.25),
              //进度颜色
              valueColor: AlwaysStoppedAnimation<Color>(
                CloudColors.overlayOnSurface(context),
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      // Navigator.pop(context);
      Navigator.of(context, rootNavigator: true).pop();

    }
  }

  static Widget loadingWidget() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final bool isDark = brightness == Brightness.dark;
    final overlayColor = isDark ? const Color(0xFFF2F2F2) : const Color(0xFF202020);
    final indicatorColor = isDark ? const Color(0xFF141414) : Colors.white;
    final indicatorBg = isDark ? const Color(0xFF141414).withOpacity(0.25) : const Color(0xFFD0D3DB);
    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: overlayColor.withOpacity(0.92),
      ),
      child: CircularProgressIndicator(
        strokeWidth: 3,
        //背景颜色
        backgroundColor: indicatorBg,
        //进度颜色
        valueColor: AlwaysStoppedAnimation<Color>(
          indicatorColor,
        ),
      ),
    );
  }
}
