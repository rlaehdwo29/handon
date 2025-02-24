import 'dart:convert';

import 'package:get/get.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SP extends GetxController {
  static SharedPreferences? m_Pref;

  @override
  void onInit() async {
    m_Pref ??= await SharedPreferences.getInstance();
    super.onInit();
  }

  // Login 유저 정보를 저장
  static Future<void> putUserModel(String key, UserModel? value) async {
    await open();
    m_Pref?.setString(key, jsonEncode(value));
  }

  // Login 유져 정보 가져오기
  static Future<UserModel> getUserInfo(String key) async {
    await open();
    var json = await m_Pref?.getString(key);
    if(json == null) {
      return UserModel();
    }else{
      Map<String, dynamic> jsonData = jsonDecode(json);
      return UserModel.fromJSON(jsonData);
    }
  }

  // 내부 DB Open Function
  static Future<void> open() async {
    m_Pref ??= await SharedPreferences.getInstance();
  }

  // 내부 DB 전체 삭제 Function
  static Future<void> clear() async {
    await open();
    await m_Pref?.clear();
  }

  // 내부 DB에 Key값이 저장되어 있으면 데이터 삭제
  static Future<void> remove(String key) async {
    await open();
    await m_Pref?.remove(key);
    await m_Pref?.commit();
  }

  // 내부 DB에 Key값과 String데이터를 저장
  static Future<void> putString(String key, String value) async {
    await open();
    await m_Pref?.setString(key, value);
  }

  // 내부 DB에 Key값과 Int 데이터를 저장
  static Future<void> putInt(String key, int value) async {
    await open();
    await m_Pref?.setInt(key, value);
  }

  // 내부 DB에 Key값과 Boolean 데이터를 저장
  static Future<void> putBool(String key, bool value) async {
    await open();
    m_Pref?.setBool(key, value);
  }

  // 내부 DB에 Key값으로 데이터 가져오기
  static Future<String?> get(String key) async {
    await open();
    return m_Pref?.getString(key);
  }

  // 내부 DB에 Key값과 데이터 가져오기.(데이터 없을 시 Default 값 설정)
  static Future<String?> getString(String key, String defaultValue) async {
    await open();
    return m_Pref?.getString(key)??defaultValue;
  }

  // 내부 DB에 Key값으로 Boolean 데이터 가져오기
  static Future<bool> getBoolean(String key) async {
    await open();
    return m_Pref?.getBool(key)??false;
  }

  // 내부 DB에 Key값으로 Boolean 데이터 가져오기(데이터 없을 시 Default값 설정)
  static Future<bool> getDefaultTrueBoolean(String key) async {
    await open();
    return m_Pref?.getBool(key)??true;
  }

  // 내부 DB에 Key값으로 Int 데이터 가져오기
  static Future<int>? getInt(String key,{int? defaultValue}) async {
    await open();
    defaultValue ??= 0;
    return m_Pref?.getInt(key)??defaultValue;
  }

  // 내부 DB에 Key값과 List 데이터 저장
  static Future<void> putStringList(String key, List<String>? list) async {
    await open();
    m_Pref?.setStringList(key, list??[]);
  }

  // 내부 DB에 Key값으로 List 가져오기.
  static Future<List<String>?>? getStringList(String key) async {
    await open();
    List<String>? json = await m_Pref?.getStringList(key);
    return json;
  }

  /**
     * 다국어 코드 저장
     */
  static Future<void> putCodeList(String key, String codeList) async {
    await open();
    Logger logger = Logger();
    try {
      await m_Pref?.setString(key, codeList);
    }catch(e){
      logger.e(e);
    }
  }

}