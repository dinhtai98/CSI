import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show  rootBundle;



class Translations {
  Translations(this.locale);

  final Locale locale;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  Map<String, dynamic> _sentences;

  Future<bool> load() async {
    print('languageCode: ${this.locale.languageCode}');

    String data = await rootBundle.loadString("locale/i18n_${locale.languageCode}.json");
    print('$data');

    this._sentences = json.decode(data);
    return true;
  }

  String text(String key) {
    if (key == null) {
      return '...';
    }
    return this._sentences[key];
  }
}
class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en','vi'].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) async {
    print("locale: $locale");
    Translations localizations = new Translations(locale);
    await localizations.load();

    print("Load ${locale.languageCode}");

    return localizations;
  }

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}