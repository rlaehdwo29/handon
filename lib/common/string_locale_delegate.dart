
import 'package:flutter/cupertino.dart';
import 'package:handon_project/common/strings.dart';

class StringLocaleDelegate extends LocalizationsDelegate<Strings> {
  const StringLocaleDelegate();

@override
bool isSupported(Locale locale) => ['ko', 'ne', 'my' , 'km'].contains(locale.languageCode);

// 파일로 되어 있는 언어를 읽어 세팅
@override
Future<Strings> load(Locale locale) async {
  Strings _strings = Strings(locale);
  await _strings.load(locale.languageCode);

  print("Load ${locale.languageCode}");

  return _strings;
}

@override
bool shouldReload(StringLocaleDelegate old) => false;
}