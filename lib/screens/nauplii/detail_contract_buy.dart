import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/ConvertQueryResult.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_transportation.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'manage_contract_buy.dart';
import 'package:postgres/postgres.dart';
import '../../Data/ConvertDataList.dart';

class NaupliiContractBuy extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new NaupliiContractBuyState();
  }
}
class NaupliiContractBuyState extends State<NaupliiContractBuy> {

  String idCon, idTransport, idSeller, idBuyer, idRanking;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoNaupliiContractBuy(String idCon) async{
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
      Data contract = new Data();
      var p = response.body.indexOf(">");
      var e = response.body.lastIndexOf("<");
      var result = response.body.substring(p + 1, e);
      var jsonData = json.decode(result);
      contract = Data.fromJson(jsonData[0]);
      return contract;
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idCon = InheritedProvider.of<String>(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('contract_details'),
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
              future: _getInfoNaupliiContractBuy(idCon),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data contract = snapshot.data;
                  String signDate = function.convertDateCSDLToDateDefault('${contract.att2}');
                  signDate = signDate.split(' ')[0];
                  idSeller = contract.att10.toString();
                  idBuyer = contract.att11.toString();
                  idRanking = contract.att9.toString();
                  //idTransport = contract.att15.toString();
                  return new Column(
                    children: <Widget>[
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context, 'id_contract', '${contract.att1}'),
                            ViewsWidget.buildRowDetails(context,'seller', '${contract.att3}'),
                            ViewsWidget.buildRowDetails(context, 'sign_date', '$signDate'),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context, 'species', Translations.of(context).text('nauplii')),
                            ViewsWidget.buildRowDetails(context, 'number_of_nauplii', '${function.formatNumber(contract.att4)}'),
                            ViewsWidget.buildRowDetails(context, 'bonus', '${contract.att6.toString() == "null" ? "" : contract.att6.toString()}'),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context, 'expected_deli_date', '${function.convertDateCSDLToDateTimeDefault(contract.att7)}'),
                            ViewsWidget.buildRowDetails(context, 'note', '${contract.att8.toString() == "null" ? "" : contract.att8.toString()}'),
                          ],
                        ),
                      ),
                      ViewsWidget.buildRowAction(context,'asigntank_or_sell', _onTapManage,
                          Image.asset("assets/images/icon_manage_contract.png", width: 30,height: 30,color: Colors.blue)),
                      ViewsWidget.buildRowAction(context,'ranking', _onTapRanking,
                          Image.asset("assets/images/icon_rating_view.png", width: 30,height: 30,color: Colors.amber)),
                      ViewsWidget.buildRowAction(context,'transportation_information',_onTapTransport,
                          Image.asset("assets/images/icon_transportation.png", width: 30,height: 30,color: Colors.blue)),
                    ],
                  );
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          )
      ),
    );
  }
  _onTapManage(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<String>(
              child: new NaupliiManageContractBuy(),
              inheritedData: idCon,
            ))).then((onValue) {
              setState(() {
              memCache = AsyncMemoizer();
      });
    });
  }
  _onTapRanking(BuildContext context){
    showDialog(
      context: context,
      builder: (_) => idRanking == "null" ? InheritedProvider<List<String>>(
        child: new DialogInputRanking(ctx: context),
        inheritedData: [idCon,idSeller,idBuyer],
      ) : InheritedProvider<String>(
        child: new DialogRatingInfomation(ctx: context),
        inheritedData: idCon,
      ))
        .then((onValue) {
          setState(() {
          memCache = AsyncMemoizer();
          });
      },
    );
  }

  _onTapTransport(BuildContext context){
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
          child: new DialogTransportaionInfomation(ctx: context) ,
          inheritedData: idCon,
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });
    });
  }
}
