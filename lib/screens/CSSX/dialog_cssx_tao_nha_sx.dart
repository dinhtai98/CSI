import 'dart:async';
import 'package:async/async.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';

import '../../translations.dart';




class DialogCSSXTaoNhaSX extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogCSSXTaoNhaSXState();
  }
}
class DialogCSSXTaoNhaSXState extends State<DialogCSSXTaoNhaSX> {

  DateTime selc = DateTime.now();
  String idKhuSX;

  int _radioFunc = -1;
  TextEditingController controllerNameCluster = new TextEditingController(),
    controllerYearEstablish = new TextEditingController(),
    controllerGPS = new TextEditingController(), controllerNTanks = new TextEditingController(),
      controllerVolume = new TextEditingController();
  void _handleFunc(int value) {
    setState(() {
      _radioFunc = value;
    });
  }
  _createNhaSX(BuildContext context,String idKhuSX) async {
    if(controllerNameCluster.text.toString().length != 0 && _radioFunc != -1 &&
        controllerNTanks.text.toString().length != 0 && controllerYearEstablish.text.toString().length != 0 &&
        controllerVolume.text.toString().length != 0) {
      String name = controllerNameCluster.text.toString();
      int totalVolume = int.parse(controllerVolume.text.replaceAll(new RegExp(r'[.,]+'),'').toString()),
      ntanks = int.parse(controllerNTanks.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String year = function.formatDateCSDL(selc);
      http.Response response = await http.post(
          Api.url_update,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryCreateNhaSX(
              name,
              _radioFunc,
              ntanks,
              totalVolume,
              year,
              idKhuSX)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf(">");
      var e = response.body.lastIndexOf("<");
      var result = response.body.substring(p + 1, e);
      if (result.contains("1")) {
        Toast.show(Translations.of(context).text('saved'), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      }
    }else{
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    idKhuSX = InheritedProvider.of<Data>(context).att1.toString();
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      //resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        title: Text(Translations.of(context).text('create_production_unit')),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ViewsWidget.buildInputRow(context, controllerNameCluster, 'name_of_production_unit', 'enter_name_of_production_unit', themeData),
            //func
            buildDesignatedFunc(context,_radioFunc,_handleFunc,themeData),
            ViewsWidget.buildInputNumberRow(context, controllerNTanks, 'number_of_tanks', 'enter_number_of_tanks', themeData),
            ViewsWidget.buildInputNumberRow(context, controllerVolume, 'total_working_volume', 'enter_total_working_volume', themeData),
            ViewsWidget.buildInputYearRow(context, controllerYearEstablish, 'establish_year', 'enter_establish_year', _yearPicker,themeData),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 25.0),
                  width: 120,
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Color(0xff01A0C7),
                    child: MaterialButton(
                      //minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: (){
                        _createNhaSX(context, idKhuSX);
                      },
                      child: Text(Translations.of(context).text('save'),
                          textAlign: TextAlign.center,
                          style: themeData.primaryTextTheme.button),
                    ),
                  ),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
  _yearPicker() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Container(
                width: 100,
                height: 100,
                child: YearPicker(
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  selectedDate: selc,
                  onChanged: (date) {
                    setState(() {
                      selc = date;
                      controllerYearEstablish.text = selc.year.toString();
                    });
                    Navigator.of(context).pop(false);
                  },
                ),
              ));
        });
  }
  static Widget buildDesignatedFunc(BuildContext context,int _radioFunc, _handleRadioFunc, ThemeData themeData){
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child:  Text(
              Translations.of(context).text('designated_function'),
              style: themeData.primaryTextTheme.display4),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  new Radio(
                    value: 1,
                    groupValue: _radioFunc,
                    onChanged: _handleRadioFunc,
                  ),
                  new Text(
                    'Nuôi tôm bố mẹ',
                    style: themeData.primaryTextTheme.display3,
                  ),
                ],
              ),Row(
                children: <Widget>[
                  new Radio(
                    value: 2,
                    groupValue: _radioFunc,
                    onChanged: _handleRadioFunc,
                  ),
                  new Text(
                    'Cho đẻ thu nauplii',
                    style: themeData.primaryTextTheme.display3,
                  ),
                ],
              ),Row(
                children: <Widget>[
                  new Radio(
                    value: 3,
                    groupValue: _radioFunc,
                    onChanged: _handleRadioFunc,
                  ),
                  new Text(
                    'Cả hai',
                    style: themeData.primaryTextTheme.display3,
                  ),
                ],
              ),



            ],
          )
        )
      ],
    );
  }
}

