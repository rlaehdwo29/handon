
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/common_util.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/interface/model/sow_model.dart';
import 'package:handon_project/interface/model/user_model.dart';
import 'package:handon_project/interface/service/dio_service.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:handon_project/utils/util.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class QRPage extends StatefulWidget {
  String? code; // mate = 교배, delivery = 분만, wean = 이유, accident = 임신사고, out = 도폐사

  QRPage({Key? key, required this.code}) : super(key:key);

  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> with WidgetsBindingObserver {

  final controller = Get.find<App>();

  final mUser = UserModel().obs;
  final searchQRModel = SowModel().obs;
  final language = "my".obs;  // ko: 한국어(Default), ne: 네팔어, my: 미얀마어, km: 캄보디아어
  ProgressDialog? pr;
  final _isScanning = false.obs;
  final qr_cd = "".obs;   // Qr코드 결과 Code
  final qr_msg = "".obs;    // Qr코드 결과 메세지

  final MobileScannerController ScanController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode]
  );

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      mUser.value = await controller.getUserInfo();
      language.value = await controller.getLanguage();
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await ScanController.dispose();
  }

  /**
   * Start Widget
   */

  // Qr코드 Widget
  Widget qrArea() {
    final scanWindow = Rect.fromCenter(
      center:  Offset(
        MediaQuery.sizeOf(context).width * 0.45,
        MediaQuery.sizeOf(context).height / 2 * 0.45,
      ),
      width: 120,
      height: 120,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: MobileScanner(
            fit: BoxFit.contain,
            controller: ScanController,
            scanWindow: scanWindow,
            onDetect: (BarcodeCapture barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              if (barcodes.isNotEmpty) {
                final scannedData = barcodes.first.displayValue;
                if (scannedData != null) {
                  _handleQRCodeDetected(scannedData);    // QR 코드 인식 후 처리 로직
                }
              }
            },
          ),
        ),
        ValueListenableBuilder(
          valueListenable: ScanController,
          builder: (context, value, child) {
            if (!value.isInitialized || !value.isRunning || value.error != null) {
              return const SizedBox();
            }

            return CustomPaint(
              painter: ScannerOverlay(scanWindow: scanWindow),
            );
          },
        ),
      ],
    );
  }




  /**
   * End Widget
   */

  /**
   * Start Function
   */

  // Qr코드가 한번에 여러개 인식하는것을 방지하기 위한 메소드.
  void _handleQRCodeDetected(String qrCodeData) async {
    if (_isScanning.value) return;

      setState(() {
        _isScanning.value = true;
      });

    try {
      print("QR Code Detected: $qrCodeData");

      // URL에서 파라미터 추출
      Uri uri = Uri.parse(qrCodeData);
      int? farmNo = int.parse(uri.queryParameters['farmNo'] ?? "0");
      int? pigNo = int.parse(uri.queryParameters['pigNo'] ?? "0");

      // QR 코드 데이터를 처리 (예: API 호출)
      await getSearchQr(farmNo, pigNo);

      // 2초 대기 후 스캔 차단 해제 (디바운싱 효과)
      await Future.delayed(Duration(seconds: 5));
    } catch (e) {
      print("Error processing QR Code: $e");
    } finally {
        _isScanning.value = false; // 스캔 잠금 해제
    }
  }

  // 조회한 QR코드의 모돈번호로 조회해서 해당 목록을 가져오는 API
  Future<void> getSearchQr(int? last_farm_no, int? mother_no) async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getSowList(mUser.value.access_key, "qr_search", "K", mUser.value.user_id, last_farm_no,null,mother_no).then((it) async {
      await pr?.hide();
      ReturnSowMap _response = DioService.dioSowResponse(it);
      logger.i("getSearchQr() Response => ${_response.list_count} || ${_response.sow_list}");
      List<SowModel>? sow = _response.sow_list;
      searchQRModel.value = sow?[0]??SowModel();
      qr_cd.value = Util.getStatusCode(widget.code, searchQRModel.value)??"";
      qr_msg.value = Util.getStatusMsg(context, widget.code, searchQRModel.value)??"";
      if(qr_cd.value == "00") {
        Future.delayed(const Duration(seconds: 2), () async {
          Navigator.of(context).pop({'code':200,'selectItem':searchQRModel.value});
        });
      }else if(qr_cd.value == "03") {
        Future.delayed(const Duration(seconds: 2), () async {
          Navigator.of(context).pop({'code':100});
        });
      }
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
      await pr?.hide();
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("getSearchQr() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("getSearchQr() default Error : => ${obj}");
          break;
      }
    });
  }

  // 임신 사고를 저장하는 API
  Future<void> saveSow(SowModel sow) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).saveSow(mUser.value.access_key, "accident_insert", "K", mUser.value.user_id, mUser.value.last_farm_no,Util.getDate(DateTime.now()), sow.mother_no, accident_kind: "01" ).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("saveSow() Response => ${_response.error}");
      if(_response.error?["error_code"] == null || _response.error?["error_code"] == "") {
        Util.toast((context.read<MenuProvider>().translate('msg_success_save_accident')));
        Navigator.of(context).pop({'code':200,'selectItem':searchQRModel.value});
      }else{
        Util.toast((context.read<MenuProvider>().translate('msg_not_match_mother_no')));    // <다국어> 일치하는 모돈 번호가 없습니다.
        Navigator.of(context).pop({'code':100});
      }
    }).catchError((Object obj) async {
      Util.toast((context.read<MenuProvider>().translate('msg_server_connection_issue')));
      switch(obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          logger.e("saveSow() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("saveSow() default Error : => ${obj}");
          break;
      }
    });
  }

  /**
   * End Function
   */

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: main_color,
          leading: IconButton(
            onPressed: () async {
              Navigator.of(context).pop({'code':100});
            },
            color: Colors.white,
            icon: Icon(Icons.arrow_back,size: 24.h,color: Colors.white),
          ),
          title:
          Consumer<MenuProvider>(
              builder: (context, menuProvider, child) {
                return Obx(() => Text(
                    // mate_manager = <다국어> 교배관리, work_manager = <다국어> 분만관리, wean_manager = <다국어> 이유관리, accident_manager = <다국어> 임신사고 관리, out_manager = <다국어> 임신사고 관리
                      widget.code == "mate" ? menuProvider.translate('mate_manager') : widget.code == "delivery" ? menuProvider.translate('work_manager') : widget.code == "wean" ? menuProvider.translate('wean_manager')  : widget.code == "accident" ? menuProvider.translate('accident_manager') : widget.code == "out" ? menuProvider.translate('out_manager') :  menuProvider.translate('individual_manager'),
                      style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize18 : styleFontSize14, Colors.white),
                    ));
              }),
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Obx(() {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20)),
              child: Column(
                children: [
                Expanded(
                    flex: 1,
                    child: qrArea()   // QR코드 Widget
                ),

                Expanded(
                    flex: 1,
                    child: Container(
                        margin: EdgeInsets.only(top: CustomStyle.getHeight(20)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: CustomStyle.getWidth(10)),
                                    child: Consumer<MenuProvider>(
                                        builder: (context, menuProvider, child) {
                                          return FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                menuProvider.translate('mother_no'),      // <다국어> 모돈번호
                                                style: CustomStyle.CustomFont(styleFontSize16, Colors.black),
                                              ));
                                        }),
                                ),
                                Text(
                                  searchQRModel.value.pig_coupon??"-",    // 모돈번호
                                  style: CustomStyle.CustomFont(styleFontSize22, Colors.black,font_weight: FontWeight.w800),
                                )
                              ],
                            ),
                            Container(
                                margin: EdgeInsets.only(top: CustomStyle.getHeight(5)),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2,color: Colors.black)
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                decoration: const BoxDecoration(
                                                    color: light_gray3,
                                                    border: Border(
                                                      right:BorderSide(color: Colors.black, width: 2),
                                                      bottom: BorderSide(color: Colors.black, width: 2),
                                                    )
                                                ),
                                                child: Consumer<MenuProvider>(
                                                    builder: (context, menuProvider, child) {
                                                      return FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            menuProvider.translate('now_parity'), //<다국어> 현재산차
                                                            style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                                          ));
                                                    }),

                                            )
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                decoration: const BoxDecoration(
                                                    color: light_gray3,
                                                    border: Border(
                                                      right: BorderSide(color: Colors.black, width: 2),
                                                      bottom: BorderSide(color: Colors.black, width: 2),
                                                    )
                                                ),
                                                child: Consumer<MenuProvider>(
                                                    builder: (context, menuProvider, child) {
                                                      return FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            menuProvider.translate('birth'),      // <다국어> 생년월일
                                                            style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                                          )
                                                      );
                                                    }),
                                            )
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                              decoration: const BoxDecoration(
                                                  color: light_gray3,
                                                border: Border(
                                                  bottom: BorderSide(color: Colors.black,
                                                      width: 2
                                                  ),
                                                )
                                              ),
                                              child: Consumer<MenuProvider>(
                                                  builder: (context, menuProvider, child) {
                                                    return FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          menuProvider.translate('pig_status'),     // <다국어> 현재상태
                                                          style: CustomStyle.CustomFont(language.value == "ko" ? styleFontSize13 : styleFontSize11, Colors.black),
                                                        ));
                                                  }),
                                            )
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        right:BorderSide(
                                                            color: Colors.black,
                                                            width: 2
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "${searchQRModel.value.parity??"-"}",   // 검색된 Qr코드 산차
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        right:BorderSide(
                                                            color: Colors.black,
                                                            width: 2
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "${searchQRModel.value.birth??"-"}",  // 검색된 생년월일
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                              child: Text(
                                                "${searchQRModel.value.pig_status??"-"}",   // 검색된 현재상태
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize13, Colors.black),
                                              )
                                            )
                                        ),
                                      ],
                                    )
                                  ],
                                )
                            ),
                            Container(
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(30)),
                              child: Text(
                                  "${qr_msg.value}",    // Qr 코드 검색 시 Return된 메세지 값을 노출
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize16, qr_cd.value == "00" ? main_color : Colors.red ,font_weight: FontWeight.w700),
                              )
                            ),

                            // Qr로 조회한 목록이 "유산"일때 버튼 노출
                            qr_cd.value == "04" ?
                            Container(
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(30)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        await saveSow(searchQRModel.value);     // 임신사고 저장 API
                                      },
                                      child: Container(
                                      width: CustomStyle.getWidth(100),
                                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(20)),
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          color: main_color
                                      ),
                                      child: Text(
                                        context.read<MenuProvider>().translate('yes'),  // <다국어> 예
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                      )
                                    )
                                  ),
                                  InkWell(
                                      onTap: (){
                                          Navigator.of(context).pop({'code':100});
                                      },
                                      child: Container(
                                        width: CustomStyle.getWidth(100),
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10), horizontal: CustomStyle.getWidth(20)),
                                        decoration: const BoxDecoration(
                                          borderRadius:  BorderRadius.all(Radius.circular(10)),
                                          color: Color(0xfff99245)
                                        ),
                                        child: Text(
                                          context.read<MenuProvider>().translate('no'),     // <다국어> 아니오
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize14, Colors.white),
                                        )
                                      )
                                  ),
                                ],
                              ),
                            ) : const SizedBox()
                        ])
                    )
                )
              ],
              )

            );
          }),
        ),
      )
    );
  }
}

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    // QR코드 Scanner 준비 사용 여부 Msg
    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Scanning is unsupported on this device';
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannedBarcodeLabel extends StatelessWidget {
  const ScannedBarcodeLabel({
    super.key,
    required this.barcodes,
  });

  final Stream<BarcodeCapture> barcodes;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: barcodes,
      builder: (context, snapshot) {
        final scannedBarcodes = snapshot.data?.barcodes ?? [];

        return Text(
          scannedBarcodes.first.displayValue ?? 'No display value.',
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.white),
        );
      },
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow || borderRadius != oldDelegate.borderRadius;
  }
}