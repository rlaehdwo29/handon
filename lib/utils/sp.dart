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

  static Future<void> putUserModel(String key, UserModel? value) async {
    await open();
    m_Pref?.setString(key, jsonEncode(value));
  }

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

  static Future<void> open() async {
    m_Pref ??= await SharedPreferences.getInstance();
  }

  static Future<void> clear() async {
    await open();
    await m_Pref?.clear();
  }

  static Future<void> remove(String key) async {
    await open();
    await m_Pref?.remove(key);
    await m_Pref?.commit();
  }

  static Future<void> putString(String key, String value) async {
    await open();
    await m_Pref?.setString(key, value);
  }

  static Future<void> putInt(String key, int value) async {
    await open();
    await m_Pref?.setInt(key, value);
  }

  static Future<void> putBool(String key, bool value) async {
    await open();
    m_Pref?.setBool(key, value);
  }

  static Future<String?> get(String key) async {
    await open();
    return m_Pref?.getString(key);
  }

  static Future<String?> getString(String key, String defaultValue) async {
    await open();
    return m_Pref?.getString(key)??defaultValue;
  }

  static Future<bool> getBoolean(String key) async {
    await open();
    return m_Pref?.getBool(key)??false;
  }

  static Future<bool> getDefaultTrueBoolean(String key) async {
    await open();
    return m_Pref?.getBool(key)??true;
  }

  static Future<int>? getInt(String key,{int? defaultValue}) async {
    await open();
    defaultValue ??= 0;
    return m_Pref?.getInt(key)??defaultValue;
  }

  static Future<void> putStringList(String key, List<String>? list) async {
    await open();
    m_Pref?.setStringList(key, list??[]);
  }

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