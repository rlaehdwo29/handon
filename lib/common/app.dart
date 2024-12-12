import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handon_project/constants/const.dart';
import 'package:handon_project/db/appdatabase.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/utils/sp.dart';

class App extends GetxController {
  final login_info = UserModel().obs;
  final language = "my".obs;

  Future<void> setLanguage(String value) async {
    await SP.putString(Const.CD_LANGUAGE, value);
    language.value = value;
    update();
  }

  Future<String> getLanguage() async {
    String? val = await SP.getString(Const.CD_LANGUAGE,"ko");
    language.value = val??"ko";
    return language.value;
  }

  Future<void> setUserInfo(String? _userId, String? login_yn, String? access_key,String? user_nm, int? last_farm_no, String? last_farm_nm, int? list_count, List<dynamic>? farm_list, bool? _autoYn) async {
    login_info.value.user_id = _userId;
    login_info.value.login_yn = login_yn;
    login_info.value.access_key = access_key;
    login_info.value.user_nm = user_nm;
    login_info.value.last_farm_no = last_farm_no;
    login_info.value.last_farm_nm = last_farm_nm;
    login_info.value.list_count = list_count;
    login_info.value.list_count = list_count;
    login_info.value.farm_list = farm_list;
    await SP.putUserModel(Const.KEY_LOGIN,login_info.value);
    update();
  }

  Future<UserModel> getUserInfo() async {
    login_info.value = await SP.getUserInfo(Const.KEY_LOGIN);
    return login_info.value;
  }

  bool isTablet(BuildContext context) {
    bool isTablet;
    double ratio = MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    if( (ratio >= 0.74) && (ratio < 1.5) )
    {
      isTablet = true;
    } else{
      isTablet = false;
    }
    return isTablet;
  }

  AppDataBase getRepository() {
    var db = AppDataBase();
    return db;
  }

}