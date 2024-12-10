// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _Rest implements Rest {
  _Rest(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://112.171.80.94:8000/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<HttpResponse<dynamic>> login(
    site_gubun,
    user_id,
    password,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'site_gubun': site_gubun,
      r'user_id': user_id,
      r'password': password,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'login',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getSowList(
    access_key,
    cmd,
    site_gubun,
    user_id,
    farm_no,
    key_word,
    mother_no,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'access_key': access_key,
      r'cmd': cmd,
      r'site_gubun': site_gubun,
      r'user_id': user_id,
      r'farm_no': farm_no,
      r'key_word': key_word,
      r'mother_no': mother_no,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'sow_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getSowDetail(
    access_key,
    cmd,
    site_gubun,
    user_id,
    farm_no,
    mother_no,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'access_key': access_key,
      r'cmd': cmd,
      r'site_gubun': site_gubun,
      r'user_id': user_id,
      r'farm_no': farm_no,
      r'mother_no': mother_no,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'sow_detail',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getWorkList(
    access_key,
    cmd,
    site_gubun,
    user_id,
    farm_no,
    start_ymd,
    end_ymd,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'access_key': access_key,
      r'cmd': cmd,
      r'site_gubun': site_gubun,
      r'user_id': user_id,
      r'farm_no': farm_no,
      r'start_ymd': start_ymd,
      r'end_ymd': end_ymd,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'work_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> saveSow(
    access_key,
    cmd,
    site_gubun,
    user_id,
    farm_no,
    work_ymd,
    mother_no, {
    real_count,
    dead_count,
    mummy_count,
    selection_count,
    wean_count,
    lactation_dead_count,
    out_gbn,
    out_detail_gbn,
    out_reason,
    accident_kind,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'access_key': access_key,
      r'cmd': cmd,
      r'site_gubun': site_gubun,
      r'user_id': user_id,
      r'farm_no': farm_no,
      r'work_ymd': work_ymd,
      r'mother_no': mother_no,
      r'real_count': real_count,
      r'dead_count': dead_count,
      r'mummy_count': mummy_count,
      r'selection_count': selection_count,
      r'wean_count': wean_count,
      r'lactation_dead_count': lactation_dead_count,
      r'out_gbn': out_gbn,
      r'out_detail_gbn': out_detail_gbn,
      r'out_reason': out_reason,
      r'accident_kind': accident_kind,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'save',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getCode(
    cmd,
    site_gubun, {
    access_key,
    user_id,
    farm_no,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'cmd': cmd,
      r'site_gubun': site_gubun,
      r'access_key': access_key,
      r'user_id': user_id,
      r'farm_no': farm_no,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'get_code',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
