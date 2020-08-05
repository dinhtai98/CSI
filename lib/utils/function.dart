import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

import '../translations.dart';
import 'api.dart';

class function{
  static Future<bool> checkInternet() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
  static String convertDateCSDLToDateTimeDefault(String dateCSDL) {
    DateFormat defaultDate = new DateFormat("dd/MM/yyyy hh:mm a");
    DateFormat defaultCSDL = new DateFormat("MM/dd/yyyy hh:mm:ss a");
    return defaultDate.format(defaultCSDL.parse(dateCSDL));
  }
  static String convertDateCSDLToDateTime(String dateCSDL){
    DateFormat defaultDate = new DateFormat("yyyy/MM/dd hh:mm:ss.SSS'Z'");
    DateFormat defaultCSDL = new DateFormat("MM/dd/yyyy hh:mm:ss a");
    return defaultCSDL.format(defaultDate.parse(dateCSDL));
  }
  static String convertDateCSDLToYear(String dateCSDL) {
    DateFormat defaultDate = new DateFormat("yyyy");
    DateFormat defaultCSDL = new DateFormat("MM/dd/yyyy hh:mm:ss a");
    return defaultDate.format(defaultCSDL.parse(dateCSDL));
  }
  static String convertTimeStampCSDLToYear(String dateCSDL){
    DateFormat defaultDate = new DateFormat("yyyy");
    DateFormat defaultCSDL = new DateFormat("dd/MM/yyyy hh:mm:ss");
    return defaultDate.format(defaultCSDL.parse(dateCSDL));
  }
  static String convertDateCSDLToDateDefault(String dateCSDL) {
    DateFormat defaultDate = new DateFormat("dd/MM/yyyy");
    DateFormat defaultCSDL = new DateFormat("MM/dd/yyyy hh:mm:ss a");
    return defaultDate.format(defaultCSDL.parse(dateCSDL));
  }
  static String convertDefaultToDateCSDL(String dateDefault) {
    DateFormat defaultDate = new DateFormat("dd/MM/yyyy hh:mm a");
    DateFormat defaultCSDL = new DateFormat("yyyy-MM-dd HH:mm:ss");
    return defaultCSDL.format(defaultDate.parse(dateDefault));
  }
  static String convertDateToDateCSDL(String dateDefault) {
    DateFormat defaultDate = new DateFormat("dd/MM/yyyy");
    DateFormat defaultCSDL = new DateFormat("yyyy-MM-dd hh:mm:ss");
    return defaultCSDL.format(defaultDate.parse(dateDefault));
  }
  static String convertTime24ToAPM(String dateDefault) {
    DateFormat defaultTime24 = new DateFormat("hh:mm:ss");
    DateFormat defaultTime = new DateFormat("hh:mm a");
    return defaultTime.format(defaultTime24.parse(dateDefault));
  }
  static String formatDateTime(DateTime date ){
    DateFormat defaultDate = new DateFormat("dd/MM/yyyy hh:mm a");
    return defaultDate.format(date).toString();
  }
  static String formatDate(DateTime date ){
    DateFormat defaultDate = new DateFormat("dd/MM/yyyy");
    return defaultDate.format(date).toString();
  }
  static String formatDateCSDL(DateTime date ){
    DateFormat defaultDate = new DateFormat("yyyy-MM-dd");
    return defaultDate.format(date).toString();
  }
  static List getTypes(BuildContext context) {
    List<String> list = new List();
    list.add(Translations.of(context).text('Wild_caught_Local'));
    list.add(Translations.of(context).text('Wild_caught_Imported'));
    list.add(Translations.of(context).text('Genetically_improved_SPF'));
    list.add(Translations.of(context).text('Genetically_improved_SPR'));
    return list;
  }
  static String getSpecies(BuildContext context, String k){
    if(k == "1"){
      return Translations.of(context).text('penaeus_vanamei');
    }else if(k == "2")
      return Translations.of(context).text('penaeus_monodon');
    return '${Translations.of(context).text('penaeus_vanamei')} & ${Translations.of(context).text('penaeus_monodon')}';
  }
  static String getType(BuildContext context, String k){
    switch(k){
      case "0":
        return Translations.of(context).text('Wild_caught_Local');
      case "1":
        return Translations.of(context).text('Wild_caught_Imported');
      case "2":
        return Translations.of(context).text('Genetically_improved_SPF');
      case "3":
        return Translations.of(context).text('Genetically_improved_SPR');
    }
    return null;
  }
  static void openDateTimePicker(BuildContext context, TextEditingController textController){
    FocusScope.of(context).requestFocus(new FocusNode());
    Locale myLocale = Localizations.localeOf(context);
    DatePicker.showDateTimePicker(context,
        showTitleActions: true, onChanged: (date) {
          //print('change $date');
        }, onConfirm: (date) {
          textController.text = '${formatDateTime(date)}';
        }, currentTime: DateTime.now(), locale: myLocale.languageCode == 'en' ? LocaleType.en : LocaleType.vi);
  }
  static void openDatePicker(BuildContext context, TextEditingController textController){
    FocusScope.of(context).requestFocus(new FocusNode());
    Locale myLocale = Localizations.localeOf(context);
    DatePicker.showDatePicker(context,
        showTitleActions: true, onChanged: (date) {
          //print('change $date');
        }, onConfirm: (date) {
          textController.text = '${formatDate(date)}';
        }, currentTime: DateTime.now(), locale: myLocale.languageCode == 'en' ? LocaleType.en : LocaleType.vi);
  }
  static String formatNumber(String s){
    var formatter = new NumberFormat("#,###");
    int number = int.parse(s);
    return formatter.format(number);
  }
  static String formatpercentage(double s){
    final formatter = new NumberFormat("##.##");
    //double number = double.parse(s);
    return formatter.format(s);
  }
  static String statusDAHCustomClearance(BuildContext context, String s){
    if(s == "1")
      return Translations.of(context).text('approved');
    return Translations.of(context).text('unapproved');
  }
  static List<DropdownMenuItem<String>> listDropdownMenuTypes(BuildContext context){
    List<DropdownMenuItem<String>> _dropDownTypes = List();
    List<String> _listTypes = function.getTypes(context);
    for (int i = 0 ; i < _listTypes.length; i++) {
      _dropDownTypes.add(new DropdownMenuItem(
          value: i.toString(),
          child: new Text(_listTypes[i])
      ));
    }
    return _dropDownTypes;
  }
  static pushNotification(BuildContext context, String query) async {
    http.Response response = await http.post(
        Api.url_push,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(query),
        encoding: Encoding.getByName("UTF-8")
    );
    var p = response.body.indexOf(">");
    var e = response.body.lastIndexOf("<");
    var result = response.body.substring(p + 1, e);

  }
  static String getTypeOfBusinessCSSX(String type){
    String s = '';
    switch(type){
      case "1":
        s = 'Sản xuất';
        break;
      case "2":
        s = 'Sản xuất & Kinh doanh';
        break;
      case "3":
        s = 'Kinh doanh';
        break;
    }
    return s;
  }
  static String getSpeciesProducing(BuildContext context, String species){
    String s = '';
    switch(species){
      case "1":
        s = Translations.of(context).text('penaeus_monodon');
        break;
      case "2":
        s = Translations.of(context).text('penaeus_vanamei');
        break;
      case "3":
        s = Translations.of(context).text('penaeus_merguiensis');
        break;
      case "4":
        s = Translations.of(context).text('penaeus_indicus');
        break;
      case "5":
        s = Translations.of(context).text('penaeus_chinensis');
        break;
      case "6":
        s = Translations.of(context).text('penaeus_japonicus');
        break;
      case "7":
        s = Translations.of(context).text('macrobrachium_rosenbergii');
        break;
      case "8":
        s = Translations.of(context).text('shrimp_other');
        break;
    }
    return s;
  }
  static String getListSpeciesProducing(BuildContext context, String species){
    List<String> list = species.split(',');
    List<String> listSpecies = [];
    for(String spe in list){
      listSpecies.add(getSpeciesProducing(context,spe));
    }
    return listSpecies.join(", ");
  }
}