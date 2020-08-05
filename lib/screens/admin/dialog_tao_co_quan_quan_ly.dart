import 'dart:async';
import 'package:async/async.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/coquanquanly.dart';
import 'package:flutter_helloworld/queries/diaphuong.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/screens/signup/success_signup.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:postgres/postgres.dart';
import '../../translations.dart';
import 'danh_sach_province.dart';
import '../../Data/ConvertQueryResult.dart';

class DialogTaoCoQuanQuanLy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogTaoCoQuanQuanLyState();
  }
}
class TagSearchService {
  static Future<void> getSuggestions(String query, String previousSelected) async {
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

    List<dynamic> tagList = <dynamic>[];
    for(dynamic item in list) {
      Data diaphuong = Data.fromJson(item);
      tagList.add({'name': diaphuong.att2, 'value': diaphuong.att1});
    }
    return tagList;
  }
}
class DialogTaoCoQuanQuanLyState extends State<DialogTaoCoQuanQuanLy> {
  List<String> listTitleType = ['directorate_of_fisheries', 'department_of_animal_health', 'customs', 'local_government'];
  int typeCoQuanQuanLy = -1;
  String title = "";
  ProgressDialog pr;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List _myActivities;
  List<dynamic> allProvinces = [];

  String displayProvince = '';
  String valueProvince = '';

  TextEditingController controllerName = new TextEditingController(), controllerProvince = new TextEditingController();

  int _radioManagementLevel = 0;
  void _handleManagementLevel(int value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _radioManagementLevel = value;
    });
  }
  Future<void> getSuggestions() async {
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

    allProvinces.clear();
    //List<dynamic> tagList = <dynamic>[];
    for(dynamic item in list) {
      Data diaphuong = Data.fromJson(item);
      allProvinces.add({'display': diaphuong.att2, 'value': diaphuong.att1});
    }
  }
  _createCoQuanQuanLy(BuildContext context) async {
    var _checkInternet = function.checkInternet();
    _checkInternet.then((onValue) async {
      if (onValue) {
        if(controllerName.text.length != 0 && (_radioManagementLevel == 1 ||
            (_radioManagementLevel == 2 && _myActivities.length > 0) || (_radioManagementLevel == 3 && valueProvince != '' ))) {
          pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
          pr.style(
            message: Translations.of(context).text('please_wait'),
          );
          pr.show();

          String name = controllerName.text.toString();
          List dataProvinces = [];
          if(_radioManagementLevel == 2){
            dataProvinces = _myActivities;
          }else if(_radioManagementLevel == 3){
            dataProvinces.add(valueProvince);
          }
          http.Response response = await http.post(
              Api.urlGetDataByPost,
              headers: {
                "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
                "Content-Type": "application/x-www-form-urlencoded",
                "cache-control": "no-cache"
              },
              body: utf8.encode(CoQuanQuanLy.queryDangKyCoQuanQuanLy(name, dataProvinces.join(","), typeCoQuanQuanLy, _radioManagementLevel)),
              encoding: Encoding.getByName("UTF-8")
          );
          print(response.body);
          var p = response.body.indexOf(">");
          var e = response.body.lastIndexOf("<");
          var result = response.body.substring(p + 1, e);
          print(result);
          if (result.contains("CSIID")) {
            Future.delayed(Duration(seconds: 3)).then((value) {
              pr.hide().whenComplete(() {
                var jsonData = json.decode(result);
                Data data = Data.fromJson(jsonData[0]);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SuccessSignup(username: data.att1.toString(),typeSignup: 1,)));
              });
            });
          }else{
            pr.hide();
            Toast.show(Translations.of(context).text('error'), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        }else{
          Toast.show(Translations.of(context).text('please_input'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }else{
        _scaffoldKey.currentState.removeCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(Translations.of(context).text('no_internet')),
              duration: Duration(seconds: 1),
            ));
      }
    });
  }
  @override
  void initState() {
    super.initState();
    getSuggestions();
    _myActivities = [];
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
    typeCoQuanQuanLy = InheritedProvider.of<int>(context);
    title = Translations.of(context).text(listTitleType[typeCoQuanQuanLy - 1]);
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      key: _scaffoldKey,
      //resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        title: Text(title, style: themeData.primaryTextTheme.caption,),
      ),
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ViewsWidget.buildInputRow(context, controllerName, 'name_authority', 'hint_name_authority', themeData),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(Translations.of(context).text('management_level'),style:themeData.primaryTextTheme.display4)
              ),
              Row(
                children: <Widget>[
                  new Radio(
                    value: 1,
                    groupValue: _radioManagementLevel,
                    onChanged: _handleManagementLevel,
                  ),
                  new Text(
                    Translations.of(context).text('state'),
                    style: themeData.primaryTextTheme.display3,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  new Radio(
                    value: 2,
                    groupValue: _radioManagementLevel,
                    onChanged: _handleManagementLevel,
                  ),
                  new Text(
                    Translations.of(context).text('zone'),
                    style: themeData.primaryTextTheme.display3,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  new Radio(
                    value: 3,
                    groupValue: _radioManagementLevel,
                    onChanged: _handleManagementLevel,
                  ),
                  new Text(
                    Translations.of(context).text('province'),
                    style: themeData.primaryTextTheme.display3,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                child: _radioManagementLevel < 2 ? Text('') : ( _radioManagementLevel == 2 ? widgetZone(themeData) : widgetProvince(themeData))
              ),
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
                          _createCoQuanQuanLy(context);
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
      ),
    );
  }
  Widget widgetZone(ThemeData themeData){
    return MultiSelectFormField(
      autovalidate: false,
      titleText: Translations.of(context).text('zone'),
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Please select one or more options';
        }
      },
      dataSource: allProvinces,
      textField: 'display',
      valueField: 'value',
      okButtonLabel: 'OK',
      cancelButtonLabel: 'CANCEL',
      // required: true,
      hintText: 'Please choose one or more',
      //value: _myActivities,
      initialValue: _myActivities,
      onSaved: (value) {
        if (value == null) return;
        setState(() {
          _myActivities = value;
        });
      },
    );
  }
  Widget widgetProvince(ThemeData themeData){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Text(
              Translations.of(context).text('province'),
              style: themeData.primaryTextTheme.display4),
          flex: 2,
        ),
        Expanded(
          flex: 4,
          child: TextFormField(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DialogDanhSachDiaPhuong(displayProvince: displayProvince,valueProvince: valueProvince,), fullscreenDialog: true),
                ).then((onValue){
                  if(onValue != null) {
                    setState(() {
                      displayProvince = onValue[0];
                      valueProvince = onValue[1];
                      controllerProvince.text = displayProvince;
                    });
                  }
                });
              },
              style: themeData.primaryTextTheme.display3,
              controller: controllerProvince,
              decoration: InputDecoration(
                //contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                hintText: Translations.of(context).text('select_province'),
                //border:
                //OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
              )
          ),
        )
        //,
      ],
    );
  }
}

