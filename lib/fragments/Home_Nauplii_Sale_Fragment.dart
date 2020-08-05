import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/broodstock.dart';
import 'package:flutter_helloworld/queries/nauplii.dart';
import 'package:flutter_helloworld/scoped_model/home_selected_menu.dart';
import 'package:flutter_helloworld/screens/nauplii/detail_contract_buy.dart';
import 'package:flutter_helloworld/screens/nauplii/detail_nauplii_contract_sell.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:postgres/postgres.dart';
import '../Data/ConvertQueryResult.dart';

class HomeNaupliiSaleFragment extends StatefulWidget {
  //final data = InheritedProvider.of<Data>(context);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new HomeNaupliiSaleFragmentState();
  }
}
class HomeNaupliiSaleFragmentState extends State<HomeNaupliiSaleFragment> {
  int _radio = 1;
  int oldRadio = 1;
  void _handleRadio(int value) {
    setState(() {
      memCache = AsyncMemoizer();
      _radio = value;
    });
  }
  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();

  Future<List<dynamic>> _getAllNaupliiContractOfHatchery(String idHatchery, int type, String date) async{
    List<dynamic> listContract = List();
    List<Map<String, dynamic>> result = new List<Map<String, dynamic>>();
    return memCache.runOnce(() async {

      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(type == 1 ?
          Nauplii.queryGetAllNaupliiContractBuyOfHatchery(idHatchery,date) :
          Nauplii.queryGetAllNaupliiContractSellOfHatchery(idHatchery,date)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      setState(() {
        var jsonData = json.decode(result);
        for (var json in jsonData) {
          listContract.add(json);
        }
      });
      return listContract;
    });
  }
  int check = -1;
  String date = '';
  @override
  Widget build(BuildContext context) {
    final data = InheritedProvider.of<Data>(context);
    ThemeData themeData = buildPrimaryThemeData(context);
    // TODO: implement build
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child:  ViewsWidget.buildRadioBuySale(context, _radio  , _handleRadio,themeData),
        ),
        Expanded(
          child: ScopedModelDescendant<PopupMenu>(
            builder: (context, child, model) {
              if(check != model.name || date != model.selectedDate){
                memCache = AsyncMemoizer();
                check = model.name;
                date = model.selectedDate;
              }
              if(_radio != oldRadio){
                model.changeDate('');
                model.changeName(-1);
                oldRadio = _radio;
              }
              return FutureBuilder(
                  future: _getAllNaupliiContractOfHatchery(data.att1,_radio,model.selectedDate),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.hasError){
                      return ViewsWidget.buildNoInternet(context,(){
                        setState(() {
                          memCache = AsyncMemoizer();
                        });
                      });
                    }else if(snapshot.hasData){
                      return snapshot.data.length > 0 ? ListView.builder(
                          padding: EdgeInsets.all(5.0),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) => buildItemContract(context,snapshot.data, index, )
                      ):
                      ViewsWidget.buildNoResultSearch(context);
                    }
                    return new Center(
                        child: CircularProgressIndicator());
                  }
              );
            },
          )
        )
      ],
    );
  }
  Widget buildItemContract(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data contract = Data.fromJson(list[index]);

    String signDate = function.convertDateCSDLToDateDefault('${contract.att2}');
    signDate = signDate.split(' ')[0];
    return new Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
        child: Container(
          //decoration: BoxDecoration(color: Color(0xff000000),
          //borderRadius: BorderRadius.circular(25.0)),
          child: ListTile(
            onTap: (){
              Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (_) =>
                      InheritedProvider<String>(
                        child: _radio == 1 ? new NaupliiContractBuy() : new NaupliiContractSell() ,
                        inheritedData: contract.att1,
                      ))).then((onValue) {
                setState(() {
                  memCache = AsyncMemoizer();
                });
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right: new BorderSide(width: 1.0, color: Color(0xff007B97)))),
                child: Image.asset("assets/images/icon_contract.png", width: 30,height: 30,color: Colors.blue)
            ),
            title: Text(
                '${contract.att1}',
                style: themeData.primaryTextTheme.display1
            ),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                //Text('${request.att3}', style: TextStyle(color: Color(0xff007B97))),
                Text('$signDate', style: themeData.primaryTextTheme.display2)
              ],
            ),
            //trailing:
            //Icon(Icons., color: Colors.white, size: 30.0)
          ),
        ));
  }
}
