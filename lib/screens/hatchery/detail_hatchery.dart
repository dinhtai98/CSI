import 'dart:async';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/Data/ConvertQueryResult.dart';
import 'package:flutter_helloworld/Data/Data.dart';
import 'package:flutter_helloworld/Data/DataUser.dart';
import 'package:flutter_helloworld/dialog/dialog_input_rating.dart';
import 'package:flutter_helloworld/dialog/dialog_view_rating.dart';
import 'package:flutter_helloworld/queries/contract.dart';
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
import 'package:postgres/postgres.dart';

class HatcheryDetails extends StatefulWidget {

  int checkApply;
  HatcheryDetails({this.checkApply});

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new HatcheryDetailsState();
  }
}
class HatcheryDetailsState extends State<HatcheryDetails> {
  String idHatchery, idUser;

  Future<Data> getUser = DataUser.getDataUser();

  AsyncMemoizer<Data> memCache = AsyncMemoizer();
  Future<Data> _getHatchery(String idHat) async{
    return memCache.runOnce(() async {
      http.Response response = await http.post(
          Api.urlGetDataByPost,
          headers: {
            "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache"
          },
          body: utf8.encode(Hatchery.queryGetHatchery(idHat)),
          encoding: Encoding.getByName("UTF-8")
      );
      print("body in detail_hatchery: ${response.body}");
      if (response.statusCode == 200) {

        Data data = new Data();
        var p = response.body.indexOf(">");
        var e = response.body.lastIndexOf("<");
        var result = response.body.substring(p + 1, e);
        var jsonData = json.decode(result);
        data = Data.fromJson(jsonData[0]);
        return data;
      }else {
        throw("");
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageCache.clear();
    getUser.then((onValue){
      setState(() {
        idUser = onValue.att10.toString();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = buildPrimaryThemeData(context);
    idHatchery = InheritedProvider.of<String>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Translations.of(context).text('hatchery_details'),
          style: themeData.primaryTextTheme.caption,),
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
              future: _getHatchery(idHatchery),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return ViewsWidget.buildNoInternet(context,(){
                    setState(() {
                      memCache = AsyncMemoizer();
                    });
                  });
                }else if(snapshot.hasData){
                  Data hatchery = snapshot.data;
                  return new Column(
                    children: <Widget>[
                      GestureDetector(
                        child: new ClipRRect(
                            borderRadius: new BorderRadius.only(
                                bottomLeft : const Radius.circular(15.0),
                                bottomRight: const Radius.circular(15.0)
                            ),
                            child: Image.network("${Api.urlImageHatchery}${hatchery.att6}",
                                height: 180,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                //imageUrl: "",
                                //placeholder: (context, url) => new CircularProgressIndicator(),
                                //errorWidget: (context, url, error) => new Icon(Icons.error)
                            )
                        ),
                        onTap: () {
                          Navigator.of(context).push(new MaterialPageRoute<Null>(
                              builder: (_) =>
                                  InheritedProvider<String>(
                                    child: new ViewImage() ,
                                    inheritedData: "${Api.urlImageHatchery}${hatchery.att6}",
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
                              child: Text('${hatchery.att2}',
                                style: themeData.primaryTextTheme.display1,
                              textAlign: TextAlign.center,)
                            ),
                            //ViewsWidget.buildRowDetails(context, 'hatchery', '${hatchery.att2}'),
                            ViewsWidget.buildRowDetails(context,  'owner', '${hatchery.att3}'),
                            //ViewsWidget.buildRowDetails(context, 'phone', '${hatchery.att9}'),
                            //ViewsWidget.buildRowDetails(context, 'email', '${hatchery.att9}'),
                            ViewsWidget.buildRowDetails(context, 'address', '${hatchery.att4}'),
                            ViewsWidget.buildRowDetails(context, 'province', '${hatchery.att10}'),

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
                            ViewsWidget.buildRowDetails(context, 'business_number', '${hatchery.att9}'),
                            //ViewsWidget.buildRowDetails(context, 'company_code', '${hatchery.att10}'),
                            ViewsWidget.buildRowDetails(context, 'establish_year', '${function.convertDateCSDLToYear(hatchery.att8)}'),
                          ],
                        ),
                      ),
                      /*Visibility(
                        visible: widget.checkApply == 1,
                        child: ViewsWidget.buildBigButtonAction(context, 'apply', _applyJob)
                      )*/

                    ],
                  );
                }
                return new Center();


              }
          )
      ),
    );
  }
  /*_applyJob(BuildContext context) async {
    http.Response response = await http.post(
        Api.url_update,
        headers: {
          "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
          "Content-Type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache"
        },
        body: utf8.encode(TimViec.queryApplyCompany(
            idUser,
            idHatchery)),
        encoding: Encoding.getByName("UTF-8")
    );
    var p = response.body.indexOf(">");
    var e = response.body.lastIndexOf("<");
    var result = response.body.substring(p + 1, e);
    if (result.contains("1")) {
      Toast.show(Translations.of(context).text('saved'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }else{
      Toast.show(Translations.of(context).text('error'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }*/
}
