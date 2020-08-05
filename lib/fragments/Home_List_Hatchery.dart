import 'dart:convert';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/queries/coquanquanly.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/scoped_model/home_selected_menu.dart';
import 'package:flutter_helloworld/screens/hatchery/detail_hatchery.dart';
import 'package:flutter_helloworld/screens/trader/detail_trader.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_helloworld/utils/function.dart';
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeListHatchery extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new HomeListHatcheryState();
  }
}
class HomeListHatcheryState extends State<HomeListHatchery> {

  AsyncMemoizer<List<dynamic>> memCache = AsyncMemoizer();
  _getAllHatcheryByID(String id, String term) async {
    List<dynamic> listHatchery = List();
    List<String> listProvinceOfCompany = new List<String>();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(CoQuanQuanLy.queryGetProvinceCoQuanQuanLy(id)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("Home_List_Hatchery running");
      var p = response.body.indexOf("[");
      var e = response.body.lastIndexOf("]");
      var result = response.body.substring(p, e + 1);
      var jsonData = json.decode(result);
      Data data = Data.fromJson(jsonData[0]);
      listProvinceOfCompany = data.att1.split(",");
      for (int i = 0; i < listProvinceOfCompany.length; i++) {
        http.Response response = await http.post(
            Api.urlGetDataByPost,
            headers: {
              "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
              "Content-Type": "application/x-www-form-urlencoded",
              "cache-control": "no-cache"
            },
            body: utf8.encode(Hatchery.queryGetAllHatcheryByID(term, listProvinceOfCompany[i].toString())),
            encoding: Encoding.getByName("UTF-8")
        );
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        var hatcheryData = json.decode(result);
        listHatchery.addAll(hatcheryData);
      }
      return listHatchery;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageCache.clear();
  }
  String searchTerm = '';
  @override
  Widget build(BuildContext context) {
    final data = InheritedProvider.of<Data>(context);
    print('data ${data.att1.toString()}');
    // TODO: implement build
    return  ScopedModelDescendant<PopupMenu>(
      builder: (context, child, model) {
        if(model.selectedDate != searchTerm){
          memCache = AsyncMemoizer();
          searchTerm = model.selectedDate;
        }
        print(data.att1.toString());
        print(searchTerm);
        // selectedDate = searchText
        return FutureBuilder(
            future: _getAllHatcheryByID(data.att1.toString(), searchTerm),
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
                    itemBuilder: (BuildContext context, int index) => buildItemTrader(context,snapshot.data, index)
                ):
                ViewsWidget.buildNoResultSearch(context);
              }
              return new Center(
                  child: CircularProgressIndicator());
            }
        );
      },
    );
  }

  Widget buildItemTrader(BuildContext ctxt, List<dynamic> list ,int index) {
    ThemeData themeData = buildPrimaryThemeData(ctxt);
    Data hatchery = Data.fromJson(list[index]);
    String photo = "${Api.urlImageHatchery}${hatchery.att3}";

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
              Navigator.of(ctxt).push(new MaterialPageRoute<Null>(
                  builder: (_) =>
                      InheritedProvider<String>(
                        child: new HatcheryDetails(),
                        inheritedData: hatchery.att1,
                      ))).then((onValue) {
                setState(() {
                  memCache = AsyncMemoizer();
                });
              });
            },


            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Padding(padding: EdgeInsets.all(10.0),
              child: Text(
                '${hatchery.att2}', style: themeData.primaryTextTheme.display1,textAlign: TextAlign.center,
              ),
            ),
            subtitle: Center(
              child: new ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Image.network("$photo",
                    height: 120,
                    width: 270,
                    fit: BoxFit.fill,
                    //imageUrl: "$photo",
                    //placeholder: (context, url) => new CircularProgressIndicator(),
                    //errorWidget: (context, url, error) => new Icon(Icons.error))
                )
              )
            )
        ),
    ));
  }
}