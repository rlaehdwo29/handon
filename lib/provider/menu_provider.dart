import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/interface/model/code_model.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class MenuProvider with ChangeNotifier {
  final controller = Get.find<App>();

  Map<String, dynamic> _translations = {};

  Future<void> loadTranslations(String languageCode) async {
    _translations = await getCode(languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return _translations[key] ?? key;
  }


   Future<Map<String, dynamic>> getCode(String? code) async {
    Logger logger = Logger();
    UserModel mUser = await controller.getUserInfo();
    final response = await http.post(headers: {
    "Content-Type" : "application/json"
    },Uri.parse('http://112.171.80.94:8000/get_code?access_key=${mUser.access_key}&cmd=${code == "ne" ? "LANG_NPL" : code == "my" ? "LANG_MMR" : code == "km" ? "LANG_KHM" : "LANG_KOR" }&site_gubun=K&user_id=${mUser.user_id}'));

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      Map<String, dynamic> jsonData = jsonDecode(decoded);
      Map<String,dynamic> jsonRealData = Map();
      for(var item in jsonData["code_list"]) {
        jsonRealData.addAll({item["app_search_key"] : item["wordd"]});
      }
      return jsonRealData;
    } else {
      throw Exception('Failed to load translations');
    }
  }
}