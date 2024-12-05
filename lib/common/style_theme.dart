import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color main_color = Color(0xff055ee5);
const Color sub_color = Color(0xffEDD5B2);
const Color line = Color(0xffe0e0e0);

const Color styleBaseCol1 = Color(0xff0C5767);
const Color styleBaseCol2 = Color(0xff083742);
const Color styleBaseCol3 = Color(0xff72A3AD);

const Color styleGreyCol1 = Color(0xffCDCDCD);
const Color styleGreyCol2 = Color(0xffE0E0E0);
const Color styleGreyCol3 = Color(0xffFAFAFA);

const Color light_gray = Color(0xffe9e9e9);
const Color light_gray1 = Color(0xfff0f0f0);
const Color light_gray2 = Color(0xff6e6e6e);
const Color light_gray3 = Color(0xffafafaf);
const Color light_gray4 = Color(0xfff4f4f4);
const Color light_gray5 = Color(0xff7b7b7b);
const Color light_gray6 = Color(0xff727272);
const Color light_gray7 = Color(0xff9e9e9e);
const Color light_gray8 = Color(0xff909090);
const Color light_gray9 = Color(0xff838383);
const Color light_gray10 = Color(0xff3a3a3a);
const Color light_gray11 = Color(0xffe1e1e1);
const Color light_gray12 = Color(0xffbababa);
const Color light_gray13 = Color(0xff999999);
const Color light_gray14 = Color(0xffacacac);
const Color light_gray15 = Color(0xffdadada);
const Color light_gray16 = Color(0xff8e8e8e);
const Color light_gray17 = Color(0xff5c5c5c);
const Color light_gray18 = Color(0xffb7b7b7);
const Color light_gray19 = Color(0xffdddddd);
const Color light_gray20 = Color(0xff959595);
const Color light_gray21 = Color(0xff848484);
const Color light_gray22 = Color(0xffefefef);
const Color light_gray23 = Color(0xffc3c3c3);
const Color light_gray24 = Color(0xffececec);

final double styleFontSize5 = CustomStyle.getSp(5.0);
final double styleFontSize6 = CustomStyle.getSp(6.0);
final double styleFontSize7 = CustomStyle.getSp(7.0);
final double styleFontSize8 = CustomStyle.getSp(8.0);
final double styleFontSize9 = CustomStyle.getSp(9.0);
final double styleFontSize10 = CustomStyle.getSp(10.0);
final double styleFontSize11 = CustomStyle.getSp(11.0);
final double styleFontSize12 = CustomStyle.getSp(12.0);
final double styleFontSize13 = CustomStyle.getSp(13.0);
final double styleFontSize14 = CustomStyle.getSp(14.0);
final double styleFontSize15 = CustomStyle.getSp(15.0);
final double styleFontSize16 = CustomStyle.getSp(16.0);
final double styleFontSize17 = CustomStyle.getSp(17.0);
final double styleFontSize18 = CustomStyle.getSp(18.0);
final double styleFontSize20 = CustomStyle.getSp(20.0);
final double styleFontSize22 = CustomStyle.getSp(22.0);
final double styleFontSize36 = CustomStyle.getSp(36.0);


class CustomStyle {
  static TextStyle baseFont() {
    return TextStyle(
        fontSize: styleFontSize14,
        color: Colors.black
    );
  }

  static TextStyle CustomFont(double fontSize, Color color,{FontWeight? font_weight}) {
    return TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: font_weight != null?font_weight:FontWeight.normal
    );
  }

  static TextStyle whiteFont15B() {
    return baseFont().copyWith(
        color: Colors.white,
        fontSize: styleFontSize15,
        fontWeight: FontWeight.w700);
  }

  static TextStyle whiteFont() {
    return baseFont().copyWith(color: Colors.white);
  }

  static TextStyle blackFont() {
    return baseFont().copyWith(color: Colors.black);
  }

  static TextStyle alertMsgFont() {
    return baseFont()
        .copyWith(color: Colors.black, fontSize: styleFontSize15);
  }

  static Widget sizedBoxWidth(_width) {
    return SizedBox(width: CustomStyle.getWidth(_width));
  }

  static Widget sizedBoxHeight(_height) {
    return SizedBox(height: CustomStyle.getHeight(_height));
  }

  static double getWidth(double _width) {
    return ScreenUtil().setWidth(_width);
  }

  static double getHeight(double _height) {
    return ScreenUtil().setHeight(_height);
  }

  static double getSp(double _fSize) {
    return ScreenUtil().setSp(_fSize);
  }

  static Border borderAllBase({Color? color, double? width}) {
    return Border.all(color: color??line, width: width??CustomStyle.getWidth(0.5));
  }

  static Widget getDivider1() {
    return Container(
        height: CustomStyle.getHeight(1.0),
        color: main_color,
    );
  }

  static Widget getDivider2() {
    return Container(
      height: CustomStyle.getHeight(2.0),
      color: main_color,
    );
  }

  static Widget getDivider3() {
    return  Container(
      height: CustomStyle.getHeight(3.0),
      color: main_color,
    );
  }

  static Widget getDivider5() {
    return  Container(
      height: CustomStyle.getHeight(5.0),
      color: main_color,
    );
  }

  static Widget getDivider10() {
    return Container(
      height: CustomStyle.getHeight(10.0),
      color: main_color,
    );
  }
}