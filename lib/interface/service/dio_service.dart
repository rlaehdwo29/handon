import 'dart:convert';

import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/constants/const.dart';
import 'package:handon_project/constants/custom_log_interceptor.dart';
import 'package:handon_project/interface/model/breed_model.dart';
import 'package:handon_project/interface/model/code_model.dart';
import 'package:handon_project/interface/model/result_model.dart';
import 'package:handon_project/interface/model/sow_info_model.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/interface/model/work_model.dart';
import 'package:handon_project/interface/rest.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

class DioService {


  static Rest dioClient({header = false}) {
    Logger logger = Logger();
    logger.i("dioClient => ${header}");
    Dio dio = Dio()..interceptors.add(CustomLogInterceptor());
    if(header) dio.options.headers["accept"] = "application/json";
    dio.options.connectTimeout = Duration(seconds: Const.CONNECT_TIMEOUT);
    return Rest(dio);
  }

  static ReturnMap dioResponse(dynamic it) {
    Logger logger = Logger();
    ReturnMap response;
    try {
      logger.i("dioResponse() => ${it.response.data}");
      var jsonString = jsonEncode(it.response.data);
      print("Dio jsonString -> ${jsonString}");
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      print("Dio jsonData -> ${jsonData}");
      ResultModel result = ResultModel.fromJSON(jsonData);
      print("Dio response data -> ${it.response.data}");
      print("Dio response data data -> ${it.response.data["data"]}");
      if(it.response.data["success_yn"] == "Y") {
        response = ReturnMap(error: {"error_code": result.error?["error_code"], "message": result.error?["message"]});
      }else{
        response = ReturnMap(error: {"error_code": result.error?["error_code"], "message": result.error?["message"]});
      }
    }catch(e) {
      logger.e("Error => $e");
      response = ReturnMap(error: {"error_code": "500", "message" : e});
    }
    return response;
  }

  static ReturnLoginMap dioLoginResponse(dynamic it) {
    Logger logger = Logger();
    ReturnLoginMap response;
    try {
      logger.i("dioLoginResponse() => ${it.response.data}");
      if(it.response.data["access_key"] != null) {
        var jsonString = jsonEncode(it.response.data);
        print("Dio jsonString -> ${jsonString}");
        Map<String, dynamic> jsonData = jsonDecode(jsonString);
        print("Dio jsonData -> ${jsonData}");
        ResultLoginModel result = ResultLoginModel.fromJSON(jsonData);
        print("Dio response data -> ${it.response.data}");
        print("Dio response data data -> ${it.response.data["data"]}");
        response = ReturnLoginMap(site_gubun: result.site_gubun, user_id: result.user_id,login_yn:result.login_yn,access_key: result.access_key, user_nm: result.user_nm,last_farm_no: result.last_farm_no,last_farm_nm: result.last_farm_nm,list_count: result.list_count,farm_list:result.farm_list);
      }else{
        response = ReturnLoginMap(site_gubun: "400");
      }
    }catch(e) {
      logger.e("Error => $e");
      response = ReturnLoginMap(site_gubun: "500");
    }
    return response;
  }

  static ReturnSowMap dioSowResponse(dynamic it) {
    Logger logger = Logger();
    ReturnSowMap response;
      logger.i("dioSowResponse() => ${it.response.data}");
        var jsonString = jsonEncode(it.response.data);
        print("Dio jsonString -> ${jsonString}");
        Map<String, dynamic> jsonData = jsonDecode(jsonString);
        print("Dio jsonData -> ${jsonData}");
        ResultSowModel result = ResultSowModel.fromJSON(jsonData);
    try {
        print("Dio response data -> ${it.response.data} // ${result.runtimeType}");
        var list = result.sow_list as List;
        List<SowModel> itemsList = list.map((i) => SowModel.fromJSON(i)).toList();
        response = ReturnSowMap(list_count: result.list_count, sow_list: itemsList);
    }catch(e) {
      logger.e("Error => $e");
      response = ReturnSowMap(error: {"error_code": result.error?["error_code"], "message": result.error?["message"]},list_count: 0);
    }
    return response;
  }


  static ReturnCodeMap dioCodeResponse(dynamic it) {
    Logger logger = Logger();
    ReturnCodeMap response;
    logger.i("dioCodeResponse() => ${it.response.data}");
    var jsonString = jsonEncode(it.response.data);
    print("Dio jsonString -> ${jsonString}");
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    print("Dio jsonData -> ${jsonData}");
    ResultCodeModel result = ResultCodeModel.fromJSON(jsonData);
    try {
      print("Dio response data -> ${it.response.data} // ${result.runtimeType}");
      var list = result.code_list as List;
      List<CodeModel> itemsList = list.map((i) => CodeModel.fromJSON(i)).toList();
      response = ReturnCodeMap(list_count: result.list_count, code_list: itemsList);
    }catch(e) {
      logger.e("Error => $e");
      response = ReturnCodeMap(error: {"error_code": result.error?["error_code"], "message": result.error?["message"]},list_count: 0);
    }
    return response;
  }

  static ReturnSowDetailMap dioSowDetailResponse(dynamic it) {
    Logger logger = Logger();
    ReturnSowDetailMap response;
    logger.i("dioSowDetailResponse() => ${it.response.data}");
    var jsonString = jsonEncode(it.response.data);
    print("Dio jsonString -> ${jsonString}");
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    print("Dio jsonData -> ${jsonData}");
    ResultSowDetailModel result = ResultSowDetailModel.fromJSON(jsonData);
    try {
      print("Dio response data -> ${it.response.data} // ${result.runtimeType}");
      var list = result.breed_list as List;
      SowInfoModel item = SowInfoModel.fromJSON(result.sow_info);
      List<BreedModel> itemsList = list.map((i) => BreedModel.fromJSON(i)).toList();
      response = ReturnSowDetailMap(sow_info: item, list_count: result.list_count, breed_list: itemsList);
    }catch(e) {
      logger.e("Error => $e");
      response = ReturnSowDetailMap(error: {"error_code": result.error?["error_code"], "message": result.error?["message"]},list_count: 0);
    }
    return response;
  }

  static ReturnWorkMap dioWorkResponse(dynamic it) {
    Logger logger = Logger();
    ReturnWorkMap response;
    logger.i("dioWorkResponse() => ${it.response.data}");
    var jsonString = jsonEncode(it.response.data);
    print("Dio jsonString -> ${jsonString}");
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    print("Dio jsonData -> ${jsonData}");
    ResultWorkModel result = ResultWorkModel.fromJSON(jsonData);
    try {
      print("Dio response data -> ${it.response.data} // ${result.runtimeType}");
      var list = result.work_list as List;
      List<WorkModel> itemsList = list.map((i) => WorkModel.fromJSON(i)).toList();
      response = ReturnWorkMap(list_count: result.list_count, p_tot_count: result.p_tot_count, p_real_count: result.p_real_count, p_lactation_count : result.p_lactation_count, p_wean_count: result.p_wean_count, work_list: itemsList);
    }catch(e) {
      logger.e("Error => $e");
      response = ReturnWorkMap(error: {"error_code": result.error?["error_code"], "message": result.error?["message"]},list_count: 0);
    }
    return response;
  }
}

