import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handon_project/common/app.dart';
import 'package:handon_project/common/string_locale_delegate.dart';
import 'package:handon_project/common/style_theme.dart';
import 'package:handon_project/db/appdatabase.dart';
import 'package:handon_project/interface/service/main_service.dart';
import 'package:handon_project/page/bridge_page.dart';
import 'package:handon_project/provider/menu_provider.dart';
import 'package:provider/provider.dart';

late AppDataBase database;

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);    // App Splash 화면 시작
  await EasyLocalization.ensureInitialized();

  database = AppDataBase();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MyApp()));
  FlutterNativeSplash.remove();   // App Splash 화면 제거
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  /**
   * 애플리케이션 언어 세팅 Function
   */
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);    // 언어 세팅
  }
}


class _MyAppState extends State<MyApp> {
  Locale? _locale; // 현재 앱의 로케일

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async {
      // 앱 실행 시 저장소에 저장된 언어로 세팅
      String lan = await App().getLanguage();
      _locale = Locale(lan,lan == "ko" ? "KR" : lan == "ne" ? "NE" : lan == "my" ? "MY" : "KM");
      setLocale(_locale!);
    });
  }

  // 언어 변경 Function
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.put(App());
    return MultiProvider(
      // Service 사용을 위한 정의
        providers: [
          ChangeNotifierProvider<MainService>(create: (_) => MainService()),
          ChangeNotifierProvider<MenuProvider>(create: (_) => MenuProvider())
        ],
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: ScreenUtilInit(
            designSize: const Size(360, 750),
            builder: (_, child) => MaterialApp(
              title: 'handon_flutter',
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                StringLocaleDelegate(),
              ],
              supportedLocales: const [ // 사용 언어 정의
                Locale('ko', 'KO'),
                Locale('ne', 'NE'),
                Locale('my', 'MY'),
                Locale('km', 'KM')
              ],
              locale: _locale,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                appBarTheme: ThemeData.light()
                    .appBarTheme
                    .copyWith(backgroundColor: light_gray24),
                primaryColor: light_gray24,
                textTheme: TextTheme(bodyLarge: CustomStyle.baseFont()),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                fontFamily: 'NotoSansKR',
              ),
              themeMode: ThemeMode.system,
              home: GetBuilder<App>(
                init: App(),
                builder: (_) {
                  return const BridgePage();    // 초기 화면 정의
                },
              ),
            ),
          ),
        ));
  }
}