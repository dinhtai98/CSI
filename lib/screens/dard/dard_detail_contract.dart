import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/dard.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:toast/toast.dart';
import 'dart:convert';
import '../../translations.dart';
import 'package:http/http.dart' as http;


class DARDDetailContract extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DARDDetailContractState();
  }
}
class DARDDetailContractState extends State<DARDDetailContract> {
  Future<Data> getUser = DataUser.getDataUser();
  String idCon = "", idStaff = "", idDARD = "", checkStatus = "";
  String idHatchery = ""; // to push notification reminder report 72h

  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
  new GlobalKey<RefreshIndicatorState>();
  TextStyle style = TextStyle(fontFamily: 'Google sans', fontSize: 20.0);

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  _dardGetInfoOfImportContract(String idCon) async{
    Data data = new Data();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(
              DARD.queryGetInFoImportContractQuarantine(idCon)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      data = Data.fromJson(jsonData[0]);
      return data;
    });
  }
  _dardQuarantine(BuildContext context) async {
    String  content = "DARDStaff quarantine clearance at hatchery";
    print(DARD.queryDARDQuarantine(
        idCon, idStaff, idDARD,content));
    http.Response response = await http.post(
        Api.url_update,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(DARD.queryDARDQuarantine(
            idCon, idStaff, idDARD,content)),
        encoding: Encoding.getByName("UTF-8")
    );
    var p = response.body.indexOf(">");
    var e = response.body.lastIndexOf("<");
    var result = response.body.substring(p + 1, e);

    if (result.contains("1")) {
      String type = 'reminder';
      function.pushNotification(context, '$idHatchery^$type^$idCon^x');
      Toast.show(Translations.of(context).text('saved'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      setState(() {
        memCache = AsyncMemoizer();
      });
    } else {
      Toast.show(Translations.of(context).text('error'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  _dardClearQuarantine(BuildContext context) async {
    http.Response response = await http.post(
        Api.url_update,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(DARD.queryDARDQuarantineClearance(
            idCon, idStaff)),
        encoding: Encoding.getByName("UTF-8")
    );
    var p = response.body.indexOf(">");
    var e = response.body.lastIndexOf("<");
    var result = response.body.substring(p + 1, e);

    if (result.contains("1")) {
      Toast.show(Translations.of(context).text('saved'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      setState(() {
        memCache = AsyncMemoizer();
      });
    } else {
      Toast.show(Translations.of(context).text('error'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser.then((onValue){
      setState(() {
        idStaff = onValue.att10.toString();
        idDARD = onValue.att1.toString();
      });

    });
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicator.currentState?.show();
    });
  }
  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(milliseconds: 200));
    memCache = AsyncMemoizer();
    setState(() {

    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idCon = InheritedProvider.of<String>(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('contract_details'),style: themeData.primaryTextTheme.caption,),
      ),
      body: RefreshIndicator(
          key: _refreshIndicator,
          onRefresh: _handleRefresh,
          child: FutureBuilder(
              future: _dardGetInfoOfImportContract(idCon),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data contract = snapshot.data;
                  checkStatus = contract.att10.toString();
                  idHatchery = contract.att11.toString();
                  return SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: <Widget>[
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                ViewsWidget.buildRowDetails(context, 'id_contract', contract.att1),
                                ViewsWidget.buildRowDetails(context, 'hatchery', contract.att2),
                                ViewsWidget.buildRowDetails(context, 'producer', contract.att3),
                                ViewsWidget.buildRowDetails(context, 'trader', contract.att4),
                              ],
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                ViewsWidget.buildRowDetails(context, 'species', '${function.getSpecies(context,contract.att5)}'),
                                ViewsWidget.buildRowDetails(context, 'type', '${function.getType(context,contract.att6)}'),
                                ViewsWidget.buildRowDetails(context, 'number_of_pair', '${function.formatNumber(contract.att8)}'),
                                ViewsWidget.buildRowDetails(context, 'bonus', contract.att9.toString() == "null" ? '': contract.att9.toString()),
                              ],
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                Visibility(
                                  child: ViewsWidget.buildRowDetails(context, 'quarantine_time',
                                      '${checkStatus != "null" ? function.convertDateCSDLToDateTimeDefault(contract.att12) : ''}'),
                                  visible: checkStatus != "null",
                                ),
                                Visibility(
                                  child: ViewsWidget.buildRowDetails(context, 'clearance_time',
                                      '${checkStatus == "2" ? function.convertDateCSDLToDateTimeDefault(contract.att13) : ''}'),
                                  visible: checkStatus == "2",
                                ),
                                ViewsWidget.buildRowDetails(context, 'status', '${checkStatus == "null" ?
                                Translations.of(context).text('not_yet_quarantine') :
                                (checkStatus == "1" ?
                                Translations.of(context).text('in_10_days') :
                                Translations.of(context).text('quarantine_clearance'))}'),
                              ],
                            ),
                          ),
                          dardQuarantine(context,themeData,checkStatus),
                          dardClearQuarantine(context,themeData,checkStatus)
                        ],
                      )
                  );
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          )
      ),
    );
  }
  Widget dardQuarantine(BuildContext context ,ThemeData themeData, String checkStatus){
    TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);
    return  Visibility(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        width: 120,
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(25.0),
          color: Color(0xff01A0C7),
          child: MaterialButton(
            //minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            onPressed: (){
              _dardQuarantine(context);
            },
            child: Text(Translations.of(context).text('quarantine'),
                textAlign: TextAlign.center,
                style: styleButton),
          ),
        ),
      ),
      visible: checkStatus == "null",
    );
  }
  Widget dardClearQuarantine(BuildContext context, ThemeData themeData, String checkStatus){
    TextStyle styleButton = TextStyle(fontFamily: 'Google sans', fontSize: 16.0,color: Colors.white);
    return Visibility(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        width: 150,
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(25.0),
          color: Color(0xff01A0C7),
          child: MaterialButton(
            //minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            onPressed: (){
              _dardClearQuarantine(context);
            },
            child: Text(Translations.of(context).text('clear_quarantine'),
                textAlign: TextAlign.center,
                style: styleButton),
          ),
        ),
      ),
      visible: checkStatus == "1",
    );
  }
}