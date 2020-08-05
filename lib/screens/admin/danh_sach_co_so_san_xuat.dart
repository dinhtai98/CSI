import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/coquanquanly.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/screens/admin/thong_tin_co_quan_quan_ly.dart';
import 'package:flutter_helloworld/screens/hatchery/detail_hatchery.dart';
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
import 'package:postgres/postgres.dart';
import '../../translations.dart';
import 'chi_tiet_co_so_san_xuat.dart';
import 'dialog_tao_co_quan_quan_ly.dart';
import 'dart:developer';
import '../../Data/ConvertQueryResult.dart';


class DanhSachCoSoSanXuat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DanhSachCoSoSanXuatState();
  }
}
class DanhSachCoSoSanXuatState extends State<DanhSachCoSoSanXuat> {

  List<String> _dropDownCoQuanQuanLy = ['Cơ sở Tôm bố mẹ', 'Cơ sở Nauplii', 'Cơ sở Postlarvea',];

  int _currentType = 1;


  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();

  void changedDropDown(int selected) {
    setState(() {
      _currentType = selected;
      memCache = AsyncMemoizer();

    });
    //_getTankOfClusterHatchery(_currentClu.att1);
  }
  Future<List<dynamic>> _getDSCoSoSanXuatTheoLoai(int type) async{
    return memCache.runOnce(() async {
      List<dynamic> list = List();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Hatchery.queryGetCoSoSanXuatTheoLoai(type)),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    //final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    //final double itemWidth = size.width / 2;
    ThemeData themeData = buildPrimaryThemeData(context);
    return  Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(Translations.of(context).text('type'),
                      style: themeData.primaryTextTheme.display1 ),
                ),
                Expanded(
                  flex: 4,
                  child: ButtonTheme(
                      alignedDropdown: true,
                      child: new DropdownButton<int>(
                        items: _dropDownCoQuanQuanLy.map((String value) {
                          return new DropdownMenuItem<int>(
                            value: _dropDownCoQuanQuanLy.indexOf(value) + 1,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: changedDropDown,
                        isExpanded: true,
                        style: themeData.primaryTextTheme.display3,
                        value: _currentType,
                      )
                  ),

                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getDSCoSoSanXuatTheoLoai(_currentType),
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
                        itemBuilder: (BuildContext context, int index) => buildItem(context,snapshot.data, index)
                    ):
                    ViewsWidget.buildNoResultSearch(context);
                  }
                  return new Center(
                      child: CircularProgressIndicator());
                }
            ),
          )

        ],
      ),
    );
  }
  Widget buildItem(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data item = Data.fromJson(list[index]);
    int typeBusiness = int.parse(item.att3.toString());
    return new Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.teal[600]),
            borderRadius: BorderRadius.circular(25.0),
            ),
          child: ListTile(
            onTap: () {
              Navigator.of(ctxt).push(new MaterialPageRoute<Null>(
                  builder: (_) =>
                      InheritedProvider<String>(
                        child: new AdminHatcheryDetails(),
                        inheritedData: item.att1,
                      ))).then((onValue) {
                setState(() {
                  memCache = AsyncMemoizer();
                });
              });
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
              '${item.att2}', style: themeData.primaryTextTheme.display1,textAlign: TextAlign.center,
            ),
            subtitle: Text(
              '${typeBusiness == 1 ? 'Sản xuất' : ( typeBusiness == 2 ? 'Sản xuất & Kinh doanh' : 'Kinh doanh')}', style: themeData.primaryTextTheme.display1,textAlign: TextAlign.center,
            ),
          )
      ),
    );
  }
}