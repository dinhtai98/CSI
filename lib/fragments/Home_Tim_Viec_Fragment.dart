import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/queries/tank.dart';
import 'package:flutter_helloworld/queries/timviec.dart';
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
import '../translations.dart';

class TimViecFragment extends StatefulWidget {

  final Data data;
  TimViecFragment({this.data});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new TimViecFragmentState(data);
  }
}
class TimViecFragmentState extends State<TimViecFragment> {
  final Data data;
  TimViecFragmentState(this.data);

  List<String> loaiDoanhNghiep = ['Cơ quan quản lý trung ương hoặc vùng',
                                  'Cơ quan quản lý địa phương',
                                  'Cơ sở sản xuất kinh doanh tôm bố mẹ',
                                  'Cơ sở sản xuất kinh doanh Nauplii',
                                  'Cơ sở sản xuất kinh doanh tôm post',
                                  'Đơn vị kiểm bệnh'];

  String _current = 'Cơ quan quản lý trung ương hoặc vùng';


  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();


  void changedDropDow(String selected) {
    setState(() {
      _current = selected;
      print('type ${loaiDoanhNghiep.indexOf(_current)}');
      memCache = AsyncMemoizer();

    });
    //_getTankOfClusterHatchery(_currentClu.att1);
  }
  Future<List<dynamic>> _getDanhSachCongTy(int type) async{
    return memCache.runOnce(() async {
      List<dynamic> tanksOfClu = List();
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(TimViec.querySearchJob(type)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("Home_Tim_Viec_Fragement run");
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

    ThemeData themeData = buildPrimaryThemeData(context);
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
                child: Text(Translations.of(context).text('type_of_business_2'),
                    style: themeData.primaryTextTheme.display1 ),
              ),
              Expanded(
                flex: 4,
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _current,
                    items: loaiDoanhNghiep.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value, style: themeData.primaryTextTheme.display3,),
                      );
                    }).toList(),
                    onChanged: changedDropDow,
                  )
                ),

              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
              future: _getDanhSachCongTy(loaiDoanhNghiep.indexOf(_current)),
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
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) => buildItemCongTy(context,snapshot.data, index)
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
  Widget buildItemCongTy(BuildContext context, List<dynamic> list,int index) {
    ThemeData themeData = buildPrimaryThemeData(context);
    Data congty = Data.fromJson(list[index]);

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
              /*
              int type = loaiDoanhNghiep.indexOf(_current);
              if(type >= 2 && type <= 4){
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (_) =>
                        InheritedProvider<String>(
                          child: new HatcheryDetails(checkApply: 1,) ,
                          inheritedData: congty.att1.toString(),
                        ))).then((onValue) {
                  setState(() {
                    memCache = AsyncMemoizer();
                  });
                });
              }

               */
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
                '${congty.att2}', style: themeData.primaryTextTheme.display1
            ),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                Text('Địa chỉ', style: themeData.primaryTextTheme.display2),
                Text('${congty.att3}', style: themeData.primaryTextTheme.display2)
              ],
            ),
          ),
        )
    );
  }
}