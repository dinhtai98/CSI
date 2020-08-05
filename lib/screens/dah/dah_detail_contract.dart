import 'dart:async';
import 'package:async/async.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'dart:convert';
import '../../translations.dart';
import 'package:http/http.dart' as http;

import 'dah_clearance.dart';



class DAHDetailContract extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DAHDetailContractState();
  }
}
class DAHDetailContractState extends State<DAHDetailContract> {
  List<String> getData;
  String idCon = "", idStaff = "", idDAH = "", checkClearance = "";

  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
  new GlobalKey<RefreshIndicatorState>();
  TextStyle style = TextStyle(fontFamily: 'Google sans', fontSize: 20.0);

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  _dahGetInfoOfImportContract(String idCon) async{
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
              Contract.queryDAHGetImportContract(idCon)),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    getData = InheritedProvider.of<List<String>>(context);
    idCon = getData[0];
    idStaff = getData[1];
    idDAH = getData[2];
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('contract_details'),style: themeData.primaryTextTheme.caption,),
      ),
      body: RefreshIndicator(
          key: _refreshIndicator,
          onRefresh: _handleRefresh,
          child: FutureBuilder(
              future: _dahGetInfoOfImportContract(idCon),
              builder: (BuildContext ctx, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data contract = snapshot.data;
                  checkClearance = contract.att10.toString();
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
                              ViewsWidget.buildRowDetails(context, 'bonus', contract.att9.toString() == "null" ? '' : contract.att9.toString()),
                            ],
                          ),
                        ),
                        ViewsWidget.buildRowAction(context,'collecting_sample', _onTapCollecting,
                            Image.asset("assets/images/icon_collectingsample.png", width: 30,height: 30,color: Colors.blue)),
                        ViewsWidget.buildRowAction(context,'custom_clearance', _onClearance,
                            Image.asset("assets/images/icon_customclearance.png", width: 30,height: 30,color: Colors.blue)),
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
  _onTapCollecting(){
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Colors.red,
      boxShadows: [BoxShadow(color: Colors.blue[800], offset: Offset(0.0, 2.0), blurRadius: 3.0)],
      backgroundGradient: LinearGradient(colors: [Colors.blueGrey, Colors.black]),
      isDismissible: false,
      duration: Duration(seconds: 4),
      icon: Image.asset("assets/images/icon_csiro.png", width: 30,height: 30),
      mainButton: FlatButton(
        onPressed: () {},
        child: Text(
          "CLAP",
          style: TextStyle(color: Colors.amber),
        ),
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Text(
        "Hello",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.yellow[600], fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        "Welcome to Tôm giống VN",
        style: TextStyle(fontSize: 18.0, color: Colors.green, fontFamily: "ShadowsIntoLightTwo"),
      ),
    )..show(context);
  }
  _onClearance(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<List<String>>(
              child: new DAHClearance(),
              inheritedData: [idCon,idStaff,idDAH],
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
}