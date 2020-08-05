import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/thongke.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_helloworld/utils/function.dart';
import 'package:flutter_helloworld/custom_expansion_tile.dart' as custom;
import 'package:image/image.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';
import '../../translations.dart';

class ThongKeDanhSachDangky extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new ThongKeDanhSachDangkyState();
  }
}
class ListItem {
  String title;
  String icon;
  int number;
  List<SubItem> arrExpandable = [];
  ListItem(this.title, this.icon,this.number, this.arrExpandable);
}
class SubItem {
  String title;
  String icon;
  String number;
  List<String> arr = [];
  SubItem(this.title, this.icon, this.number, this.arr);
}
class ThongKeDanhSachDangkyState extends State<ThongKeDanhSachDangky> {
  List<ListItem> list = [];
  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getTatCaSoLuongDangKy() async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(ThongKe.queryThongKe),
          encoding: Encoding.getByName("UTF-8")
      );
      print("body: ${response.body}");
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
    list.clear();
    list = [new ListItem("Cơ quan quản lý", "assets/images/icon_calendar.png", 0 ,[]),
    new ListItem("Cơ sở sản xuất", "assets/images/icon_calendar.png",  0 ,[]),
    new ListItem("Đơn vị kiểm bệnh", "assets/images/icon_calendar.png",  0 ,[]),
    new ListItem("Người mua tôm giống", "assets/images/icon_calendar.png",  0 ,[]),
    new ListItem("Đội ngũ lao động", "assets/images/icon_calendar.png",  0 ,[])];
    // TODO: implement build
    return FutureBuilder(
        future: _getTatCaSoLuongDangKy(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasError){
            return ViewsWidget.buildNoInternet(context,(){
              setState(() {
                memCache = AsyncMemoizer();
              });
            });
          }else if(snapshot.hasData){
            Data data = snapshot.data;
            // Cơ Quan Quản Lý
            list[0].number = int.parse(data.att1.toString());
            list[0].arrExpandable.clear();
            list[0].arrExpandable.add(new SubItem("Tổng Cục Thủy Sản","",data.att2.toString(),[]));
            list[0].arrExpandable.add(new SubItem("Cục Thú Y","",data.att3.toString(),[]));
            list[0].arrExpandable.add(new SubItem("Hải Quan","",data.att4.toString(),[]));
            list[0].arrExpandable.add(new SubItem("Cơ Quan Địa Phương","",data.att5.toString(),[]));

            // Cơ Sơ Sản Xuất
            list[1].number = int.parse(data.att6.toString());
            list[1].arrExpandable.clear();
            list[1].arrExpandable.add(new SubItem("Cơ sở Tôm bố mẹ","","",[data.att7.toString(),data.att8.toString(),data.att9.toString()]));
            list[1].arrExpandable.add(new SubItem("Cơ sở Nauplii","",data.att14.toString(),[data.att10.toString(),data.att11.toString(),data.att12.toString()]));
            list[1].arrExpandable.add(new SubItem("Cơ sở Postlarvea","",data.att9.toString(),[data.att13.toString(),data.att14.toString(),data.att15.toString()]));

            //DVKB
            list[2].number = int.parse(data.att16.toString());

            //NguoiMuaTom
            list[3].number = int.parse(data.att17.toString());

            //Doi Ngu Lao Dong
            list[4].number = int.parse(data.att18.toString());
            return new ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return index < 2 ? new Container(
                  margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(backgroundColor: Colors.white),
                    child: custom.ExpansionTile(
                      title: RichText(
                        //textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: list[index].title, style: themeData.primaryTextTheme.display1),
                            TextSpan(text: ' : ${list[index].number.toString()}',
                                style: themeData.primaryTextTheme.display3),
                          ],
                        ),
                      ),
                      backgroundColor: Colors.white70,
                      children: <Widget>[
                        new Column(
                          children: _buildExpandableContent(index),
                        ),
                      ],
                      headerBackgroundColor: Colors.lightBlue[50],
                    ),
                  ),
                ): _buildItemList(index);
              }
            );
          }
          return new Center(
              child: CircularProgressIndicator());
        }
    );
  }
  _buildExpandableContent(int index) {
    List<Widget> columnContent = [];

    for (SubItem content in list[index].arrExpandable)
      columnContent.add(
        new ListTile(
          title: index == 0 ? _expandableForCoQuanQuanLy(content) : _expandableForCoSoSanXuat(content)
          //leading: new Icon(vehicle.icon),
        ),
      );
    return columnContent;
  }
  _expandableForCoQuanQuanLy(SubItem content){
    ThemeData themeData = buildPrimaryThemeData(context);
    return RichText(
      //textAlign: TextAlign.center,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: content.title, style: themeData.primaryTextTheme.display4),
          TextSpan(text: ' : ${content.number.toString()}',
              style: themeData.primaryTextTheme.display3),
        ],
      ),
    );
  }
  _expandableForCoSoSanXuat(SubItem content){
    ThemeData themeData = buildPrimaryThemeData(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: new Text(content.title, style: themeData.primaryTextTheme.display2),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: RichText(
            //textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "Sản xuất", style: themeData.primaryTextTheme.display4),
                TextSpan(text: ' : ${content.arr[0]}',
                    style: themeData.primaryTextTheme.display3),
              ],
            ),
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child:  RichText(
            //textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "Sản xuất & Kinh doanh", style: themeData.primaryTextTheme.display4),
                TextSpan(text: ' : ${content.arr[1]}',
                    style: themeData.primaryTextTheme.display3),
              ],
            ),
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: RichText(
            //textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "Kinh doanh", style: themeData.primaryTextTheme.display4),
                TextSpan(text: ' : ${content.arr[2]}',
                    style: themeData.primaryTextTheme.display3),
              ],
            ),
          )
        )
      ],
    );
  }
  _buildItemList(int index) {
    ThemeData themeData = buildPrimaryThemeData(context);
    return new Container(
      child: ListTile(
        title:RichText(
          //textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: list[index].title, style: themeData.primaryTextTheme.display1),
              TextSpan(text: ' : ${list[index].number.toString()}',
                  style: themeData.primaryTextTheme.display3),
            ],
          ),
        ),
      ),
      color: Colors.lightBlue[50],
      margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
    );
  }

}