import 'dart:ffi';

import 'package:flutter/material.dart';
import 'numeric/numeric_container.dart';
import 'habit/habit.dart';
class DailyPage extends StatelessWidget {
  final DateTime date;

  DailyPage({required this.date});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '每日记录',
          style: TextStyle(
            fontFamily: "ZHUOKAI",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 顶部时间
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                '${date.year}-${date.month}-${date.day}',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'ZHUOKAI',
                ),
                textAlign: TextAlign.left,
              ),
            ),

            Container(
              color: Colors.grey[100], // 你可以将这里的颜色改为你想要的颜色
              child: const SizedBox(height: 20),
            ),            /// 调用今日活力值板块
            NumericContainer(width: screenWidth * 0.95, height: screenHeight * 0.5),

            Container(
              color: Colors.grey[100], // 你可以将这里的颜色改为你想要的颜色
              child: const SizedBox(height: 20),
            ),
            /// 此板块调用习惯打卡板块
            MultiRowBlock(quantity: 2, section_width: screenWidth,),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}