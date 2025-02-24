import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/config_url.dart';
import 'package:handon_project/interface/model/code_model.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MenuProvider with ChangeNotifier {
  final controller = Get.find<App>();

  Map<String, dynamic> _translations = {};

  // Return된 다국어를 파일로 만들어 경로에 저장. (언어 변환 시 실시간으로 빠르게 변환하기 위함.)
  Future<void> loadTranslations(String languageCode) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();   // 애플리케이션 디렉토리 경로 가져오기
      final String filePath = '${appDocDir.path}/assets/translations/$languageCode.json';

      // 파일 로드
      final File file = File(filePath);

      if (await file.exists()) {
        final String jsonString = await file.readAsString();  // 파일이 존재하면 해당 파일 읽기
        _translations = jsonDecode(jsonString);   // 가져온 데이터를 해당 변수에 저장
        notifyListeners();    // 위의 이벤트가 발생하면 갱신해주는 리스너
      } else {
        print('파일이 존재하지 않습니다: $filePath');
      }
    } catch (e) {
      print('로드 중 오류 발생(M): $e');
    }
  }

  // 다국어 데이터 사용 및 변환
  String translate(String key) {
    return _translations[key] ?? key;
  }


   Future<Map<String, dynamic>> getCode(String? code) async {
    Logger logger = Logger();
    UserModel mUser = await controller.getUserInfo();
    final response = await http.post(headers: {
    "Content-Type" : "application/json"
    },Uri.parse('${SERVER_URL}get_code?access_key=${mUser.access_key}&cmd=${code == "ne" ? "LANG_NPL" : code == "my" ? "LANG_MMR" : code == "km" ? "LANG_KHM" : "LANG_KOR" }&site_gubun=K&user_id=${mUser.user_id}'));

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