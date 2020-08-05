import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/screens/broodstock/list_of_importcontract_assign_to_tank.dart';
import 'package:flutter_helloworld/screens/broodstock/list_of_importcontract_sell.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'list_of_broodstockcontractbuy_assign_to_tank.dart';
import 'list_of_broodstockcontractbuy_sell.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';

class ManageContractBuy extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new ManageContractBuyState();
  }
}
class ManageContractBuyState extends State<ManageContractBuy> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController _hideButtonController;
  var _isVisible;

  String idContract;
  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getInfoBroodstockContractBuy(String idCon) async {
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(
              Contract.queryGetInfoOfBroodstockContractBuy(idCon)),
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
    idContract = InheritedProvider.of<String>(context);

    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: Text(Translations.of(context).text('Manage_broodstock_assignment_contract'),
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
                future: _getInfoBroodstockContractBuy(idContract),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return ViewsWidget.buildNoInternet(context,(){
                      setState(() {
                        memCache = AsyncMemoizer();
                      });
                    });
                  } else if (snapshot.hasData) {
                    Data contract = snapshot.data;
                    return Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              ViewsWidget.buildRowDetails(context, 'id_contract', contract.att1),
                              ViewsWidget.buildRowDetails(context, 'species', '${function.getSpecies(context,contract.att4)}'),
                              ViewsWidget.buildRowDetails(context, 'type', '${function.getType(context,contract.att5)}'),
                              ViewsWidget.buildRowDetails(context, 'number_of_cur_male', '${function.formatNumber(contract.att7)}'),
                              ViewsWidget.buildRowDetails(context, 'number_of_cur_female', '${function.formatNumber(contract.att8)}'),
                            ],
                          ),
                        ),
                        ViewsWidget.buildRowAction(context,'assign_to_tank', _onTapAssignToTank,
                            Image.asset("assets/images/icon_tank.png", width: 30,height: 30,color: Colors.blue)),
                        ViewsWidget.buildRowAction(context,'sell', _onTapSell,
                            Image.asset("assets/images/icon_contract.png", width: 30,height: 30,color: Colors.blueGrey)),

                      ],
                    );
                  }
                  return new Center(child: CircularProgressIndicator());
                }
            )
        )
    );
  }
  _onTapAssignToTank(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<String>(
              child: new ListOfBuyBroodStockAssignToTank(),
              inheritedData: idContract,
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });

  }
  _onTapSell(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) =>
            InheritedProvider<String>(
              child: new ListOfSellFromAssignContract(),
              inheritedData: idContract,
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
}
