import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/screens/tank/detail_tank.dart';
import 'package:flutter_helloworld/screens/tank/tank_broodstock.dart';
import 'package:flutter_helloworld/screens/tank/tank_nauplii.dart';
import 'package:flutter_helloworld/screens/tank/tank_postlarvea.dart';
import 'package:flutter_helloworld/style/colors.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../translations.dart';
import 'dialog_cssx_tao_be.dart';
import 'dialog_cssx_tao_nha_sx.dart';




class DanhSachTankCuaNhaSX extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DanhSachTankCuaNhaSXState();
  }
}
class DanhSachTankCuaNhaSXState extends State<DanhSachTankCuaNhaSX> {
  Data data;

  Future<Data> getUser = DataUser.getDataUser();
  int typeHatchery = -1;

  ScrollController _hideButtonController;
  bool showFab = true;

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  Future<List<dynamic>> _getAllTankOfNhaX(String idNhaSX) async{
    return memCache.runOnce(() async {
      List<dynamic> list = List();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryGetAllBeOfNhaSX(idNhaSX)),
          encoding: Encoding.getByName("UTF-8")
      );
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      for (var json in jsonData) {
        list.add(json);
      }
      return list;
    });
  }
  AsyncMemoizer<Data> memCacheTank = AsyncMemoizer();

  Future<Data> _getTank(String idTank) async{
    return memCacheTank.runOnce(() async {
      Data tank = new Data();

      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryGetTank(idTank)),
          encoding: Encoding.getByName("UTF-8")
      );
      print('status ${response.statusCode}');
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      List jsonData = json.decode(result);
      tank = Data.fromJson(jsonData[0]);
      return tank;
    });

  }
  _scrollListener() {
    if (_hideButtonController.offset >= _hideButtonController.position.maxScrollExtent) {
      if(showFab == true) {
        /* only set when the previous state is false
             * Less widget rebuilds
             */
        setState((){
          showFab = false;
        });
      }
    }
    if (_hideButtonController.offset <= _hideButtonController.position.minScrollExtent ||
        _hideButtonController.position.userScrollDirection == ScrollDirection.forward) {
      if(showFab == false) {
        /* only set when the previous state is false
               * Less widget rebuilds
               */
        setState((){
          showFab = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(_scrollListener);
    getUser.then((onValue){
      setState(() {
        typeHatchery = int.parse(onValue.att9.toString());
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
    final double itemWidth = size.width / 2;
    data = InheritedProvider.of<Data>(context);
    ThemeData themeData = buildPrimaryThemeData(context);
    return Scaffold(
      appBar: ViewsWidget.getAppBar(context, 'tank'),
      body: FutureBuilder(
          future: _getAllTankOfNhaX(data.att1.toString()),
          builder: (BuildContext context, AsyncSnapshot snapshotTank) {
            if(snapshotTank.hasError){
              return ViewsWidget.buildNoInternet(context,(){
                setState(() {
                  memCache = AsyncMemoizer();
                });
              });
            }else if(snapshotTank.hasData){
              return snapshotTank.data.length > 0 ? GridView.count(
                crossAxisCount: 2,
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
                                memCache = AsyncMemoizer();
                                // _getTankOfClusterHatchery(_currentClu.att1);
                              });
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Text('${tank.att2}',style: themeData.primaryTextTheme.display4,textAlign: TextAlign.center,),
                                    sub == "null" ?
                                    new Text('') :
                                    (sub.contains('SUBAT') ?
                                    new Text(Translations.of(context).text('broodstock'),style: themeData.primaryTextTheme.display2) :
                                    (tank.att5.toString() != "null" ?
                                    new Text(Translations.of(context).text('postlarvea'),style: themeData.primaryTextTheme.display2) :
                                    new Text(Translations.of(context).text('nauplii'),style: themeData.primaryTextTheme.display2))
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 5,
                                top: 5,
                                child: IconButton(
                                  icon: Icon(Icons.info,color: Colors.blue),
                                  onPressed: () {
                                    showBottomSheetItemTank(idTank);
                                  },
                                ),
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
      floatingActionButton: new Visibility(
        visible: showFab,
        child: new FloatingActionButton(
          onPressed: () {
            openDialog();
          },
          child: new Icon(Icons.add),
        ),
      ),
    );
  }
  void openDialog() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (_) => InheritedProvider<Data>(
          child: new DialogCSSXTaoBe(),
          inheritedData: data,
        ),
        fullscreenDialog: true)).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }

  void showBottomSheetItemTank(String idTank) {
    memCacheTank = AsyncMemoizer();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future:_getTank(idTank),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasError){
              return ViewsWidget.buildNoInternet(context,(){
                setState(() {
                  memCacheTank = AsyncMemoizer();
                });
              });
            }else if(snapshot.hasData){
              Data tank = snapshot.data;
              String year = function.convertDateCSDLToYear(tank.att3.toString());
              return new SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ViewsWidget.buildRowDetails(context,'tank', '${tank.att2.toString()}'),
                    Visibility(
                      visible: typeHatchery == 2,
                      child: ViewsWidget.buildRowDetails(context,'designated_function', '${tank.att4.toString()}'),
                    ),

                    ViewsWidget.buildRowDetails(context,'surface_area', '${function.formatNumber(tank.att5.toString())}'),
                    ViewsWidget.buildRowDetails(context,'working_volume', '${function.formatNumber(tank.att6.toString())}'),
                    Visibility(
                      visible: typeHatchery == 2,
                      child:  ViewsWidget.buildRowDetails(context,'n_of_broodstock_able', '${function.formatNumber(tank.att7.toString())}'),
                    ),Visibility(
                      visible: typeHatchery == 2,
                      child: ViewsWidget.buildRowDetails(context,'n_of_nauplii_able', '${function.formatNumber(tank.att8.toString())}'),
                    ),

                    ViewsWidget.buildRowDetails(context,'establish_year', '$year'),
                  ],
                ),
              );

            }
            return new Center(
                child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}