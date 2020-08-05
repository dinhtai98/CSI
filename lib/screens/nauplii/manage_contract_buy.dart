import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'list_of_naupliicontractbuy_assign_to_tank.dart';
import 'list_of_naupliicontractbuy_sell.dart';
import 'package:postgres/postgres.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';

class NaupliiManageContractBuy extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new NaupliiManageContractBuyState();
  }
}
class NaupliiManageContractBuyState extends State<NaupliiManageContractBuy> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController _hideButtonController;
  var _isVisible;
  Future<Data> getUser = DataUser.getDataUser();
  String idHatchery;
  String idContract;
  String idStaff;
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
      print("manage_contract_buy");
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
  void initState() {
    super.initState();
    getUser.then((onValue) {
      setState(() {
        idHatchery = onValue.att1.toString();
        idStaff = onValue.att10.toString();
      });
    });
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });

    _isVisible = true;
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
                future: _getInfoNaupliiContractBuy(idContract),
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
                              ViewsWidget.buildRowDetails(context, 'species', Translations.of(context).text('nauplii')),
                              ViewsWidget.buildRowDetails(context, 'number_of_nauplii', '${function.formatNumber(contract.att5)}'),
                              ViewsWidget.buildRowDetails(context, 'bonus', '${contract.att6.toString() == "null" ? "" : contract.att6.toString()}'),
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
            InheritedProvider<List<String>>(
              child: new ListOfNaupliiAssignTankFromContract(),
              inheritedData: [idContract, idHatchery, idStaff],
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
              child: new ListOfNaupliiSellFromContract(),
              inheritedData: idContract,
            ))).then((onValue) {
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
}
