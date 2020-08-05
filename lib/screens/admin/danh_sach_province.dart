import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/diaphuong.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_helloworld/utils/function.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:postgres/postgres.dart';
import '../../translations.dart';
import '../../Data/ConvertQueryResult.dart';

class DialogDanhSachDiaPhuong extends StatefulWidget {

  final String displayProvince;
  final String valueProvince;
  DialogDanhSachDiaPhuong({this.displayProvince,this.valueProvince});

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogDanhSachDiaPhuongState();
  }
}

class DialogDanhSachDiaPhuongState extends State<DialogDanhSachDiaPhuong> {

  TextEditingController _controller = TextEditingController();
  TextStyle notOk = TextStyle(fontFamily: 'Google sans', fontSize: 14.0, wordSpacing: 3.0, color: Colors.red);
  String display = '', value = '';

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  Future<List> getSuggestions(String curProvinces) async {
    return memCache.runOnce(() async {
      await Future.delayed(Duration(milliseconds: 400), null);
      List<dynamic> list = List();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(DiaPhuong.queryGetAllDiaPhuong),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p,e + 1);
      list = json.decode(result);

      List<dynamic> listProvinces = List();
      //List<dynamic> tagList = <dynamic>[];
      for(dynamic item in list) {
        Data diaphuong = Data.fromJson(item);
        if(diaphuong.att1.toString() != curProvinces)
          listProvinces.add({'display': diaphuong.att2, 'value': diaphuong.att1});
      }
      return listProvinces;
    });
  }

  @override
  void initState() {
    super.initState();
    display = widget.displayProvince;
    value = widget.valueProvince;
    _controller.text = display;

  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    return Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('select_province'), style: themeData.primaryTextTheme.caption,
        ),
        centerTitle: true,
        flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
              ),
            )
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop([display,value]);
            },
            child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Xong', style: themeData.primaryTextTheme.caption,
                  ),
                )
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child:ButtonTheme(
          alignedDropdown: true,
          child: TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: this._controller,
                style:  value.trim() == ""  ? notOk : themeData.primaryTextTheme.display3,
                decoration: InputDecoration(
                  hintText: Translations.of(context).text('select_province'),
                ),
              ),
              getImmediateSuggestions: true,
              suggestionsCallback: (pattern) {
                print('pattern $pattern');
                if(display != pattern){
                  setState(() {
                    display = "";
                    value = "";
                  });
                  print('value $value, display $display');
                }
                memCache = AsyncMemoizer();
                return getSuggestions(value);
              },
              itemBuilder: (context, suggestion) {
                dynamic list = suggestion;
                String display = list['display'];
                return ListTile(
                  title: Text(display, style:  themeData.primaryTextTheme.display3,),
                );
              },
              noItemsFoundBuilder: (context) {
                return Text(Translations.of(context).text("no_results_found"),style:  notOk,);
              },
              errorBuilder: (context,object) {
                return Text(Translations.of(context).text("error"),style:  notOk,);
              },
              hideOnLoading: true,
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                dynamic provinceSelected = suggestion;
                setState(() {
                  value = provinceSelected['value'].toString();
                  display = provinceSelected['display'].toString();
                  _controller.text = display;
                });

                print('value $value, display $display, controller ${_controller.text}');
              },
              onSaved: (value){
                print('onSaved $value');
                //this._typeAheadController.text = value;
              }
          ),
        ),
      ),
    );
  }

}