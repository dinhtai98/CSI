import 'package:flutter_helloworld/utils/function.dart';
class ConvertDataList{
  List<dynamic> convertedList (List<dynamic> list){
    var key;
    var value;
    List<dynamic> newList = new List<dynamic>();
    for(int i = 0; i < list.length; i++){
      Map<String, dynamic> mergeMap = new Map<String, dynamic>();
      Map<String, dynamic> newMap = new Map<String, dynamic>();
      for(int y = 0; y < list[i].length; y++){
        list[i][y].forEach((k,v){
          key = k;
          value = v.toString();
          newMap[key] = value;
        });
      }
      mergeMap.addAll(newMap);
      newList.add(mergeMap);
    }
    return newList;
  }
}

