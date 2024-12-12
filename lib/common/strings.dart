import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handon_project/common/config_url.dart';
import 'package:handon_project/constants/const.dart';
import 'package:handon_project/utils/sp.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Strings {
  Strings(this.locale);

  final Locale locale;

  static Strings? of(BuildContext context) {
    return Localizations.of<Strings>(context, Strings);
  }

  Map<String, String>? _strings;

  Future<bool> load(String value) async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/assets/translations/$value.json';
      // File 객체로 데이터 읽기
      File file = File(filePath);

        await createLocale();

        String data = await file.readAsString();
        Map<String, dynamic> _result = json.decode(data);

        _strings = Map();
        _result.forEach((String key, dynamic value) {
          _strings?[key] = value.toString();
        });

        return true;
    } catch (e) {
      print('로드 중 오류 발생(S): $e');
      return false;
    }
  }



  String? get(String key) {
    return _strings?[key];
  }

  Future<void> createLocale() async {
    List<String> list  = List.empty(growable: true);
    list.add("ko");
    list.add("ne");
    list.add("my");
    list.add("km");
    for(var item in list) {
      Map<String,dynamic> data = await getCode(item);
      try {
        var server_version = int.parse(data["version"]??"0");
        var old_version = await SP.getString(item == "ne" ? Const.CD_NE_VERSION : item == "my" ? Const.CD_MY_VERSION : item == "km" ? Const.CD_KM_VERSION : Const.CD_KO_VERSION, "0");
        var old2_version = int.parse(old_version??"0");

        //Directory currentDirectory = Directory.current;
        Directory directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/assets/translations/$item.json';

        // 디렉토리와 파일 생성
        File file = File(filePath);

        if (!await file.exists()) {
          await file.create(recursive: true);
          await SP.putString(item == "ne" ? Const.CD_NE_VERSION : item == "my" ? Const.CD_MY_VERSION : item == "km" ? Const.CD_KM_VERSION : Const.CD_KO_VERSION, data["version"]);
          data.remove("version");

          String jsonString = JsonEncoder.withIndent('  ').convert(data);
          await file.writeAsString(jsonString);
          //print('JSON 파일이 생성되었습니다: $filePath');
        }else{
          if(old2_version < server_version) {
            await file.delete();
            await file.create(recursive: true);
            await SP.putString(item == "ne" ? Const.CD_NE_VERSION : item == "my" ? Const.CD_MY_VERSION : item == "km" ? Const.CD_KM_VERSION : Const.CD_KO_VERSION, data["version"]);
            data.remove("version");

            String jsonString = JsonEncoder.withIndent('  ').convert(data);
            await file.writeAsString(jsonString);
            //print('JSON 파일이 생성되었습니다: $filePath');
          }
        }

      } catch (e) {
        print('JSON 파일 생성 중 오류 발생: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getCode(String? code) async {
    Logger logger = Logger();
    final response = await http.post(headers: {
      "Content-Type" : "application/json"
    },Uri.parse('${SERVER_URL}get_code?cmd=${code == "ne" ? "LANG_NPL" : code == "my" ? "LANG_MMR" : code == "km" ? "LANG_KHM" : "LANG_KOR" }&site_gubun=K'));

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      Map<String, dynamic> jsonData = jsonDecode(decoded);
      Map<String,dynamic> jsonRealData = Map();
      jsonRealData.addAll({"version" : jsonData["list_count"].toString()});
      for(var item in jsonData["code_list"]) {
        jsonRealData.addAll({item["app_search_key"] : item["wordd"]});
      }
      return jsonRealData;
    } else {
      throw Exception('Failed to load translations');
    }
  }

}
