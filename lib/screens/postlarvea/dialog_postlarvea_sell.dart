import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_input_transportation_information.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/postlarvea.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import '../../translations.dart';



class DialogPostlarveaSell extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogPostlarveaSellState();
  }
}
class DialogPostlarveaSellState extends State<DialogPostlarveaSell> {
  DateFormat defaultDate = new DateFormat("yyyy-MM-dd hh:mm");
  DateFormat defaultCSDL = new DateFormat("MM/dd/yyyy hh:mm:ss a");

  Future<Data> getUser = DataUser.getDataUser();
  List<String> getData;
  String idSub,idPre, stage,idStaff, idHatchery;
  int curNum = -1;

  TextEditingController txtNum = new TextEditingController(),
      txtNote = new TextEditingController(),txtBonus = new TextEditingController(),
      txtExpectedDate = new TextEditingController(), txtSignDate = new TextEditingController();

  int _radioBuyer = -1;
  void _handleRadioBuyer(int value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      memCacheBuyer = AsyncMemoizer();
      _radioBuyer = value;
      curNameBuyer = "";
      curIDBuyer = "";
      this._buyerTypeAheadController.text = "";
    });
  }
  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getSubBatchOfPostlarvea(String idSub) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Postlarvea.queryGetSubBatchOfPostLarvea(idSub)),
          encoding: Encoding.getByName("UTF-8")
      );
      if (response.statusCode == 200) {
        Data sub = new Data();
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        sub = Data.fromJson(jsonData[0]);
        return sub;
      }else {
        throw("");
      }
    });
  }

  final TextEditingController _buyerTypeAheadController = TextEditingController();
  String curIDBuyer = "", curNameBuyer = "";
  TextStyle notOk = TextStyle(fontFamily: 'Google sans', fontSize: 14.0, wordSpacing: 3.0, color: Colors.red);
  AsyncMemoizer<List<dynamic>> memCacheBuyer = AsyncMemoizer();

  Future<List<dynamic>> _getAllHatcheryExceptMe(String idHatchery, String filter) async{

    List<dynamic> list = List();
    return memCacheBuyer.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Hatchery.queryGetAllHatcheryExceptMe(idHatchery,filter)),
          encoding: Encoding.getByName("UTF-8")
      );
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic item in jsonData) {
          list.add(item);
        }
        return list;
      }
      throw("");
    });
  }
  Future<List<dynamic>> _getAllFarmer() async{

    List<dynamic> list = List();
    return memCacheBuyer.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Postlarvea.queryGetAllFarmer),
          encoding: Encoding.getByName("UTF-8")
      );
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        for (dynamic item in jsonData) {
          list.add(item);
        }
        return list;
      }
      throw("");
    });
  }

  _postlarveaSell(BuildContext context) async {
    if(txtNum.text.toString().length != 0 &&  curIDBuyer != "" &&
        txtExpectedDate.text.length != 0 && txtSignDate.text.length != 0) {


      String idHatReceiver = "null", idFarmer = "null";
      if(_radioBuyer == 0)
        idHatReceiver = curIDBuyer;
      else if(_radioBuyer == 1)
        idFarmer = curIDBuyer;
      int num = int.parse(txtNum.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String note = txtNote.text.toString(), bonus = txtBonus.text.toString(),
          expectedDate = function.convertDefaultToDateCSDL(txtExpectedDate.text),
          signDate = function.convertDateToDateCSDL(txtSignDate.text);
      if(num <= curNum && num > 0) {
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Postlarvea.querySellPostlarvea(
                idSub, num, idHatchery, idHatReceiver, signDate, note, idPre, stage, idFarmer, idStaff, expectedDate, bonus)),
            encoding: Encoding.getByName("UTF-8")
        );
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var jsonData = json.decode(response.body.substring(p, e + 1));
        Data result = Data.fromJson(jsonData[0]);

        if (jsonData.length > 0) {
          Toast.show(Translations.of(context).text('saved'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.pop(context);
          openDialog(context,result.att1);
        }
      }else{
        Toast.show('${Translations.of(context).text('you_have_just')} '
            '${function.formatNumber(curNum.toString())} '
            '${Translations.of(context).text('postlarvea')}',
            context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }else{
      Toast.show(Translations.of(context).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  void openDialog(BuildContext context, String idCon) {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<String>(
          child: new DialogInputTransportationInformation(),
          inheritedData: idCon,
        ),
        fullscreenDialog: true));
  }
  @override
  void initState() {
    super.initState();
    getUser.then((onValue){
      setState(() {
        idHatchery = onValue.att1.toString();
        idStaff = onValue.att10.toString();
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    getData = InheritedProvider.of<List<String>>(context);
    idSub = getData[0];
    idPre = getData[1];

    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('assignment_contract'),
            style: themeData.primaryTextTheme.caption
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
      body: SingleChildScrollView(
          child: FutureBuilder(
              future: _getSubBatchOfPostlarvea(idSub),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                } else if (snapshot.hasData) {
                  Data postlarvea = snapshot.data;
                  curNum = int.parse(postlarvea.att1.toString());
                  var dateHarvest = DateTime.parse('${defaultDate.format(defaultCSDL.parse(postlarvea.att2))}');
                  var dateCurrent = DateTime.now();
                  var difference = dateCurrent.difference(dateHarvest).inDays + 1;
                  stage = difference.toString();
                  return Column(
                    children: <Widget>[
                      ViewsWidget.buildRowDetails(context,'species', Translations.of(context).text('postlarvea')),
                      ViewsWidget.buildRowDetails(context,'cur_stage_of_postlarvea', '$difference'),
                      ViewsWidget.buildRowDetails(context,'number_of_postlarvea', '${function.formatNumber(postlarvea.att1)}'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: new Container(
                          height: 1.5,
                          color: Colors.blueGrey,
                        ),
                      ),
                      ViewsWidget.buildRadioBuyer(context, _radioBuyer  , _handleRadioBuyer,themeData),
                      Visibility(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Text(_radioBuyer == 0 ? Translations.of(context).text('hatchery') :
                                Translations.of(context).text('farmer'),
                                    style: themeData.primaryTextTheme.display4),
                              ),
                              Expanded(
                                flex: 4,
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: TypeAheadFormField(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: this._buyerTypeAheadController,
                                        style:  curIDBuyer == ""  ? notOk : themeData.primaryTextTheme.display3,
                                        decoration: InputDecoration(
                                          hintText: _radioBuyer == 0 ? Translations.of(context).text('select_hatchery') :
                                          Translations.of(context).text('select_farmer'),
                                        ),
                                      ),
                                      getImmediateSuggestions: true,
                                      suggestionsCallback: (pattern) {
                                        if(curNameBuyer != pattern){
                                          curIDBuyer = "";
                                        }
                                        memCacheBuyer = AsyncMemoizer();
                                        return _radioBuyer == 0 ? _getAllHatcheryExceptMe(idHatchery,pattern) :
                                                                  _getAllFarmer();
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
                                      hideOnLoading: true,
                                      transitionBuilder: (context, suggestionsBox, controller) {
                                        return suggestionsBox;
                                      },
                                      onSuggestionSelected: (suggestion) {
                                        dynamic list = suggestion;
                                        String id = list['att1'];
                                        String name = list['att2'];
                                        curIDBuyer = id;
                                        curNameBuyer = name;
                                        this._buyerTypeAheadController.text = name;
                                      },
                                      onSaved: (value){
                                        print('onSaved $value');
                                        //this._typeAheadController.text = value;
                                      }
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        visible: _radioBuyer == -1 ? false : true,
                      ),
                      ViewsWidget.buildInputNumberRow(context, txtNum,'number_of_postlarvea', 'hint_number_of_postlarvea',themeData ),
                      ViewsWidget.buildInputRow(context, txtBonus ,'bonus','hint_bonus', themeData),
                      ViewsWidget.buildInputRow(context, txtNote ,'note','hint_note', themeData),
                      ViewsWidget.selectDateTimePicker(context,txtExpectedDate,'expected_deli_date', themeData),
                      ViewsWidget.selectDatePicker(context,txtSignDate,'sign_date', themeData),
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
                                  _postlarveaSell(context);
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
                  );
                }
                return new Center(child: CircularProgressIndicator());
              })
      ),
    );
  }

}
