import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'DataPart.dart';
@JsonSerializable(nullable: false)
class Data{
   String att1;
   String att2;
   String att3;
   String att4;
   String att5;
   String att6;
   String att7;
   String att8;
   String att9;
   String att10;
   String att11;
   String att12;
   String att13;
   String att14;
   String att15;
   String att16;
   String att17;
   String att18;
   String att19;
   String att20;
   String att21;
   String att22;
   String att23;

    Data({
    this.att1, this.att2, this.att3, this.att4, this.att5, this.att6,
    this.att7, this.att8, this.att9, this.att10, this.att11, this.att12,
    this.att13, this.att14, this.att15, this.att16, this.att17, this.att18,
    this.att19,this.att20,this.att21,this.att22,this.att23
    });

  factory Data.fromJson(Map<String, dynamic> json){
    return new Data(
      att1 : json['att1'],
      att2 : json['att2'],
      att3 : json['att3'],
      att4 : json['att4'],
      att5 : json['att5'],
      att6 : json['att6'],
      att7 : json['att7'],
      att8 : json['att8'],
      att9 : json['att9'],
      att10 : json['att10'],
      att11 : json['att11'],
      att12 : json['att12'],
      att13 : json['att13'],
      att14 : json['att14'],
      att15 : json['att15'],
      att16 : json['att16'],
      att17 : json['att17'],
      att18 : json['att18'],
      att19 : json['att19'],
      att20 : json['att20'],
      att21 : json['att21'],
      att22 : json['att22'],
      att23 : json['att23'],
    );
  }

   Map<String, dynamic> toJson() => _$DataToJson(this);
}


class DataList {
  final List<Data> datas;

  DataList({
    this.datas,
  });
  factory DataList.fromJson(List<dynamic> parsedJson) {

    List<Data> datas = new List<Data>();

    return new DataList(
      datas: datas,
    );
  }
}
