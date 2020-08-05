import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/numberformatter.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:toast/toast.dart';

import '../translations.dart';
import 'dialog_input_transportation_information.dart';



class DialogHatcheryBroodstockSellFromAssign extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogHatcheryBroodstockSellFromAssignState();
  }
}
class DialogHatcheryBroodstockSellFromAssignState extends State<DialogHatcheryBroodstockSellFromAssign> {
  List<String> dataContract;
  String idContract,idBatch, idStaff, idHatchery;
  int curPair = -1;

  TextEditingController txtPair = new TextEditingController(), txtTransferAmount = new TextEditingController(),
      txtTotalAmount = new TextEditingController(),txtBank = new TextEditingController(),
      txtWiring = new TextEditingController(),txtBonus = new TextEditingController(),
      txtExpectedDate = new TextEditingController(), txtTransferMoneyDate = new TextEditingController(),
      txtSignDate = new TextEditingController();

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoOfAssignContract(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Contract.queryGetInfoOfAssignContract(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("dialog_hatchery_broodstock_sell_from_assign");
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

  _broodstockSellFromAssign(BuildContext context) async {

    if(txtPair.text.toString().length != 0 && txtTransferAmount.text.toString().length != 0 &&
        txtTotalAmount.text.length != 0 && txtBank.text.length != 0 && txtWiring.text.length != 0 &&
        txtExpectedDate.text.length != 0 && txtTransferMoneyDate.text.length != 0 &&
        txtSignDate.text.length != 0 && curIDHat != "") {

      String idReceiver = curIDHat;
      int pair = int.parse(txtPair.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      int transferAmount = int.parse(txtTransferAmount.text.replaceAll(new RegExp(r'[.,]+'),'').toString()),
      totalAmount = int.parse(txtTotalAmount.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String bank = txtBank.text.toString(), wiring = txtWiring.text.toString(), bonus = txtBonus.text.toString(),
      expectedDate = function.convertDefaultToDateCSDL(txtExpectedDate.text),
      transferMoneyDate = function.convertDateToDateCSDL(txtTransferMoneyDate.text),
      signDate = function.convertDateToDateCSDL(txtSignDate.text);
      if(pair <= curPair && pair > 0){
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Broodstock.querySellBroodstockFromAssignContract(
                idContract,idReceiver, signDate, pair, idBatch,
                expectedDate, transferMoneyDate, totalAmount,
                transferAmount,bank,wiring,idHatchery,idStaff,bonus)),
            encoding: Encoding.getByName("UTF-8")
        );
        print(response.body);
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
            '${function.formatNumber(curPair.toString())} '
            '${Translations.of(context).text('number_of_pair')}',
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
    dataContract = InheritedProvider.of<List<String>>(context);
    idContract = dataContract[0];
    idStaff = dataContract[1];
    idHatchery = dataContract[2];

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
              future: _getInfoOfAssignContract(idContract),
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
                  idBatch = contract.att6.toString();
                  curPair = min(int.parse(contract.att4),int.parse(contract.att5));
                  return Column(
                    children: <Widget>[
                      ViewsWidget.buildRowDetails(context,'species', '${function.getSpecies(context,contract.att2)}'),
                      ViewsWidget.buildRowDetails(context,'type', '${function.getType(context,contract.att3)}'),
                      ViewsWidget.buildRowDetails(context,'number_of_pair', '${function.formatNumber(curPair.toString())}'),
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
                      ViewsWidget.buildInputNumberRow(context, txtPair,'number_of_pair', 'hint_number_of_pair',themeData ),
                      ViewsWidget.buildInputNumberRow(context, txtTransferAmount ,'transfer_amount','hint_transfer_amount', themeData),
                      ViewsWidget.buildInputNumberRow(context, txtTotalAmount ,'total_amount','hint_total_amount', themeData),
                      ViewsWidget.buildInputRow(context, txtBank ,'via_bank','hint_bank', themeData),
                      ViewsWidget.buildInputRow(context, txtWiring ,'wiring_number','hint_wiring_number', themeData),
                      ViewsWidget.buildInputRow(context, txtBonus ,'bonus','hint_bonus', themeData),
                      ViewsWidget.selectDateTimePicker(context,txtExpectedDate,'expected_deli_date', themeData),
                      ViewsWidget.selectDatePicker(context,txtTransferMoneyDate,'money_transfer_date', themeData),
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
                                  _broodstockSellFromAssign(context);
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
