import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/numberformatter.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../translations.dart';



class DialogHatcheryCreateRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogHatcheryCreateRequestState();
  }
}
class DialogHatcheryCreateRequestState extends State<DialogHatcheryCreateRequest> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController _traderTypeAheadController = TextEditingController();
  final TextEditingController _proTypeAheadController = TextEditingController();
  TextStyle notOk = TextStyle(fontFamily: 'Google sans', fontSize: 14.0, wordSpacing: 3.0, color: Colors.red);

  Future<Data> getUser = DataUser.getDataUser();
  String hatcheryName;

  String curIDPro = "", curNamePro = "";
  AsyncMemoizer<List<dynamic>> memCachePro = AsyncMemoizer();

  String curIDTrader = "", curNameTrader = "";
  AsyncMemoizer<List<dynamic>> memCacheTra = AsyncMemoizer();

  String _radioSpecies = "0";


  String _curType = "0";

  TextEditingController getExpectTime = new TextEditingController();
  TextEditingController getInputPair = new TextEditingController();
  //TextEditingController controller = new TextEditingController();
  //String filter;

  Future<List<dynamic>> _getAllProducer(String filter) async{
    List<dynamic> _listProducer = List();
    return memCachePro.runOnce(() async {
      const duration = Duration(milliseconds: 250);
      //new Timer(duration, () async {
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Producer.queryFilterNameProducer(filter)),
            encoding: Encoding.getByName("UTF-8")
        );
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic pro in jsonData) {
          _listProducer.add(pro);
        }
      //});
      return _listProducer;
    });
  }


  Future<List<dynamic>> _getAllTrader(String pattern) async{
    List<dynamic> listTraders = List();
    return memCacheTra.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Trader.queryFilterNameAllTrader(pattern)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (dynamic item in jsonData) {
        listTraders.add(item);
      }
      return listTraders;
    });
  }


  void changedDropDownTypes(String selectedType) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _curType = selectedType;
    });
  }
  void _handleRadioSpecies(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _radioSpecies = value;
    });
  }
  _sendRequest(BuildContext context,String IDHat) async {
    if(getInputPair.text.toString().length != 0 && getExpectTime.text.toString().length != 0 &&
        curIDTrader != "" && curIDPro != "") {
      String species = _radioSpecies;
      int numberOfPair = int.parse(getInputPair.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String expectedTime = function.convertDefaultToDateCSDL(getExpectTime.text);
      String types = _curType;
      if(numberOfPair > 0) {
        ProgressDialog pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
        pr.style(
          message: Translations.of(context).text('wait'),
        );
        pr.show();
        var _checkInternet = function.checkInternet();
        _checkInternet.then((onValue) async {
          if(onValue){
            http.Response response = await http.post(
                Api.urlGetDataByPost,
                headers: {
                  "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
                  "Content-Type": "application/x-www-form-urlencoded",
                  "cache-control": "no-cache"
                },
                body: utf8.encode(Request.query_InsertNewRequest(
                    IDHat,
                    curIDTrader,
                    species,
                    numberOfPair,
                    expectedTime,
                    curIDPro,
                    types)),
                encoding: Encoding.getByName("UTF-8")
            );
            var p = response.body.indexOf("[");
            var e = response.body.lastIndexOf("]");
            var result = response.body.substring(p, e + 1);
            if (result.contains("REQUE")) {
              var jsonData = json.decode(result);
              Data data = Data.fromJson(jsonData[0]);
              String group = curIDTrader;
              Future.delayed(Duration(seconds: 3)).then((value) {
                pr.hide().whenComplete(() {
                  function.pushNotification(
                      context, '$group^request^${data.att1.toString()}^$hatcheryName');
                  Toast.show(Translations.of(context).text('sent'), context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                  Navigator.pop(context);
                });
              });
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
      }else{
        Toast.show(Translations.of(context).text('error'), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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
    getUser.then((onValue){
      setState(() {
        hatcheryName = onValue.att4.toString();
      });

    });
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
    final data = InheritedProvider.of<Data>(context);
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      key: _scaffoldKey,
      //resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        title: Text(Translations.of(context).text('request'),
          style: themeData.primaryTextTheme.caption,
        ),
        centerTitle: true,
        flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2db7d1), Color(0xff55ceb1)],
              ),
            )
        ),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                  child:  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(Translations.of(context).text('trader'),style: themeData.primaryTextTheme.display4,),
                        flex: 2,
                      ),
                      //ViewsWidget.buildTypeAHead(themeData, this._traderTypeAheadController, curIDTrader, curNameTrader, memCacheTra, _getAllTrader)
                      Expanded(
                        flex: 4,
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: TypeAheadFormField(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: this._traderTypeAheadController,
                                style:  curIDTrader == ""  ? notOk : themeData.primaryTextTheme.display3,
                                decoration: InputDecoration(
                                  hintText: Translations.of(context).text('select_trader'),
                                ),
                              ),
                              getImmediateSuggestions: true,
                              suggestionsCallback: (pattern) {
                                if(curNameTrader != pattern){
                                  setState(() {
                                    curIDTrader = "";
                                  });

                                }
                                memCacheTra = AsyncMemoizer();
                                return _getAllTrader(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                dynamic list = suggestion;
                                String name = list['att2'];
                                return ListTile(
                                  title: Text(name,style:  themeData.primaryTextTheme.display3,),
                                );
                              },
                              noItemsFoundBuilder: (context) {
                                return Text(Translations.of(context).text("no_results_found"),style:  notOk,);
                              },
                              errorBuilder: (context,object) {
                                return Text(Translations.of(context).text("error"),style:  notOk,);
                              },
                              hideOnLoading: false,
                              transitionBuilder: (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                dynamic list = suggestion;
                                String id = list['att1'];
                                String name = list['att2'];
                                setState(() {
                                  curIDTrader = id;
                                  curNameTrader = name;
                                  this._traderTypeAheadController.text = name;
                                });

                              },

                              onSaved: (value){
                                print('onSaved $value');
                                //this._typeAheadController.text = value;
                              }
                          ),
                        ),

                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                  child:  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(Translations.of(context).text('producer'),style: themeData.primaryTextTheme.display4),
                      ),
                      Expanded(
                        flex: 4,
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: TypeAheadFormField(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: this._proTypeAheadController,
                                style:  curIDPro == ""  ? notOk : themeData.primaryTextTheme.display3,
                                decoration: InputDecoration(
                                  hintText: Translations.of(context).text('select_producer'),
                                ),
                              ),
                              getImmediateSuggestions: true,
                              suggestionsCallback: (pattern) {
                                if(curNamePro != pattern){
                                  setState(() {
                                    curIDPro = "";
                                  });
                                }
                                memCachePro = AsyncMemoizer();
                                return _getAllProducer(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                dynamic list = suggestion;
                                String name = list['att2'];
                                return ListTile(
                                  title: Text(name,style:  themeData.primaryTextTheme.display3,),
                                );
                              },
                              noItemsFoundBuilder: (context) {
                                return Text(Translations.of(context).text("no_results_found"),style:  notOk,);
                              },
                              errorBuilder: (context,object) {
                                return Text(Translations.of(context).text("error"),style:  notOk,);
                              },
                              hideOnLoading: false,
                              transitionBuilder: (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                dynamic list = suggestion;
                                String id = list['att1'];
                                String name = list['att2'];
                                setState(() {
                                  curIDPro = id;
                                  curNamePro = name;
                                  this._proTypeAheadController.text = name;
                                });

                              },
                              onSaved: (value){
                                print('onSaved $value');
                                //this._typeAheadController.text = value;
                              }
                          ),
                        ),
                      )

                    ],
                  ),
                ),

                Padding(
                    padding: EdgeInsets.fromLTRB(10.0,10.0,0.0,5.0),
                    child: Text(Translations.of(context).text('species'),style: themeData.primaryTextTheme.display4)
                ),
                ViewsWidget.buildRadioSpecies(context, _radioSpecies, _handleRadioSpecies,themeData),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                  child:  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(Translations.of(context).text('type'),style: themeData.primaryTextTheme.display4),
                        flex: 2,
                      ),
                      ViewsWidget.buildDropDownListString( function.listDropdownMenuTypes(context) ,_curType, changedDropDownTypes,themeData)
                    ],
                  ),
                ),
                ViewsWidget.buildInputNumberRow(context, getInputPair, 'number_of_pair', 'hint_number_of_pair', themeData),
                ViewsWidget.selectDateTimePicker(context,getExpectTime,'expected_deli_date', themeData),
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
                            _sendRequest(context, data.att1.toString());
                          },
                          child: Text(Translations.of(context).text('send'),
                              textAlign: TextAlign.center,
                              style: themeData.primaryTextTheme.button),
                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          )
      )
    );
  }
}
