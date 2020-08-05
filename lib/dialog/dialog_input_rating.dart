import 'dart:convert';
import 'package:flutter_helloworld/queries/contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/style/theme_style.dart';
import 'package:flutter_helloworld/utils/api.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:flutter_helloworld/views/view.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:flutter_helloworld/utils/function.dart';
import '../navigator.dart';
import '../translations.dart';


class DialogInputRanking extends StatefulWidget {
  BuildContext ctx;
  DialogInputRanking({this.ctx});
  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new DialogInputRankingState();
  }
}
class DialogInputRankingState extends State<DialogInputRanking> {
  BuildContext preContext;
  List<String> getData;
  String idCon, idSeller, idBuyer;
  double rating = 0;
  var txtComment = new TextEditingController();
  _executeRanking(BuildContext curContext) async {
    FocusScope.of(curContext).requestFocus(FocusNode());
    //proccontract_ranking
    if(rating != 0.0) {
      String comment = txtComment.text.toString();
      var _checkInternet = function.checkInternet();
      _checkInternet.then((onValue) async {
        if(onValue){
          http.Response response = await http.post(
              Api.url_update,
              headers: {
                "SOAPAction": "http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL",
                "Content-Type": "application/x-www-form-urlencoded",
                "cache-control": "no-cache"
              },
              body: utf8.encode(idCon.contains('IMCON') ? Contract.queryHatcheryRankingProducer(idSeller, idBuyer, idCon,rating.toInt(),comment) : Contract.queryHatcheryRankingContract(idSeller, idBuyer, idCon,rating.toInt(),comment)),
              encoding: Encoding.getByName("UTF-8")
          );
          var p = response.body.indexOf(">");
          var e = response.body.lastIndexOf("<");
          var result = response.body.substring(p + 1, e);

          if (result.contains("1")) {
            Toast.show(Translations.of(preContext).text('saved'), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            Navigator.pop(curContext);
          } else {
            Toast.show(Translations.of(preContext).text('error'), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        }else {
          Toast.show(Translations.of(preContext).text('no_internet'), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      });

    }else{
      Toast.show(Translations.of(preContext).text('please_input'), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    preContext = widget.ctx;
    getData = InheritedProvider.of<List<String>>(context);
    idCon = getData[0];
    idSeller = getData[1];
    idBuyer = getData[2];
    return  AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        contentPadding: EdgeInsets.only(top: 0.0),
        content: SingleChildScrollView(
          child: Container(
              width: 300.0,
              child: inputRanking(context)
          ),
        )

    );

  }
  Widget inputRanking(BuildContext curContext){
    ThemeData themeData = buildPrimaryThemeData(curContext);
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ViewsWidget.buildTitleDialog(preContext, 'ranking'),
          new StarRating(rating: rating,size: 30,
            onRatingChanged: (rating) => setState(
                  () {
                this.rating = rating;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(Translations.of(preContext).text('comment'),
                    style: themeData.primaryTextTheme.display4,),
                ),
                Flexible(
                    flex: 4,
                    child: new TextField(
                        controller: txtComment,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: Translations.of(preContext).text('hint_comment'),
                          //border:
                        )
                    )
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ViewsWidget.buildButtonDismiss(curContext,'cancel'),
              ViewsWidget.buildButtonAction(curContext, 'save', _executeRanking)

            ],
          ),
        ]
    );
  }

}