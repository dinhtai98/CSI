import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/ConvertQueryResult.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_input_transportation_information.dart';
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
import '../../Data/ConvertQueryResult.dart';

class BroodstockContractBuy extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new BroodstockContractBuyState();
  }
}
class BroodstockContractBuyState extends State<BroodstockContractBuy> {

  String idAssignContract, idTransport, idSeller, idBuyer, idRanking;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoBroodstockContractBuy(String idCon) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Contract.queryGetInfoOfBroodstockContractBuy(idCon)),
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
    idAssignContract = InheritedProvider.of<String>(context);
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
              future: _getInfoBroodstockContractBuy(idAssignContract),
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
                  String moneyTransferDate = function.convertDateCSDLToDateDefault('${contract.att10}');
                  moneyTransferDate = signDate.split(' ')[0];
                  idSeller = contract.att14.toString();
                  idBuyer = contract.att15.toString();
                  idRanking = contract.att16.toString();
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
                            ViewsWidget.buildRowDetails(context, 'species', '${function.getSpecies(context,contract.att4)}'),
                            ViewsWidget.buildRowDetails(context, 'type', '${function.getType(context,contract.att5)}'),
                            ViewsWidget.buildRowDetails(context, 'number_of_pair', '${function.formatNumber(contract.att6)}'),
                            ViewsWidget.buildRowDetails(context, 'bonus', '${contract.att13.toString() == "null" ? "" : contract.att13.toString()}'),
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
                            ViewsWidget.buildRowDetails(context, 'expected_deli_date', '${function.convertDateCSDLToDateTimeDefault(contract.att9)}'),
                            ViewsWidget.buildRowDetails(context, 'money_transfer_date', '$moneyTransferDate'),
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
                            ViewsWidget.buildRowDetails(context,'total_amount', '${function.formatNumber(contract.att11)}'),
                            ViewsWidget.buildRowDetails(context,'transfer_amount', '${function.formatNumber(contract.att12)}'),
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
                return ViewsWidget.buildPleaseWait();
              }
          )
      ),
    );
  }
  _onTapManage(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<String>(
              child: new ManageContractBuy(),
              inheritedData: idAssignContract,
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
          inheritedData: [idAssignContract,idSeller,idBuyer]
        ) : InheritedProvider<String>(
            child: new DialogRatingInfomation(),
            inheritedData: idAssignContract
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });

    });
  }
  _onTapTransport(BuildContext context){
    showDialog(
        context: context,
        builder: (_) => InheritedProvider<String>(
          child: new DialogTransportaionInfomation(ctx: context) ,
          inheritedData: idAssignContract,
        )
    ).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
        //_getTankBroodstock(idSub);
      });

    });
  }
}
