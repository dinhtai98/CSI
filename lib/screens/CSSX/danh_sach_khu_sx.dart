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
import 'danh_sach_nha_sx.dart';
import 'dialog_cssx_tao_khu_sx.dart';

class DanhSachKhuSX extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DanhSachKhuSXState();
  }
}
class DanhSachKhuSXState extends State<DanhSachKhuSX> {

  // 1: CS Tôm bố mẹ, 2 CS Nauplii, 3 CS Postlarvea
  int typeHatchery = -1;

  Data data;

  ScrollController _hideButtonController;
  bool showFab = true;

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  Future<List<dynamic>> _getAllKhuSXOfCSSX(String idHatchery) async{
    return memCache.runOnce(() async {
      List<dynamic> list = List();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.query_GetAllKhuSXOfCSSX(idHatchery)),
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
  AsyncMemoizer<Data> memCacheCluster = AsyncMemoizer();
  Future<Data> _getKhuSX(String idCluster) async{
    return memCacheCluster.runOnce(() async {
      Data khusx = new Data();

      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Tank.queryKhuSX(idCluster)),
          encoding: Encoding.getByName("UTF-8")
      );

      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      List jsonData = json.decode(result);
      khusx = Data.fromJson(jsonData[0]);
      return khusx;
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

  }

  @override
  Widget build(BuildContext context) {
    data = InheritedProvider.of<Data>(context);
    typeHatchery = int.parse(data.att9.toString());
    ThemeData themeData = buildPrimaryThemeData(context);
    return Scaffold(
      body: FutureBuilder(
          future: _getAllKhuSXOfCSSX(data.att1.toString()),
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
                  controller: _hideButtonController,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) => buildItemKhuSX(context,snapshot.data, index)
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
          child: new DialogCSSXTaoKhuSX(),
          inheritedData: data,
        ),
        fullscreenDialog: true)).then((onValue){
      setState(() {
        memCache = AsyncMemoizer();
      });
    });
  }
  Widget buildItemKhuSX(BuildContext context, List<dynamic> list,int index) {
    ThemeData themeData = buildPrimaryThemeData(context);
    Data khusx = Data.fromJson(list[index]);

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
            onTap: () {
              if(typeHatchery > 1){
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (_) =>
                        InheritedProvider<Data>(
                          child: new DanhSachNhaSX() ,
                          inheritedData: khusx,
                        ))).then((onValue) {
                  setState(() {
                    memCache = AsyncMemoizer();
                  });
                });
              }
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
                '${khusx.att2}', style: themeData.primaryTextTheme.display1
            ),
            trailing: IconButton(
              icon: Icon(Icons.info, color: kColorIcon , size: 30.0),
              onPressed: (){
                showBottomSheetItemCluster(khusx.att1.toString());
              },
            ),
          ),
        )
    );
  }
  void showBottomSheetItemCluster(String idCluster) {
    memCacheCluster = AsyncMemoizer();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future:_getKhuSX(idCluster),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasError){
              return ViewsWidget.buildNoInternet(context,(){
                setState(() {
                  memCacheCluster = AsyncMemoizer();
                });
              });
            }else if(snapshot.hasData){
              Data khusx = snapshot.data;
              String year = function.convertDateCSDLToYear(khusx.att8.toString());
              return new SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ViewsWidget.buildRowDetails(context,'name_of_production_cluster', '${khusx.att2.toString()}'),
                    ViewsWidget.buildRowDetails(context,'address', '${khusx.att3.toString()}'),
                    ViewsWidget.buildRowDetails(context,'country', '${khusx.att4.toString()}'),
                    ViewsWidget.buildRowDetails(context,'gps', '${khusx.att5.toString()}'),
                    ViewsWidget.buildRowDetails(context,'contact_name', '${khusx.att6.toString()}'),
                    ViewsWidget.buildRowDetails(context,'phone', '${khusx.att7.toString()}'),
                    ViewsWidget.buildRowDetails(context,'production_capacity', '${function.formatNumber(khusx.att9.toString())}'),
                    Visibility(
                      visible: typeHatchery > 1,
                      child: ViewsWidget.buildRowDetails(context, 'n_of_production_unit', '${khusx.att10.toString()}'),
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