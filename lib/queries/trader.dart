import 'package:flutter_helloworld/utils/diacritics.dart';

class Trader{
  static String queryGetAllStaffTrader = "13" + "^" + "Select \"IDTraderStaff\" as \"att1\", \"TraderStaffLastName\" as \"att2\", \n" +
      "\"TraderStaffFirstName\" as \"att3\", \"TraderStaffPhone\" as \"att4\", \"Manage\" as \"att5\",\n" +
      "\"TraderStaffEmail\" as \"att6\",\"Tbl_TraderStaff\".\"IDBroodstockTrader\" as \"att7\",\n" +
      "\"Username\" as \"att8\", \"Password\" as \"att9\",\n" +
      "\"Active\" as \"att10\",\"CreatedDate\" as \"att11\",\n" +
      "\"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att12\"\n" +
      "from public.\"Tbl_TraderStaff\",\"Tbl_BroodstockTrader\"\n" +
      "WHERE \"Tbl_TraderStaff\".\"IDBroodstockTrader\" = \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\"";
  static String queryGetStaffTrader(String idStaff){
    String query = "11" + "^" + "Select \"IDTraderStaff\" as \"att1\", \"TraderStaffLastName\" as \"att2\", \"TraderStaffFirstName\" as \"att3\", \n" +
        "\"TraderStaffPhone\" as \"att4\", \"Manage\" as \"att5\", \"TraderStaffEmail\" as \"att6\",\n" +
        "\"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att7\",\"Username\" as \"att8\", \"Password\" as \"att9\",\n" +
        "\"Active\" as \"att10\",\"CreatedDate\" as \"att11\" \n" +
        "from public.\"Tbl_TraderStaff\", \"Tbl_BroodstockTrader\"\n" +
        "WHERE \"Tbl_TraderStaff\".\"IDBroodstockTrader\" = \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\" AND\n" +
        "\"IDTraderStaff\" = '$idStaff' ";
    return query;
  }
  static String query_getAllTrader = "6" + "^" + "Select \"IDBroodstockTrader\" as \"att1\", \"BroodstockTraderName\" as \"att2\", \"ContactTraderLastName\" as \"att3\", \n" +
      "\"ContactTraderFirstName\" as \"att4\", \"BroodstockTraderSpecies\" as \"att5\", \"BroodstockTraderTypes\" as \"att6\" \n" +
      "from \"Tbl_BroodstockTrader\"";
  static String queryFilterNameAllTrader(String filter){
    if(filter.length > 0){
      filter = "ILIKE '%${TextUnaccented.removeDiacritics(filter)}%'";
    }else{
      filter = 'IS NOT NULL';
    }
    String query = "6" + "^" + "Select \"IDBroodstockTrader\" as \"att1\", \"BroodstockTraderName\" as \"att2\", \"ContactTraderLastName\" as \"att3\", \n" +
        "\"ContactTraderFirstName\" as \"att4\", \"BroodstockTraderSpecies\" as \"att5\", \"BroodstockTraderTypes\" as \"att6\" \n" +
        "from \"Tbl_BroodstockTrader\" \n" +
        "where (\"BroodstockTraderName\") $filter \n"
        "order by \"BroodstockTraderName\"";
    return query;
  }
  static String queryGetTrader(String idTrader) {
    String query = "15" + "^" +
        "Select \"IDBroodstockTrader\" as \"att1\", \"BroodstockTraderName\" as \"att2\", \"ContactTraderLastName\" as \"att3\", \n" +
        "\"ContactTraderFirstName\" as \"att4\", \"ContactTraderPhone\" as \"att5\", \n" +
        "\"BroodstockTraderSpecies\" as \"att6\", \"BroodstockTraderTypes\" as \"att7\",\n" +
        "\"BroodstockTraderEstablishmentYear\" as \"att8\", \"BroodstockTraderBusinessNumber\" as \"att9\", \n" +
        "\"BroodstockTraderStreetAddress\" as \"att10\",\n" +
        "\"Tbl_City\".\"CityName\" as \"att11\", \n" +
        "\"BroodstockTraderOperatedYear\" as \"att12\",\"BroodstockTraderEmail\" as \"att13\", \n" +
        "\"TraderCompanyCode\" as \"att14\",\"Tbl_Province\".\"ProvinceName\" as \"att15\" \n" +
        "from \"Tbl_BroodstockTrader\", \"Tbl_City\",\"Tbl_Province\" \n" +
        "WHERE \"Tbl_City\".\"IDCity\" = \"Tbl_BroodstockTrader\".\"IDCity\" AND\n" +
        "\"Tbl_City\".\"IDProvince\" = \"Tbl_Province\".\"IDProvince\" AND\n" +
        "\"IDBroodstockTrader\" = '$idTrader'";
    return query;
  }
}