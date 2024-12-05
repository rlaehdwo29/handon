import 'package:dio/dio.dart' ;
import 'package:retrofit/retrofit.dart';

import '../common/config_url.dart';

part 'rest.g.dart';

@RestApi(baseUrl: SERVER_URL)
abstract class Rest {
  factory Rest(Dio dio, {String baseUrl}) = _Rest;

/**
 * 로그인
 */
  @POST(URL_LOGIN)
  Future<HttpResponse> login(
    @Query("site_gubun") String? site_gubun,
    @Query("user_id") String? user_id,
    @Query("password") String? password
  );

/**
 * 교배예정돈 List
 */
  @POST(URL_SOWLIST)
  Future<HttpResponse> getSowList(
      @Query("access_key") String? access_key ,
      @Query("cmd") String? cmd ,
      @Query("site_gubun") String? site_gubun,
      @Query("user_id") String? user_id ,
      @Query("farm_no") int? farm_no,
      @Query("key_word") String? key_word,
      @Query("mother_no") int? mother_no
  );

  @POST(URL_SOW_DETAIL)
  Future<HttpResponse> getSowDetail(
      @Query("access_key") String? access_key,
      @Query("cmd") String? cmd ,
      @Query("site_gubun") String? site_gubun,
      @Query("user_id") String? user_id ,
      @Query("farm_no") int? farm_no,
      @Query("mother_no") int? mother_no
      );

  /**
   * 교배 List
   */
  @POST(URL_WORKLIST)
  Future<HttpResponse> getWorkList(
      @Query("access_key") String? access_key,
      @Query("cmd") String? cmd,
      @Query("site_gubun") String? site_gubun,
      @Query("user_id") String? user_id,
      @Query("farm_no") int? farm_no,
      @Query("start_ymd") String? start_ymd,
      @Query("end_ymd") String? end_ymd
      );

  /**
   * 교배예정돈 저장
   */
  @POST(URL_SAVE)
  Future<HttpResponse> saveSow(
      @Query("access_key") String? access_key ,
      @Query("cmd") String? cmd ,
      @Query("site_gubun") String? site_gubun,
      @Query("user_id") String? user_id ,
      @Query("farm_no") int? farm_no,
      @Query("work_ymd") String? work_ymd,
      @Query("mother_no") int? mother_no,
      {
        @Query("real_count") int? real_count,
        @Query("dead_count") int? dead_count,
        @Query("mummy_count") int? mummy_count,
        @Query("selection_count") int? selection_count,
        @Query("wean_count") int? wean_count,
        @Query("lactation_dead_count") int? lactation_dead_count,

        @Query("out_gbn") String? out_gbn,
        @Query("out_detail_gbn") String? out_detail_gbn,
        @Query("out_reason") String? out_reason,
        @Query("accident_kind") String? accident_kind,
      }

      );

  @POST(URL_CODE)
  Future<HttpResponse> getCode(
      @Query("cmd") String? cmd ,
      @Query("site_gubun") String? site_gubun,
      {
        @Query("access_key") String? access_key ,
        @Query("user_id") String? user_id ,
        @Query("farm_no") int? farm_no,
      }
      );

}