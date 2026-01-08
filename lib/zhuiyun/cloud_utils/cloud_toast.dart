import 'dart:io';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CloudToast {
  static show(String msg, BuildContext context) {
    if (Platform.isWindows || Platform.isMacOS) {
      showToast(msg, context: context, position: StyledToastPosition.center);
      return;
      showToastWidget(
        Text(
          msg,
          style: const TextStyle(
            fontSize: 12.0,
            color: CloudColors.white,
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
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CloudColors.c020202,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              //背景颜色
              backgroundColor: CloudColors.cA4ADBD,
              //进度颜色
              valueColor: AlwaysStoppedAnimation<Color>(
                CloudColors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static Widget loadingWidget() {
    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CloudColors.c020202,
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 3,
        //背景颜色
        backgroundColor: CloudColors.cA4ADBD,
        //进度颜色
        valueColor: AlwaysStoppedAnimation<Color>(
          CloudColors.white,
        ),
      ),
    );
  }
}
