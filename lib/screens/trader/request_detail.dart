import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/request.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';

class TraderRequestDetails extends StatefulWidget {
  String idRequest;

  TraderRequestDetails(this.idRequest);

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new TraderRequestDetailsState();
  }
}
class TraderRequestDetailsState extends State<TraderRequestDetails> {
  TextStyle notOk = TextStyle(fontFamily: 'Google sans', fontSize: 14.0, wordSpacing: 3.0, color: Colors.red);
  String idHatchery, traderName;

  var checkInit = 0;
  var  txtPair = new TextEditingController();
  var  txtUnitPrice = new TextEditingController();
  var  txtArrivalPort = new TextEditingController();
  var  txtArrivalPortTime = new TextEditingController();
  var  txtExpectedTime = new TextEditingController();
  var  txtBonus = new TextEditingController();
  var  txtNote = new TextEditingController();

  final TextEditingController _proTypeAheadController = TextEditingController();

  String _curType = "0";
  String _radioSpecies = "0";

  AsyncMemoizer<List<dynamic>> memCachePro = AsyncMemoizer();
  String curIDPro = "", curNamePro = "";
  Future<List<dynamic>> _getAllProducer(String filter) async{
    return memCachePro.runOnce(() async {
      List<dynamic> _listProducer = List();
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
  void changedDropDownTypes(String selectedType) {
    setState(() {
      _curType = selectedType;
    });
  }
  void _handleRadioSpecies(String value) {
    setState(() {
      _radioSpecies = value;
    });
  }
  AsyncMemoizer<Data> memCacheResponse = AsyncMemoizer();
  AsyncMemoizer<Data> memCacheRequest = AsyncMemoizer();
  Future<Data> _getRequest() async{
    return memCacheRequest.runOnce(() async {
      int i = 0;
      while (i++ < 3) {
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Request.query_findRequest(widget.idRequest)),
            encoding: Encoding.getByName("UTF-8")
        );
        if (response.statusCode == 200) {
          Data requestData = new Data();
          var p = response.body.indexOf("[");
          var e = response.body.lastIndexOf("]");
          var result = response.body.substring(p, e + 1);
          var jsonData = json.decode(result);
          requestData = Data.fromJson(jsonData[0]);
          return requestData;
        }
      }
      throw("");
    });
  }
  Future<Data> _getResponseFromRequest() async{
    return memCacheResponse.runOnce(() async {
      int i = 0;
      while(i++ < 3) {
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(
                Request.query_CheckRequest_Responsed(widget.idRequest)),
            encoding: Encoding.getByName("UTF-8")
        );
        if (response.statusCode == 200) {
          Data responseData = new Data();
          var p = response.body.indexOf("[");
          var e = response.body.lastIndexOf("]");
          var result = response.body.substring(p, e + 1);
          //setState(() {
          List jsonData = json.decode(result);
          if (jsonData.length > 0) {
            responseData = Data.fromJson(jsonData[0]);
          }
          return responseData;
        }
      }
      throw("");
    });
  }
  _sendResponse(BuildContext context) async {

    if(txtPair.text.toString().length != 0 && txtUnitPrice.text.toString().length != 0 &&
        txtExpectedTime.text.toString().length != 0 &&
        txtArrivalPortTime.text.toString().length != 0 && txtArrivalPort.text.toString().length != 0 &&
        curIDPro != null ) {

      int numberOfPair = int.parse(txtPair.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      int price = int.parse(txtUnitPrice.text.replaceAll(new RegExp(r'[.,]+'),'').toString());
      String expectedTime = txtExpectedTime.text;
      String portTime = txtArrivalPortTime.text;
      String arrivalPort = txtArrivalPort.text.toString(), bonus = txtBonus.text.toString(),
             note = txtNote.text.toString();
      if(numberOfPair > 0) {
        http.Response response = await http.post(
            Api.url_update,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Request.query_InsertResponse(
                widget.idRequest,
                _radioSpecies,
                numberOfPair,
                price,
                expectedTime,
                arrivalPort,
                portTime,
                bonus,
                curIDPro,
                _curType,
                note)),
            encoding: Encoding.getByName("UTF-8")
        );
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        if (result == "1") {
          function.pushNotification(
              context, '$idHatchery^response^${widget.idRequest}^$traderName');
          Toast.show(Translations.of(context).text('sent'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.pop(context);
        }
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
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('request_details'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(Translations.of(context).text('request'), style: themeData.primaryTextTheme.display1,)
                        ],
                      ),
                    ),
                    FutureBuilder(
                      future: _getRequest(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if(snapshot.hasError){
                          return ViewsWidget.buildNoInternet(context,(){
                            setState(() {
                              memCacheRequest = AsyncMemoizer();
                              build(context);
                            });
                          });
                        }else if(snapshot.hasData){
                          Data requestData = snapshot.data;
                          idHatchery = requestData.att8;
                          traderName = requestData.att2;
                          return new Column(
                            children: <Widget>[
                              ViewsWidget.buildRowDetails(context,'request_date', '${requestData.att7}'),
                              ViewsWidget.buildRowDetails(context,'trader', '${requestData.att2}'),
                              ViewsWidget.buildRowDetails(context,'producer', '${requestData.att1}'),
                              ViewsWidget.buildRowDetails(context,'species', '${function.getSpecies(context,requestData.att3)}'),
                              ViewsWidget.buildRowDetails(context,'type', '${function.getType(context,requestData.att4)}'),
                              ViewsWidget.buildRowDetails(context,'number_of_pair', '${function.formatNumber(requestData.att5)}'),
                              ViewsWidget.buildRowDetails(context,'expected_deli_date', '${requestData.att6}')
                            ],
                          );
                        }
                        return new Center(
                            child: CircularProgressIndicator());
                      },
                    )
                  ],
                )
            ),
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(Translations.of(context).text('response'), style: themeData.primaryTextTheme.display1,)
                      ],
                    ),
                  ),
                  FutureBuilder(
                    future:_getResponseFromRequest(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if(snapshot.hasError){
                        return ViewsWidget.buildNoInternet(context,(){
                          setState(() {
                            memCacheResponse = AsyncMemoizer();
                            memCachePro = AsyncMemoizer();
                            build(context);
                          });
                        });
                      }else if(snapshot.hasData){
                        Data responseData = snapshot.data;
                        if(responseData.att1.toString() == "null"){
                          return buildTraderResponse(context);
                        }else{
                          return new Column(
                            children: <Widget>[
                              ViewsWidget.buildRowDetails(context,'response_date', '${responseData.att11}'),
                              ViewsWidget.buildRowDetails(context,'producer', '${responseData.att1}'),
                              ViewsWidget.buildRowDetails(context,'species', '${function.getSpecies(context,responseData.att2)}'),
                              ViewsWidget.buildRowDetails(context,'type', '${function.getType(context,responseData.att3)}'),
                              ViewsWidget.buildRowDetails(context,'number_of_pair', '${function.formatNumber(responseData.att5)}'),
                              ViewsWidget.buildRowDetails(context,'unit_price', '${function.formatNumber(responseData.att4)}'),
                              ViewsWidget.buildRowDetails(context,'arrival_port', '${responseData.att7}'),
                              ViewsWidget.buildRowDetails(context,'arrival_port_date', '${responseData.att8}'),
                              ViewsWidget.buildRowDetails(context,'expected_deli_date', '${responseData.att6}'),
                              ViewsWidget.buildRowDetails(context,'bonus', '${responseData.att9}'),
                              ViewsWidget.buildRowDetails(context,'note', '${responseData.att10}'),
                            ],
                          );
                        }
                      }
                      return new Center(
                          child: CircularProgressIndicator());
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTraderResponse(BuildContext context){
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
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
                          curIDPro = "";
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
                      hideOnLoading: true,
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (suggestion) {
                        dynamic list = suggestion;
                        String id = list['att1'];
                        String name = list['att2'];
                        curIDPro = id;
                        curNamePro = name;
                        this._proTypeAheadController.text = name;
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
        ViewsWidget.buildInputNumberRow(context, txtPair,'number_of_pair', 'hint_number_of_pair',themeData ),
        ViewsWidget.buildInputNumberRow(context, txtUnitPrice,'unit_price', 'hint_unit_price',themeData ),
        ViewsWidget.buildInputRow(context, txtArrivalPort,'arrival_port', 'hint_arrival_port',themeData ),
        ViewsWidget.selectDateTimePicker(context,txtArrivalPortTime,'arrival_port_date', themeData),
        ViewsWidget.selectDateTimePicker(context,txtExpectedTime,'expected_deli_date', themeData),
        ViewsWidget.buildInputRow(context, txtBonus,'bonus', 'hint_bonus',themeData ),
        ViewsWidget.buildInputRow(context, txtNote,'note','hint_note',themeData ),
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
                    _sendResponse(context);
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
    );
  }
}