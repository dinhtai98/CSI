import 'dart:async';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter_helloworld/queries/coquanquanly.dart';
import 'package:flutter_helloworld/queries/hatchery.dart';
import 'package:flutter_helloworld/queries/producer.dart';
import 'package:flutter_helloworld/queries/timviec.dart';
import 'package:flutter_helloworld/queries/trader.dart';
import 'package:flutter_helloworld/screens/photo/view_image.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';
import '../../translations.dart';
import 'package:flutter_helloworld/utils/function.dart';
import '../../Data/ConvertQueryResult.dart';
import 'package:postgres/postgres.dart';
class AdminDetailsCoQuanQuanLy extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new AdminDetailsCoQuanQuanLyState();
  }
}
class AdminDetailsCoQuanQuanLyState extends State<AdminDetailsCoQuanQuanLy> {

  String idAuthor;

  AsyncMemoizer<Data> memCache = AsyncMemoizer();

  Future<Data> _getCoQuanQuanLy(String idAuthor) async{
    List<dynamic> list = List();
    Data data = new Data();
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(CoQuanQuanLy.queryGetCoQuanQuanLy(idAuthor)),
          encoding: Encoding.getByName("UTF-8")
      );

      if (response.statusCode == 200) {

        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        var jsonData = json.decode(result);
        data = Data.fromJson(jsonData[0]);
      }
      return data;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idAuthor = InheritedProvider.of<String>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('authority_details'),
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
              future: _getCoQuanQuanLy(idAuthor),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data cqql = snapshot.data;
                  int level = int.parse(cqql.att2.toString());
                  String managementLevel = '';
                  if(level == 1)
                    managementLevel = Translations.of(context).text('state');
                  else
                    managementLevel = level == 2 ? Translations.of(context).text('zone') : Translations.of(context).text('province');
                  return new Column(
                    children: <Widget>[
                      GestureDetector(
                        // child: new ClipRRect(
                        //     borderRadius: new BorderRadius.only(
                        //         bottomLeft : const Radius.circular(15.0),
                        //         bottomRight: const Radius.circular(15.0)
                        //     ),
                        //     child: Image.network("${Api.urlImageHatchery}${cqql.att5}",
                        //         height: 180,
                        //         width: MediaQuery.of(context).size.width,
                        //         fit: BoxFit.fill,
                        //         //imageUrl: "",
                        //         //placeholder: (context, url) => new CircularProgressIndicator(),
                        //         //errorWidget: (context, url, error) => new Icon(Icons.error)
                        //     )
                        // ),
                        child: Text("Mở comment code ở trên để hiện hình ảnh khi có ảnh rồi"),
                        onTap: () {
                          Navigator.of(context).push(new MaterialPageRoute<Null>(
                              builder: (_) =>
                                  InheritedProvider<String>(
                                    child: new ViewImage() ,
                                    inheritedData: "${Api.urlImageHatchery}${cqql.att5}",
                                  ))).then((onValue) {
                            setState(() {
                              memCache = AsyncMemoizer();
                            });
                          });
                        }
                      ),
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text('${cqql.att1}',
                                style: themeData.primaryTextTheme.display1,
                              textAlign: TextAlign.center,)
                            ),
                            ViewsWidget.buildRowDetails(context,  'management_level', '$managementLevel'),
                            Visibility(
                              child: ViewsWidget.buildRowDetails(context, level == 2 ? 'zone' : 'province', '${cqql.att3}'),
                              visible: level != 1,
                            ),
                            ViewsWidget.buildRowDetails(context, 'username', '${cqql.att11}'),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                        child: Column(
                          children: <Widget>[
                            ViewsWidget.buildRowDetails(context, 'authority_leader', '${cqql.att9}'),
                            ViewsWidget.buildRowDetails(context, 'mobile_phone', '${cqql.att7}'),
                            ViewsWidget.buildRowDetails(context, 'website', '${cqql.att4}'),
                            ViewsWidget.buildRowDetails(context, 'address', '${cqql.att6}'),
                            ViewsWidget.buildRowDetails(context, 'number_of_staff', '${cqql.att10}'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return new Center(
                    child: CircularProgressIndicator());
              }
          )
      ),
    );
  }

}
