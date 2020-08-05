import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/screens/tank/detail_tank.dart';
import 'package:flutter_helloworld/screens/tank/tank_broodstock.dart';
import 'package:flutter_helloworld/screens/tank/tank_nauplii.dart';
import 'package:flutter_helloworld/screens/tank/tank_postlarvea.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../translations.dart';



class TankFragment extends StatefulWidget {

  final Data data;
  TankFragment({this.data});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new TankFragmentState(data);
  }
}
class TankFragmentState extends State<TankFragment> {
  final Data data;
  TankFragmentState(this.data);

  List<DropdownMenuItem<Data>> _dropDownCluster = List();

  Data _currentClu = new Data();


  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  AsyncMemoizer<List<dynamic>> memCacheTank = AsyncMemoizer();

  Future<List<dynamic>> _getClusterOfHatchery() async{
    return memCache.runOnce(() async{
      List<dynamic> listCluster = List();

      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.query_GetAllClusterOfHatchery(data.att7)),
          encoding: Encoding.getByName("UTF-8")
      );
      if(response.statusCode == 200) {
        var p = response.body.indexOf("[");
        var e = response.body.lastIndexOf("]");
        var result = response.body.substring(p, e + 1);
        var jsonData = json.decode(result);
       for (dynamic item in jsonData) {
          listCluster.add(item);
        }
        _listDropdownMenu(listCluster);
        return listCluster;
      }
      throw("");
    });
  }
  _listDropdownMenu(List<dynamic> list){
    //_dropDownCluster.clear();
    for (dynamic item in list) {
      Data data = Data.fromJson(item);
      _dropDownCluster.add(new DropdownMenuItem(
          value: data,
          child: new Text(data.att2)
      ));
    }
    setState(() {
      _currentClu = _dropDownCluster[0].value;
    });
  }
  void changedDropDownClu(Data selectedClu) {
    setState(() {
      _currentClu = selectedClu;
      memCacheTank = AsyncMemoizer();

    });
    //_getTankOfClusterHatchery(_currentClu.att1);
  }
  Future<List<dynamic>> _getTankOfClusterHatchery(String idClu) async{
    return memCacheTank.runOnce(() async {
      List<dynamic> tanksOfClu = List();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryGetAllBeOfNhaSX(_currentClu.att1)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (var json in jsonData) {
        tanksOfClu.add(json);
      }
      return tanksOfClu;
    });
  }



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    ThemeData themeData = buildPrimaryThemeData(context);
    return FutureBuilder(
        future: _getClusterOfHatchery(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            return ViewsWidget.buildNoInternet(context,(){
              setState(() {
                memCache = AsyncMemoizer();
                memCacheTank = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(Translations.of(context).text('cluster'),
                            style: themeData.primaryTextTheme.display1 ),
                      ),
                      ViewsWidget.buildDropDownList(
                          _dropDownCluster, _currentClu, changedDropDownClu,themeData),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                      future: _getTankOfClusterHatchery(_currentClu.att1.toString()),
                      builder: (BuildContext context, AsyncSnapshot snapshotTank) {
                        if(snapshotTank.hasError){
                          return ViewsWidget.buildNoInternet(context,(){
                            setState(() {
                              memCacheTank = AsyncMemoizer();
                            });
                          });
                        }else if(snapshotTank.hasData){
                          return snapshotTank.data.length > 0 ? GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: (itemWidth / itemHeight),
                            padding: const EdgeInsets.all(4.0),
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            // Generate 100 widgets that display their index in the List.
                            children: List.generate(snapshotTank.data.length, (index) {
                              Data tank = Data.fromJson(snapshotTank.data[index]);
                              String idTank = tank.att1.toString();
                              String sub = tank.att3.toString();
                              return new GridTile(
                                child: Card(
                                  shape: tank.att4.toString() == "0"
                                      ? new RoundedRectangleBorder(
                                      side: new BorderSide(color: Colors.red , width: 4.0),
                                      borderRadius: BorderRadius.circular(15.0))
                                      :
                                  ( sub != "null" ? new RoundedRectangleBorder(
                                      side: new BorderSide(color: kColorBackground, width: 4.0),
                                      borderRadius: BorderRadius.circular(15.0))
                                      : new RoundedRectangleBorder(
                                      side: new BorderSide(color: Colors.grey, width: 4.0),
                                      borderRadius: BorderRadius.circular(15.0))
                                  ),
                                  child: InkWell(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                          new TankDetails(idTank: idTank,idSub: sub, checkPostlarvea: tank.att5.toString())),
                                        ).then((onValue){
                                          setState(() {
                                            memCacheTank = AsyncMemoizer();
                                            // _getTankOfClusterHatchery(_currentClu.att1);
                                          });
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text('${tank.att2}',style: themeData.primaryTextTheme.display4),
                                          sub == "null" ?
                                          new Text('') :
                                          (sub.contains('SUBAT') ?
                                          new Text(Translations.of(context).text('broodstock'),style: themeData.primaryTextTheme.display2) :
                                          (tank.att5.toString() != "null" ?
                                          new Text(Translations.of(context).text('postlarvea'),style: themeData.primaryTextTheme.display2) :
                                          new Text(Translations.of(context).text('nauplii'),style: themeData.primaryTextTheme.display2))
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              );
                            }),
                          ) :
                          ViewsWidget.buildNoResultSearch(context);
                        }
                        return new Center(
                            child: CircularProgressIndicator());
                      }
                  ),
                )

              ],
            );
          }
          return new Center(
              child: CircularProgressIndicator());
        }
    );
  }

}