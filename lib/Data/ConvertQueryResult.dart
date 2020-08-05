import '../Data/ConvertDataList.dart';

class ConvertQueryResult{
  List<dynamic> convertQueryResultToList(List<Map<String, dynamic>> result){
    List<dynamic> list1 = new List<dynamic>();
    List<dynamic> list2 = new List<dynamic>();
    for(final row in result) {
      List<dynamic> list = new List<dynamic>();
      row.forEach((k, v){
        list.add(v);
      });
      list1.add(list);
    }
    list2 = ConvertDataList().convertedList(list1);
    return list2;
  }
}