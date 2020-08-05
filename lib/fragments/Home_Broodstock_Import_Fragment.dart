import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/scoped_model/home_selected_menu.dart';
import 'package:flutter_helloworld/screens/contract/process_of_import_contract.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:postgres/postgres.dart';
import '../Data/ConvertDataList.dart';
import '../translations.dart';
import '../Data/ConvertQueryResult.dart';

class Home_Broodstock_Import_Fragment extends StatefulWidget {
  //final data = InheritedProvider.of<Data>(context);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Home_Broodstock_Import_FragmentState();
  }
}
class Home_Broodstock_Import_FragmentState extends State<Home_Broodstock_Import_Fragment> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  Future<List<dynamic>> _getAllImportContractOfHatchery(String idHatchery, String date) async{
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
          body: utf8.encode(date == '' ? Contract.queryGetAllImportContractHatchery(idHatchery) : Contract.queryGetImportContractHatcheryFilterDate(idHatchery,date)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (var json in jsonData) {
        listContract.add(json);
      }
      return listContract;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }
  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(milliseconds: 200));
    setState(() {
      memCache = AsyncMemoizer();
    });
    return null;
  }
  int check = -1;
  String date = '';

  @override
  Widget build(BuildContext context) {
    final data = InheritedProvider.of<Data>(context);
    return Scaffold(
      body: ScopedModelDescendant<PopupMenu>(
        builder: (context, child, model) {
          if(check != model.name || date != model.selectedDate){
            memCache = AsyncMemoizer();
            check = model.name;
            date = model.selectedDate;
          }
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            child:  FutureBuilder(
                future: _getAllImportContractOfHatchery(data.att1,model.selectedDate),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasError){
                    return ViewsWidget.buildNoInternet(context,(){
                      setState(() {
                        memCache = AsyncMemoizer();
                      });
                    });
                  }else if(snapshot.hasData){
                    return snapshot.data.length > 0 ? ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
            )
          );
        },
      )
    );
  }
  Widget buildItemContract(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data contract = Data.fromJson(list[index]);

    String signDate = contract.att5;
    //signDate = signDate.split(' ')[0];
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProcessImportContract(idContract : contract.att1)),
              );
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