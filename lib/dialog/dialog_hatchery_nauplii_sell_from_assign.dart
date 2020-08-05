import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/dialog/dialog_input_transportation_information.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/nauplii.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';
import '../translations.dart';
import 'package:postgres/postgres.dart';
import '../Data/ConvertDataList.dart';

class NaupliiSellFromContract extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new NaupliiSellFromContractState();
  }
}
class NaupliiSellFromContractState extends State<NaupliiSellFromContract> {
  List<String> getData;
  String idCon, idHatchery ,idStaff;
  int curNum = -1;

  TextEditingController txtNum = new TextEditingController(), txtBonus = new TextEditingController(),
      txtNote = new TextEditingController(), txtExpectedDate = new TextEditingController(),
      txtSignDate = new TextEditingController();

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoOfNaupliiContract(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Contract.queryGetInfoOfNaupliiContractBuy(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      print(response.body);
      if (response.statusCode == 200) {
        Data contract = new Data();
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
        contract = Data.fromJson(jsonData[0]);
        return contract;
      }else {
        throw("");
      }
    });
  }

  final TextEditingController _hatcheryTypeAheadController = TextEditingController();
  String curIDHat = "", curNameHat = "";
  TextStyle notOk = TextStyle(fontFamily: 'Google sans', fontSize: 14.0, wordSpacing: 3.0, color: Colors.red);
  AsyncMemoizer<List<dynamic>> memCacheHatchery = AsyncMemoizer();

  Future<List<dynamic>> _getAllHatcheryExceptMe(String idHatchery, String filter) async{

    List<dynamic> list = List();
    return memCacheHatchery.runOnce(() async {
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

  _executeNaupliiSellFromContract(BuildContext context) async {

    if(txtNum.text.toString().length != 0 && txtExpectedDate.text.length != 0 &&
        txtSignDate.text.length != 0 && curIDHat != "") {

      String idReceiver = curIDHat;
      int num = int.parse(txtNum.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String note = txtNote.text.toString(), bonus = txtBonus.text.toString(),
          expectedDate = function.convertDefaultToDateCSDL(txtExpectedDate.text.toString()),
          signDate = function.convertDateToDateCSDL(txtSignDate.text.toString());
      if(num <= curNum && curNum > 0) {
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Nauplii.queryNaupliiSellFromContract(idCon, num, idReceiver, idHatchery, signDate, note, idStaff, expectedDate, bonus)),
            encoding: Encoding.getByName("UTF-8")
        );
        print("dialog_hatchery_nauplii_sell_form_assign");
        print(response.body);
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var jsonData = json.decode(response.body.substring(p, e + 1));
        Data result = Data.fromJson(jsonData[0]);

        if (jsonData.length > 0) {
          Toast.show(Translations.of(context).text('saved'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.pop(context);
          openDialog(context,result.att1.toString());
        }
      }else{
        Toast.show('${Translations.of(context).text('you_have_just')} ${function.formatNumber(curNum.toString())} ${Translations.of(context).text('nauplii')}',
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
  }
  @override
  Widget build(BuildContext context) {
    getData = InheritedProvider.of<List<String>>(context);
    idCon = getData[0];
    idStaff = getData[1];
    idHatchery = getData[2];

    ThemeData themeData = buildPrimaryThemeData(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('assignment_contract'),
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
      body: SingleChildScrollView(
          child: FutureBuilder(
              future: _getInfoOfNaupliiContract(idCon),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                      build(context);
                    });
                  });
                } else if (snapshot.hasData) {
                  Data contract = snapshot.data;
                  curNum = int.parse(contract.att5.toString());
                  return Column(
                    children: <Widget>[
                      ViewsWidget.buildRowDetails(context,'id_contract', '${contract.att1}'),
                      ViewsWidget.buildRowDetails(context,'number_of_nauplii','${function.formatNumber(contract.att5)}'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: new Container(
                          height: 1.5,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Text(Translations.of(context).text('hatchery'),
                                  style: themeData.primaryTextTheme.display4),
                            ),
                            Expanded(
                              flex: 4,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: TypeAheadFormField(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: this._hatcheryTypeAheadController,
                                      style:  curIDHat == ""  ? notOk : themeData.primaryTextTheme.display3,
                                      decoration: InputDecoration(
                                        hintText: Translations.of(context).text('select_hatchery'),
                                      ),
                                    ),
                                    getImmediateSuggestions: true,
                                    suggestionsCallback: (pattern) {
                                      if(curNameHat != pattern){
                                        curIDHat = "";
                                      }
                                      memCacheHatchery = AsyncMemoizer();
                                      return _getAllHatcheryExceptMe(idHatchery,pattern);
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
                                      curIDHat = id;
                                      curNameHat = name;
                                      this._hatcheryTypeAheadController.text = name;
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
                      ViewsWidget.buildInputNumberRow(context, txtNum,'number_of_nauplii', 'hint_number_of_nauplii',themeData ),
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
                                  _executeNaupliiSellFromContract(context);
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
